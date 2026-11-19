-- ==============================================================================
-- KUSANGA KITADI v2.0 — MASTER SCRIPT DA NOVA SUPER BASE DE DADOS (SUPABASE)
-- Execute este ficheiro completo uma única vez no Supabase SQL Editor.
-- Contém: Extensões, Tabelas, Índices, Funções PL/pgSQL, Triggers, RLS e Seeds.
-- ==============================================================================

-- 1. EXTENSÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TIPOS ENUM
DO $$ BEGIN
  CREATE TYPE atm_status AS ENUM ('pending', 'approved', 'rejected');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE availability_status AS ENUM ('available', 'no-cash', 'out-of-service', 'uncertain', 'stale');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 3. TABELAS BASE
-- ==============================================================================

-- Províncias
CREATE TABLE IF NOT EXISTS public.provinces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  code TEXT NOT NULL UNIQUE,
  capital TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Municípios (Nova DPA - Lei nº 3/22)
CREATE TABLE IF NOT EXISTS public.municipalities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  province_id UUID NOT NULL REFERENCES public.provinces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  is_capital BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(province_id, name)
);

-- Bancos Comerciais e de Desenvolvimento
CREATE TABLE IF NOT EXISTS public.banks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  short_code TEXT UNIQUE,
  primary_color TEXT,
  website_url TEXT,
  logo_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Perfis de Utilizador (ligados a auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  reputation_points INT DEFAULT 0,
  reports_count INT DEFAULT 0,
  reputation_badge TEXT DEFAULT 'Iniciante',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Funções Administrativas
CREATE TABLE IF NOT EXISTS public.admin_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Funções de Moderação Comunitária
CREATE TABLE IF NOT EXISTS public.moderator_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  email TEXT NOT NULL,
  invited_by UUID REFERENCES auth.users(id),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'pending', 'revoked')),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notificações Administrativas
CREATE TABLE IF NOT EXISTS public.admin_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  user_email TEXT NOT NULL,
  user_name TEXT,
  provider TEXT DEFAULT 'google',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Caixas Automáticos (ATMs)
CREATE TABLE IF NOT EXISTS public.atms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  bank_id UUID NOT NULL REFERENCES public.banks(id) ON DELETE RESTRICT,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  municipality TEXT NOT NULL,
  neighborhood TEXT,
  municipality_id UUID REFERENCES public.municipalities(id) ON DELETE SET NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  maps_url TEXT,
  status atm_status NOT NULL DEFAULT 'pending',
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  approved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reportes Comunitários de Disponibilidade e Filas
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  atm_id UUID NOT NULL REFERENCES public.atms(id) ON DELETE CASCADE,
  availability availability_status NOT NULL,
  notes_available TEXT,
  queue_time TEXT,
  comment TEXT,
  reported_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  confirmed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  source TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Favoritos do Utilizador
CREATE TABLE IF NOT EXISTS public.user_favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  atm_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT user_favorites_user_atm_unique UNIQUE (user_id, atm_id)
);

