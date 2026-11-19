-- ============================================================
-- ATM KOTA — Províncias e Municípios de Angola (Lei nº 3/22, 2022)
-- Migration: 009_provinces_municipalities.sql
-- ============================================================

-- ============================================================
-- TABELAS
-- ============================================================

CREATE TABLE IF NOT EXISTS provinces (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL UNIQUE,
  code       TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS municipalities (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  province_id UUID NOT NULL REFERENCES provinces(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(province_id, name)
);

-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_municipalities_province_id
  ON municipalities (province_id);

CREATE INDEX IF NOT EXISTS idx_provinces_code
  ON provinces (code);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE provinces     ENABLE ROW LEVEL SECURITY;
ALTER TABLE municipalities ENABLE ROW LEVEL SECURITY;

-- Leitura pública
CREATE POLICY "provinces_public_read"
  ON provinces FOR SELECT
  USING (true);

CREATE POLICY "municipalities_public_read"
  ON municipalities FOR SELECT
  USING (true);

-- Write apenas admins
CREATE POLICY "provinces_admin_insert"
  ON provinces FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "provinces_admin_update"
  ON provinces FOR UPDATE
  USING (is_admin());

CREATE POLICY "provinces_admin_delete"
  ON provinces FOR DELETE
  USING (is_admin());

CREATE POLICY "municipalities_admin_insert"
  ON municipalities FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "municipalities_admin_update"
  ON municipalities FOR UPDATE
  USING (is_admin());

CREATE POLICY "municipalities_admin_delete"
  ON municipalities FOR DELETE
  USING (is_admin());

-- ============================================================
-- DADOS — Províncias (Lei nº 3/22 de 2022)
-- Luanda e Icolo e Bengo (nova província autónoma)
-- ============================================================

INSERT INTO provinces (name, code) VALUES
  ('Luanda',        'LUA'),
  ('Icolo e Bengo', 'ICB')
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- DADOS — Municípios de Luanda
-- Após a Lei 3/22, Luanda ficou com 7 municípios
-- (Icolo e Bengo separou-se como província autónoma)
-- ============================================================

INSERT INTO municipalities (province_id, name)
SELECT p.id, m.name
FROM provinces p
CROSS JOIN (
  VALUES
    ('Luanda'),
    ('Viana'),
    ('Cacuaco'),
    ('Cazenga'),
    ('Belas'),
    ('Kilamba Kiaxi'),
    ('Quissama')
) AS m(name)
WHERE p.code = 'LUA'
ON CONFLICT (province_id, name) DO NOTHING;

-- ============================================================
-- DADOS — Municípios de Icolo e Bengo
-- Nova província criada pela Lei nº 3/22 de 2022
-- ============================================================

INSERT INTO municipalities (province_id, name)
SELECT p.id, m.name
FROM provinces p
CROSS JOIN (
  VALUES
    ('Icolo e Bengo'),
    ('Catete'),
    ('Cabiri'),
    ('Funda'),
    ('Zenza do Itombe'),
    ('Calumbo')
) AS m(name)
WHERE p.code = 'ICB'
ON CONFLICT (province_id, name) DO NOTHING;

-- ============================================================
-- ALTERAÇÃO À TABELA atms — adicionar municipality_id
-- ============================================================

ALTER TABLE atms
  ADD COLUMN IF NOT EXISTS municipality_id UUID REFERENCES municipalities(id);

CREATE INDEX IF NOT EXISTS idx_atms_municipality_id
  ON atms (municipality_id);
