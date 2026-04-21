-- ============================================
-- Migration: Corrige dimensão dos vetores de 768 para 3072
-- ============================================
-- O Gemini embedding-001 gera 3072 dimensões, não 768.
-- ============================================

-- 1. Remove a tabela existente (se tiver)
DROP TABLE IF EXISTS food_vectors;

-- 2. Recria com a dimensão correta
CREATE TABLE food_vectors (
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
  embedding vector(3072)  -- Gemini embedding-001 = 3072 dimensões
);

-- 3. Índice para filtro por categoria
CREATE INDEX food_vectors_category_idx
ON food_vectors (category);

-- 4. Habilita RLS - leitura pública
ALTER TABLE food_vectors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leitura pública de food_vectors"
ON food_vectors FOR SELECT
USING (true);

-- 5. Atualiza a função de busca para 3072 dimensões
CREATE OR REPLACE FUNCTION search_foods(
  query_embedding vector(3072),
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

-- 6. Comentários
COMMENT ON TABLE food_vectors IS 'Vetores de embedding para busca semântica de alimentos';
COMMENT ON COLUMN food_vectors.embedding IS 'Embedding gerado pelo Gemini embedding-001 (3072 dimensões)';