-- ==============================================================================
-- 4. ÍNDICES DE PERFORMANCE E PESQUISA
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_municipalities_province_id ON public.municipalities (province_id);
CREATE INDEX IF NOT EXISTS idx_provinces_code ON public.provinces (code);
CREATE INDEX IF NOT EXISTS idx_banks_short_code ON public.banks (short_code);
CREATE INDEX IF NOT EXISTS idx_banks_is_active ON public.banks (is_active);
CREATE UNIQUE INDEX IF NOT EXISTS idx_moderator_roles_email ON public.moderator_roles (LOWER(email));
CREATE INDEX IF NOT EXISTS idx_atms_lat_lng ON public.atms (lat, lng);
CREATE INDEX IF NOT EXISTS idx_atms_status ON public.atms (status);
CREATE INDEX IF NOT EXISTS idx_atms_municipality_neighborhood ON public.atms (municipality, neighborhood);
CREATE INDEX IF NOT EXISTS idx_atms_municipality_id ON public.atms (municipality_id);
CREATE INDEX IF NOT EXISTS idx_reports_atm_id ON public.reports (atm_id);
CREATE INDEX IF NOT EXISTS idx_reports_expires_at ON public.reports (expires_at);
CREATE INDEX IF NOT EXISTS idx_reports_atm_created_desc ON public.reports (atm_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_created_desc ON public.reports (reported_by, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON public.user_favorites (user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_atm_id ON public.user_favorites (atm_id);

-- ==============================================================================
-- 5. FUNÇÕES E TRIGGERS DE SEGURANÇA E LÓGICA DE NEGÓCIO
-- ==============================================================================

-- Helper: Verifica se é Admin
CREATE OR REPLACE FUNCTION public.is_admin(target_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_roles WHERE admin_roles.user_id = target_user_id
  );
$$;

-- Helper: Verifica se é Moderador
CREATE OR REPLACE FUNCTION public.is_moderator(target_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.moderator_roles mr
    LEFT JOIN auth.users u ON u.id = target_user_id
    WHERE (mr.user_id = target_user_id OR LOWER(mr.email) = LOWER(u.email))
      AND mr.status = 'active'
  );
$$;

-- Helper: Verifica se pode moderar (Admin ou Moderador)
CREATE OR REPLACE FUNCTION public.can_moderate(target_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT public.is_admin(target_user_id) OR public.is_moderator(target_user_id);
$$;

-- Trigger: Atualização automática de updated_at nos ATMs
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_atms_updated_at ON public.atms;
CREATE TRIGGER trigger_atms_updated_at
  BEFORE UPDATE ON public.atms
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Trigger: Expiração de reportes (padrão 2 horas)
CREATE OR REPLACE FUNCTION public.set_report_expires_at()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.expires_at IS NULL THEN
    NEW.expires_at := NEW.confirmed_at + INTERVAL '2 hours';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_report_expires_at ON public.reports;
CREATE TRIGGER trigger_set_report_expires_at
  BEFORE INSERT OR UPDATE ON public.reports
  FOR EACH ROW EXECUTE FUNCTION public.set_report_expires_at();

-- Trigger: Criação automática de perfil ao registar novo utilizador (Google OAuth ou Email)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      NEW.raw_user_meta_data->>'display_name',
      split_part(NEW.email, '@', 1)
    ),
    COALESCE(
      NEW.raw_user_meta_data->>'avatar_url',
      NEW.raw_user_meta_data->>'picture',
      NULL
    )
  )
  ON CONFLICT (id) DO UPDATE SET
    display_name = COALESCE(EXCLUDED.display_name, public.profiles.display_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger: Notificação interna de novo cadastro para a equipa
CREATE OR REPLACE FUNCTION public.handle_new_user_registration_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.admin_notifications (
    user_id,
    user_email,
    user_name,
    provider,
    created_at,
    read
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      NEW.raw_user_meta_data->>'display_name',
      split_part(NEW.email, '@', 1)
    ),
    COALESCE(NEW.raw_app_meta_data->>'provider', 'google'),
    NOW(),
    false
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_notification ON auth.users;
CREATE TRIGGER on_auth_user_created_notification
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_registration_notification();

-- Trigger Anti-Spam: Limita 1 reporte por utilizador no mesmo ATM a cada 5 minutos
CREATE OR REPLACE FUNCTION public.check_report_rate_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_recent_count INT;
BEGIN
  IF NEW.reported_by IS NOT NULL THEN
    SELECT COUNT(*) INTO v_recent_count
    FROM public.reports
    WHERE atm_id = NEW.atm_id
      AND reported_by = NEW.reported_by
      AND created_at > (NOW() - INTERVAL '5 minutes');

    IF v_recent_count > 0 THEN
      RAISE EXCEPTION 'Aguarde 5 minutos antes de enviar outro reporte para este mesmo caixa.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_check_report_rate_limit ON public.reports;
CREATE TRIGGER trigger_check_report_rate_limit
  BEFORE INSERT ON public.reports
  FOR EACH ROW EXECUTE FUNCTION public.check_report_rate_limit();

-- Trigger de Reputação Comunitária (+5 pontos por reporte confirmado)
CREATE OR REPLACE FUNCTION public.update_user_reputation_on_report()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_new_points INT;
  v_new_badge TEXT;
BEGIN
  IF NEW.reported_by IS NOT NULL THEN
    UPDATE public.profiles
    SET 
      reputation_points = COALESCE(reputation_points, 0) + 5,
      reports_count = COALESCE(reports_count, 0) + 1
    WHERE id = NEW.reported_by
    RETURNING reputation_points INTO v_new_points;

    IF v_new_points >= 100 THEN
      v_new_badge := 'Guardião de Luanda';
    ELSIF v_new_points >= 40 THEN
      v_new_badge := 'Kamba Vigilante';
    ELSIF v_new_points >= 15 THEN
      v_new_badge := 'Colaborador Activo';
    ELSE
      v_new_badge := 'Iniciante';
    END IF;

    UPDATE public.profiles
    SET reputation_badge = v_new_badge
    WHERE id = NEW.reported_by;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_update_user_reputation ON public.reports;
CREATE TRIGGER trigger_update_user_reputation
  AFTER INSERT ON public.reports
  FOR EACH ROW EXECUTE FUNCTION public.update_user_reputation_on_report();

-- Função para calcular status de confiança do ATM
CREATE OR REPLACE FUNCTION public.get_atm_confidence_status(p_atm_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_has_available BOOLEAN := false;
  v_has_no_cash BOOLEAN := false;
  v_latest_status TEXT;
BEGIN
  SELECT 
    BOOL_OR(availability = 'available'),
    BOOL_OR(availability = 'no-cash')
  INTO v_has_available, v_has_no_cash
  FROM public.reports
  WHERE atm_id = p_atm_id
    AND confirmed_at > (NOW() - INTERVAL '45 minutes')
    AND expires_at > NOW();

  IF v_has_available IS TRUE AND v_has_no_cash IS TRUE THEN
    RETURN 'uncertain';
  END IF;

  SELECT availability::text INTO v_latest_status
  FROM public.reports
  WHERE atm_id = p_atm_id
    AND expires_at > NOW()
  ORDER BY confirmed_at DESC
  LIMIT 1;

  RETURN COALESCE(v_latest_status, 'stale');
END;
$$;

-- ==============================================================================
-- 6. POLÍTICAS DE SEGURANÇA (ROW LEVEL SECURITY - RLS)
-- ==============================================================================

ALTER TABLE public.provinces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.municipalities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderator_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.atms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_favorites ENABLE ROW LEVEL SECURITY;

-- Provinces & Municipalities: Leitura pública
CREATE POLICY "provinces_public_read" ON public.provinces FOR SELECT USING (true);
CREATE POLICY "municipalities_public_read" ON public.municipalities FOR SELECT USING (true);

-- Banks: Leitura pública de bancos ativos
CREATE POLICY "banks_public_read" ON public.banks FOR SELECT USING (true);
CREATE POLICY "banks_admin_all" ON public.banks FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Profiles: Leitura pública, update apenas próprio
CREATE POLICY "profiles_public_read" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_own_update" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Admin & Moderator Roles: Apenas admins gerenciam
CREATE POLICY "admin_roles_admin_all" ON public.admin_roles FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "moderator_roles_admin_all" ON public.moderator_roles FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "moderator_roles_self_read" ON public.moderator_roles FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR LOWER(email) = LOWER((SELECT email FROM auth.users WHERE id = auth.uid())));

-- Admin Notifications
CREATE POLICY "admin_notifications_select" ON public.admin_notifications FOR SELECT TO authenticated
  USING (public.can_moderate());
CREATE POLICY "admin_notifications_update" ON public.admin_notifications FOR UPDATE TO authenticated
  USING (public.can_moderate());
CREATE POLICY "admin_notifications_insert" ON public.admin_notifications FOR INSERT WITH CHECK (true);

-- ATMs: Leitura pública dos caixas aprovados (ecrã inicial público sem login obrigatório)
CREATE POLICY "atms_public_read_approved" ON public.atms FOR SELECT USING (status = 'approved');
CREATE POLICY "atms_moderator_read_all" ON public.atms FOR SELECT TO authenticated USING (public.can_moderate());
CREATE POLICY "atms_auth_insert" ON public.atms FOR INSERT TO authenticated WITH CHECK (auth.uid() IS NOT NULL AND status = 'pending' AND created_by = auth.uid());
CREATE POLICY "atms_moderator_update" ON public.atms FOR UPDATE TO authenticated USING (public.can_moderate());
CREATE POLICY "atms_admin_delete" ON public.atms FOR DELETE TO authenticated USING (public.is_admin());

-- Reports: Leitura pública dos reportes ativos (dentro da janela de expiração)
CREATE POLICY "reports_public_read_active" ON public.reports FOR SELECT USING (expires_at > NOW());
CREATE POLICY "reports_moderator_read_all" ON public.reports FOR SELECT TO authenticated USING (public.can_moderate());
CREATE POLICY "reports_auth_insert" ON public.reports FOR INSERT TO authenticated WITH CHECK (auth.uid() IS NOT NULL AND reported_by = auth.uid());
CREATE POLICY "reports_moderator_delete" ON public.reports FOR DELETE TO authenticated USING (public.can_moderate());

-- User Favorites: Exclusivo de cada utilizador
CREATE POLICY "user_favorites_select_own" ON public.user_favorites FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "user_favorites_insert_own" ON public.user_favorites FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "user_favorites_delete_own" ON public.user_favorites FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- ==============================================================================
-- 7. SEED INICIAL — PROVÍNCIAS, MUNICÍPIOS (DPA 2022) E TODOS OS BANCOS
-- ==============================================================================

-- Províncias
INSERT INTO public.provinces (name, code, capital) VALUES
  ('Luanda',        'LUA', 'Ingombota'),
  ('Icolo e Bengo', 'ICB', 'Catete')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, capital = EXCLUDED.capital;

-- 16 Municípios de Luanda (Capital: Ingombota)
INSERT INTO public.municipalities (province_id, name, is_capital)
SELECT p.id, m.name, (m.name = 'Ingombota')
FROM public.provinces p
CROSS JOIN (
  VALUES
    ('Belas'), ('Cacuaco'), ('Camama'), ('Cazenga'),
    ('Hoji-ya-Henda'), ('Ingombota'), ('Kilamba'), ('Kilamba Kiaxi'),
    ('Maianga'), ('Mulenvos'), ('Mussulo'), ('Rangel'),
    ('Samba'), ('Sambizanga'), ('Talatona'), ('Viana')
) AS m(name)
WHERE p.code = 'LUA'
ON CONFLICT (province_id, name) DO NOTHING;

-- 7 Municípios do Icolo e Bengo (Capital: Catete)
INSERT INTO public.municipalities (province_id, name, is_capital)
SELECT p.id, m.name, (m.name = 'Catete')
FROM public.provinces p
CROSS JOIN (
  VALUES
    ('Bom Jesus'), ('Cabiri'), ('Cabo Ledo'), ('Calumbo'),
    ('Catete'), ('Quiçama'), ('Sequele')
) AS m(name)
WHERE p.code = 'ICB'
ON CONFLICT (province_id, name) DO NOTHING;

-- Todos os Bancos Comerciais e de Desenvolvimento de Angola (BNA)
INSERT INTO public.banks (name, short_code, primary_color, website_url, is_active)
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

-- ==============================================================================
-- 8. SEED DE ATMS VERIFICADOS EM LUANDA (PILOTO COM BANCO ATLÂNTICO E BAI)
-- ==============================================================================

INSERT INTO public.atms (
  bank_id,
  name,
  address,
  municipality,
  neighborhood,
  lat,
  lng,
  maps_url,
  status,
  approved_at
)
SELECT
  b.id,
  'ATM Center MDC',
  'Bairro Kicuxi, Avenida Fidel de Castro Ruz - MDC Shopping Via Express',
  'Viana',
  'Kicuxi',
  -8.97402,
  13.35277,
  'https://maps.app.goo.gl/2fayq3ih5s2GgyoX6',
  'approved',
  NOW()
FROM public.banks b
WHERE b.short_code = 'ATLANTICO'
ON CONFLICT DO NOTHING;

INSERT INTO public.atms (
  bank_id,
  name,
  address,
  municipality,
  neighborhood,
  lat,
  lng,
  maps_url,
  status,
  approved_at
)
SELECT
  b.id,
  'Atlântico — Belas Shopping',
  'Belas Shopping Center, Piso 0',
  'Talatona',
  'Talatona',
  -8.9243,
  13.1861,
  'https://maps.google.com/?q=-8.9243,13.1861',
  'approved',
  NOW()
FROM public.banks b
WHERE b.short_code = 'ATLANTICO'
ON CONFLICT DO NOTHING;

INSERT INTO public.atms (
  bank_id,
  name,
  address,
  municipality,
  neighborhood,
  lat,
  lng,
  maps_url,
  status,
  approved_at
)
SELECT
  b.id,
  'BAI — Sede Torre Garden',
  'Rua Major Kanhangulo 212',
  'Ingombota',
  'Ingombota',
  -8.8149,
  13.2341,
  'https://maps.google.com/?q=-8.8149,13.2341',
  'approved',
  NOW()
FROM public.banks b
WHERE b.short_code = 'BAI'
ON CONFLICT DO NOTHING;

INSERT INTO public.atms (
  bank_id,
  name,
  address,
  municipality,
  neighborhood,
  lat,
  lng,
  maps_url,
  status,
  approved_at
)
SELECT
  b.id,
  'BAI — Agência Kinaxixi',
  'Largo do Kinaxixi',
  'Ingombota',
  'Kinaxixi',
  -8.8220,
  13.2277,
  'https://maps.google.com/?q=-8.8220,13.2277',
  'approved',
  NOW()
FROM public.banks b
WHERE b.short_code = 'BAI'
ON CONFLICT DO NOTHING;
