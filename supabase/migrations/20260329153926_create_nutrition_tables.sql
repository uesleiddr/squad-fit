-- ============================================
-- Migration: Tabelas para Nutricionista Inteligente
-- ============================================

-- 1. Adicionar campo calorie_goal na tabela users
ALTER TABLE users
ADD COLUMN IF NOT EXISTS calorie_goal INTEGER DEFAULT 2000;

-- ============================================
-- 2. Criar tabela meal_entries (refeições)
-- ============================================
CREATE TABLE IF NOT EXISTS meal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  description TEXT NOT NULL,
  total_calories INTEGER NOT NULL DEFAULT 0,
  total_protein DECIMAL(8,2) DEFAULT 0,
  total_carbs DECIMAL(8,2) DEFAULT 0,
  total_fat DECIMAL(8,2) DEFAULT 0,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS para meal_entries
ALTER TABLE meal_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meals" ON meal_entries
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meals" ON meal_entries
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meals" ON meal_entries
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meals" ON meal_entries
  FOR DELETE USING (auth.uid() = user_id);

-- Index para consultas por data
CREATE INDEX IF NOT EXISTS idx_meal_entries_user_date
ON meal_entries(user_id, recorded_at);

-- ============================================
-- 3. Criar tabela meal_items (itens da refeição)
-- ============================================
CREATE TABLE IF NOT EXISTS meal_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_entry_id UUID NOT NULL REFERENCES meal_entries(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity DECIMAL(8,2) NOT NULL DEFAULT 1,
  unit TEXT DEFAULT 'porção',
  calories INTEGER NOT NULL DEFAULT 0,
  protein DECIMAL(8,2) DEFAULT 0,
  carbs DECIMAL(8,2) DEFAULT 0,
  fat DECIMAL(8,2) DEFAULT 0,
  fatsecret_food_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS para meal_items
ALTER TABLE meal_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meal items" ON meal_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own meal items" ON meal_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own meal items" ON meal_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own meal items" ON meal_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );

-- Index para buscar itens de uma refeição
CREATE INDEX IF NOT EXISTS idx_meal_items_entry
ON meal_items(meal_entry_id);
