-- ============================================================
-- KUSANGA KITADI — Todos os Bancos de Angola
-- Migration: 010_all_angola_banks.sql
-- ============================================================

-- ============================================================
-- EXPANDIR TABELA banks — novas colunas
-- ============================================================

ALTER TABLE banks
  ADD COLUMN IF NOT EXISTS short_code    TEXT,
  ADD COLUMN IF NOT EXISTS primary_color TEXT,
  ADD COLUMN IF NOT EXISTS website_url   TEXT,
  ADD COLUMN IF NOT EXISTS is_active     BOOLEAN NOT NULL DEFAULT true;

-- Índice na sigla para lookups rápidos
CREATE UNIQUE INDEX IF NOT EXISTS idx_banks_short_code
  ON banks (short_code)
  WHERE short_code IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_banks_is_active
  ON banks (is_active);

-- ============================================================
-- EXPANDIR TABELA atms — updated_at com auto-update trigger
-- ============================================================

ALTER TABLE atms
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Trigger para auto-update de updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_atms_updated_at ON atms;
CREATE TRIGGER trigger_atms_updated_at
  BEFORE UPDATE ON atms
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- INSERT — Todos os Bancos Existentes em Angola (Lista Oficial BNA)
-- ============================================================

INSERT INTO banks (name, short_code, primary_color, website_url, is_active)
VALUES
  ('Banco Angolano de Investimentos',   'BAI',       '#E30613', 'https://www.bai.ao',                   true),
  ('Banco de Fomento Angola',           'BFA',       '#00529B', 'https://www.bfa.ao',                   true),
  ('Banco Internacional de Crédito',    'BIC',       '#0066CC', 'https://www.bic.ao',                   true),
  ('Banco Atlântico',                   'ATLANTICO', '#004B8D', 'https://www.bancatlantico.ao',          true),
  ('Millennium Atlântico',              'MATLANT',   '#CE0000', 'https://www.millenniumatlantico.ao',    true),
  ('Sol Banco',                         'SOL',       '#F7A800', 'https://www.solbanco.ao',               true),
  ('Caixa Angola',                      'CAIXA',     '#004B1C', 'https://www.caixaangola.ao',            true),
  ('Banco de Negócios Internacional',   'BNI',       '#1B4F72', 'https://www.bni.ao',                   true),
  ('Standard Bank de Angola',           'SBA',       '#0033A0', 'https://www.standardbank.co.ao',       true),
  ('Banco Económico',                   'BECON',     '#8B0000', 'https://www.bancoeconomico.ao',         true),
  ('Banco de Poupança e Crédito',       'BPC',       '#003B70', 'https://www.bpc.ao',                   true),
  ('Banco de Desenvolvimento de Angola','BDA',       '#2E6B3E', 'https://www.bda.ao',                   true),
  ('Banco Yetu',                        'YETU',      '#FF6B00', 'https://www.bancoyetu.ao',              true),
  ('Banco Keve',                        'KEVE',      '#006633', 'https://www.bancokeve.ao',              true),
  ('Banco de Comércio e Indústria',     'BCI',       '#8B4513', 'https://www.bci.ao',                   true),
  ('Access Bank Angola',                'ACCESS',    '#001E62', 'https://angola.accessbankplc.com',     true),
  ('Standard Chartered Angola',         'SCB',       '#0E7AC4', 'https://www.sc.com/ao',                true),
  ('First National Bank Angola',        'FNB',       '#004B87', 'https://www.fnbangola.ao',             true),
  ('Finibanco Angola',                  'FINI',      '#C0392B', 'https://www.finibanco.ao',              true),
  ('Banco BAI Microfinanças',           'BAIM',      '#E30613', 'https://www.baim.ao',                  true),
  ('Banco Valor',                       'VALOR',     '#2C3E50', 'https://www.bancovalor.ao',             true),
  ('Banco Prestígio',                   'PREST',     '#6B2D8B', 'https://www.bancoprestigio.ao',         true),
  ('Banco VTB África',                  'VTB',       '#002882', 'https://www.vtb.ao',                   true),
  ('Banco Comercial do Huambo',         'BCH',       '#165B33', 'https://www.bch.ao',                   true)
ON CONFLICT (name) DO UPDATE SET
  short_code    = EXCLUDED.short_code,
  primary_color = EXCLUDED.primary_color,
  website_url   = EXCLUDED.website_url,
  is_active     = EXCLUDED.is_active;
