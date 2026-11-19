-- ==============================================================================
-- KUSANGA KITADI v2.0 — SEED DE ATMS VERIFICADOS EM LUANDA E ICOLO E BENGO
-- Execute este script no SQL Editor do Supabase para adicionar mais caixas verificados.
-- ==============================================================================

INSERT INTO public.atms (
  bank_id,
  name,
  address,
  municipality,
  neighborhood,
  municipality_id,
  lat,
  lng,
  maps_url,
  status,
  approved_at
)
SELECT
  b.id,
  d.name,
  d.address,
  d.municipality,
  d.neighborhood,
  m.id AS municipality_id,
  d.lat,
  d.lng,
  d.maps_url,
  'approved'::atm_status,
  NOW()
FROM (
  VALUES
    -- Banco Atlântico
    ('ATLANTICO', 'Atlântico — Aeroporto 4 de Fevereiro', 'Terminal de Chegadas do Aeroporto Internacional', 'Maianga', 'Aeroporto', -8.8583, 13.2311, 'https://maps.google.com/?q=-8.8583,13.2311'),
    ('ATLANTICO', 'Atlântico — Cidade Financeira', 'Via AL1, Talatona, Edifício Cidade Financeira Bloco 2', 'Talatona', 'Cidade Financeira', -8.9288, 13.1905, 'https://maps.google.com/?q=-8.9288,13.1905'),
    ('ATLANTICO', 'Atlântico — Agência Mutamba', 'Rua Rainha Ginga, Largo da Mutamba', 'Ingombota', 'Mutamba', -8.8131, 13.2325, 'https://maps.google.com/?q=-8.8131,13.2325'),

    -- BAI
    ('BAI', 'BAI — Agência Talatona', 'Via Expressa Sul / Av. Talatona, junto ao SIAC', 'Talatona', 'Talatona', -8.9177, 13.1883, 'https://maps.google.com/?q=-8.9177,13.1883'),
    ('BAI', 'BAI — Agência Viana Centro', 'Estrada de Catete, Km 12, Próximo à Administração Municipal', 'Viana', 'Viana Centro', -8.9042, 13.3721, 'https://maps.google.com/?q=-8.9042,13.3721'),
    ('BAI', 'BAI — Aeroporto Doméstico', 'Aeroporto 4 de Fevereiro, Terminal Doméstico', 'Maianga', 'Aeroporto', -8.8569, 13.2335, 'https://maps.google.com/?q=-8.8569,13.2335'),

    -- BFA
    ('BFA', 'BFA — Sede Avenida 4 de Fevereiro', 'Avenida 4 de Fevereiro 113, Marginal de Luanda', 'Ingombota', 'Baixa / Marginal', -8.8095, 13.2367, 'https://maps.google.com/?q=-8.8095,13.2367'),
    ('BFA', 'BFA — Agência Morro Bento', 'Avenida 21 de Janeiro, Morro Bento', 'Samba', 'Morro Bento', -8.8821, 13.2104, 'https://maps.google.com/?q=-8.8821,13.2104'),
    ('BFA', 'BFA — Kilamba Central', 'Centralidade do Kilamba, Quarteirão B, Edifício B12', 'Kilamba', 'Quarteirão B', -8.9952, 13.2588, 'https://maps.google.com/?q=-8.9952,13.2588'),
    ('BFA', 'BFA — Cazenga Cuca', 'Estrada de Deolinda Rodrigues, junto à antiga Cuca', 'Cazenga', 'Hoji-ya-Henda', -8.8351, 13.2792, 'https://maps.google.com/?q=-8.8351,13.2792'),

    -- Banco BIC
    ('BIC', 'BIC — Sede Luanda Baixa', 'Rua Amílcar Cabral 58', 'Ingombota', 'Mutamba', -8.8164, 13.2309, 'https://maps.google.com/?q=-8.8164,13.2309'),
    ('BIC', 'BIC — Agência Maculusso', 'Rua Frederico Welwitsch, Maculusso', 'Ingombota', 'Maculusso', -8.8239, 13.2355, 'https://maps.google.com/?q=-8.8239,13.2355'),
    ('BIC', 'BIC — Cacuaco Vila', 'Estrada Nacional 100, Vila de Cacuaco', 'Cacuaco', 'Cacuaco Vila', -8.7812, 13.3645, 'https://maps.google.com/?q=-8.7812,13.3645'),

    -- BPC
    ('BPC', 'BPC — Agência Central Mutamba', 'Avenida 4 de Fevereiro / Largo Saydi Mingas', 'Ingombota', 'Mutamba', -8.8118, 13.2338, 'https://maps.google.com/?q=-8.8118,13.2338'),
    ('BPC', 'BPC — São Paulo', 'Largo de São Paulo, Bairro São Paulo', 'Sambizanga', 'São Paulo', -8.8189, 13.2541, 'https://maps.google.com/?q=-8.8189,13.2541'),

    -- Banco Sol
    ('SOL', 'Sol — Sede Talatona', 'Rua do Centro de Convenções de Talatona', 'Talatona', 'Talatona', -8.9212, 13.1934, 'https://maps.google.com/?q=-8.9212,13.1934'),
    ('SOL', 'Sol — Rangel Terra Nova', 'Avenida Deolinda Rodrigues, Paragem da Terra Nova', 'Rangel', 'Terra Nova', -8.8283, 13.2612, 'https://maps.google.com/?q=-8.8283,13.2612'),

    -- Standard Bank de Angola
    ('SBA', 'Standard Bank — Edifício Sky One', 'Rua Marechal Brós Tito 35, Sky One', 'Ingombota', 'Kinaxixi', -8.8188, 13.2318, 'https://maps.google.com/?q=-8.8188,13.2318'),

    -- Banco Keve
    ('KEVE', 'Keve — Agência Palanca', 'Avenida Pedro de Castro Van-Dúnem Loy, Palanca', 'Kilamba Kiaxi', 'Palanca', -8.8694, 13.2678, 'https://maps.google.com/?q=-8.8694,13.2678'),

    -- Província do Icolo e Bengo (Catete e Bom Jesus)
    ('BPC', 'BPC — Agência Catete Sede', 'Estrada Nacional 230, Vila de Catete', 'Catete', 'Catete Centro', -9.1311, 13.7022, 'https://maps.google.com/?q=-9.1311,13.7022'),
    ('BFA', 'BFA — Agência Bom Jesus', 'Estrada do Polo Industrial de Bom Jesus', 'Bom Jesus', 'Polo Industrial', -9.1602, 13.5654, 'https://maps.google.com/?q=-9.1602,13.5654')
) AS d(bank_code, name, address, municipality, neighborhood, lat, lng, maps_url)
JOIN public.banks b ON b.short_code = d.bank_code
LEFT JOIN public.municipalities m ON LOWER(m.name) = LOWER(d.municipality)
WHERE NOT EXISTS (
  SELECT 1 FROM public.atms a WHERE a.name = d.name
);
