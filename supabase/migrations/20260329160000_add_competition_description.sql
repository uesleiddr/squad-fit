-- ============================================
-- Adiciona coluna description em competitions
-- ============================================
-- Esta migration adiciona a coluna description que estava faltando
-- Criada em: 2026-03-29
-- ============================================

ALTER TABLE competitions ADD COLUMN IF NOT EXISTS description TEXT;
