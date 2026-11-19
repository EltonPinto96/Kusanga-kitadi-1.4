-- ============================================================
-- KUSANGA KITADI — Províncias e Municípios de Angola (DPA Actualizada)
-- Província de Luanda (16 Municípios, Sede: Ingombota)
-- Província do Icolo e Bengo (7 Municípios, Sede: Catete)
-- Migration: 009_provinces_municipalities.sql
-- ============================================================

-- ============================================================
-- TABELAS
-- ============================================================

CREATE TABLE IF NOT EXISTS provinces (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL UNIQUE,
  code       TEXT NOT NULL UNIQUE,
  capital    TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS municipalities (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  province_id UUID NOT NULL REFERENCES provinces(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  is_capital  BOOLEAN NOT NULL DEFAULT false,
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
-- DADOS — Províncias
-- Luanda (Capital: Ingombota) e Icolo e Bengo (Capital: Catete)
-- ============================================================

INSERT INTO provinces (name, code, capital) VALUES
  ('Luanda',        'LUA', 'Ingombota'),
  ('Icolo e Bengo', 'ICB', 'Catete')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  capital = EXCLUDED.capital;

-- ============================================================
-- DADOS — Província de Luanda (16 Municípios)
-- Sede (capital): Município da Ingombota
-- 1. Belas, 2. Cacuaco, 3. Camama, 4. Cazenga, 5. Hoji-ya-Henda,
-- 6. Ingombota (Capital), 7. Kilamba, 8. Kilamba Kiaxi, 9. Maianga,
-- 10. Mulenvos, 11. Mussulo, 12. Rangel, 13. Samba, 14. Sambizanga,
-- 15. Talatona, 16. Viana (inclui Zango)
-- ============================================================

INSERT INTO municipalities (province_id, name, is_capital)
SELECT p.id, m.name, (m.name = 'Ingombota')
FROM provinces p
CROSS JOIN (
  VALUES
    ('Belas'),
    ('Cacuaco'),
    ('Camama'),
    ('Cazenga'),
    ('Hoji-ya-Henda'),
    ('Ingombota'),
    ('Kilamba'),
    ('Kilamba Kiaxi'),
    ('Maianga'),
    ('Mulenvos'),
    ('Mussulo'),
    ('Rangel'),
    ('Samba'),
    ('Sambizanga'),
    ('Talatona'),
    ('Viana')
) AS m(name)
WHERE p.code = 'LUA'
ON CONFLICT (province_id, name) DO NOTHING;

-- ============================================================
-- DADOS — Província do Icolo e Bengo (7 Municípios)
-- Sede (capital): Município de Catete
-- 1. Bom Jesus, 2. Cabiri, 3. Cabo Ledo, 4. Calumbo,
-- 5. Catete (Capital), 6. Quiçama, 7. Sequele
-- ============================================================

INSERT INTO municipalities (province_id, name, is_capital)
SELECT p.id, m.name, (m.name = 'Catete')
FROM provinces p
CROSS JOIN (
  VALUES
    ('Bom Jesus'),
    ('Cabiri'),
    ('Cabo Ledo'),
    ('Calumbo'),
    ('Catete'),
    ('Quiçama'),
    ('Sequele')
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
