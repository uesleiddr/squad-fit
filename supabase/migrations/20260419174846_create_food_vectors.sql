-- ============================================
-- Migration: Tabela de vetores para busca semântica de alimentos
-- ============================================
-- Esta tabela armazena embeddings pré-gerados dos alimentos
-- para permitir busca semântica usando pgvector.
--
-- Os embeddings são gerados pelo Gemini embedding-001 (768 dimensões)
-- e migrados via script: npm run migrate-vectors
-- ============================================

-- 1. Habilita a extensão pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Cria a tabela de vetores
CREATE TABLE IF NOT EXISTS food_vectors (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  calories REAL DEFAULT 0,
  protein REAL DEFAULT 0,
  carbs REAL DEFAULT 0,
  fat REAL DEFAULT 0,
  source TEXT,
  category TEXT,
  preparation TEXT,
  tags TEXT,
  embedding vector(768)  -- Gemini embedding-001 = 768 dimensões
);

-- 3. Índice para filtro por categoria (usado antes da busca vetorial)
CREATE INDEX IF NOT EXISTS food_vectors_category_idx
ON food_vectors (category);

-- 4. Índice para busca por similaridade de cosseno
-- Nota: IVFFlat requer dados na tabela para criar o índice
-- Por isso criamos após a migração dos dados
-- CREATE INDEX food_vectors_embedding_idx ON food_vectors
-- USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- 5. Habilita RLS - leitura pública (dados são públicos)
ALTER TABLE food_vectors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leitura pública de food_vectors"
ON food_vectors FOR SELECT
USING (true);

-- 6. Função para busca semântica com filtro de categoria
CREATE OR REPLACE FUNCTION search_foods(
  query_embedding vector(768),
  match_threshold FLOAT DEFAULT 0.5,
  match_count INT DEFAULT 10,
  filter_category TEXT DEFAULT NULL
)
RETURNS TABLE (
  id TEXT,
  name TEXT,
  calories REAL,
  protein REAL,
  carbs REAL,
  fat REAL,
  source TEXT,
  category TEXT,
  preparation TEXT,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    fv.id,
    fv.name,
    fv.calories,
    fv.protein,
    fv.carbs,
    fv.fat,
    fv.source,
    fv.category,
    fv.preparation,
    1 - (fv.embedding <=> query_embedding) AS similarity
  FROM food_vectors fv
  WHERE
    (filter_category IS NULL OR fv.category = filter_category)
    AND 1 - (fv.embedding <=> query_embedding) > match_threshold
  ORDER BY fv.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- 7. Comentários para documentação
COMMENT ON TABLE food_vectors IS 'Vetores de embedding para busca semântica de alimentos';
COMMENT ON COLUMN food_vectors.embedding IS 'Embedding gerado pelo Gemini embedding-001 (768 dimensões)';
COMMENT ON COLUMN food_vectors.category IS 'Categoria do alimento: ovo, frango, carne_bovina, peixe, arroz, feijao, etc';
COMMENT ON COLUMN food_vectors.preparation IS 'Método de preparo: grelhado, frito, cozido, assado, cru, etc';
COMMENT ON FUNCTION search_foods IS 'Busca semântica de alimentos com filtro opcional por categoria';
