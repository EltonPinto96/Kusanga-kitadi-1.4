// scripts/seed-real-atms.mjs
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const SUPABASE_URL = process.env.VITE_SUPABASE_URL || 'https://knepzlvnyyupxspkmexv.supabase.co';
const SUPABASE_KEY = process.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_IpFNLMjdTbHngWpLmEnp8w_H-mT3hxR';

const headers = {
  'apikey': SUPABASE_KEY,
  'Authorization': `Bearer ${SUPABASE_KEY}`,
  'Content-Type': 'application/json',
  'Prefer': 'return=minimal'
};

const REAL_ATMS = [
  // Banco Atlântico
  {
    name: 'Atlântico — Aeroporto 4 de Fevereiro',
    bankMatch: 'Atlântico',
    address: 'Terminal de Chegadas do Aeroporto Internacional 4 de Fevereiro',
    municipality: 'Maianga',
    neighborhood: 'Aeroporto',
    lat: -8.8583,
    lng: 13.2311,
    maps_url: 'https://maps.google.com/?q=-8.8583,13.2311',
  },
  {
    name: 'Atlântico — Cidade Financeira',
    bankMatch: 'Atlântico',
    address: 'Via AL1, Talatona, Edifício Cidade Financeira Bloco 2',
    municipality: 'Talatona',
    neighborhood: 'Cidade Financeira',
    lat: -8.9288,
    lng: 13.1905,
    maps_url: 'https://maps.google.com/?q=-8.9288,13.1905',
  },
  {
    name: 'Atlântico — Agência Mutamba',
    bankMatch: 'Atlântico',
    address: 'Rua Rainha Ginga, Largo da Mutamba',
    municipality: 'Ingombota',
    neighborhood: 'Mutamba',
    lat: -8.8131,
    lng: 13.2325,
    maps_url: 'https://maps.google.com/?q=-8.8131,13.2325',
  },
  // BAI
  {
    name: 'BAI — Agência Talatona',
    bankMatch: 'BAI',
    address: 'Via Expressa Sul / Av. Talatona, junto ao SIAC',
    municipality: 'Talatona',
    neighborhood: 'Talatona',
    lat: -8.9177,
    lng: 13.1883,
    maps_url: 'https://maps.google.com/?q=-8.9177,13.1883',
  },
  {
    name: 'BAI — Agência Viana Centro',
    bankMatch: 'BAI',
    address: 'Estrada de Catete, Km 12, Próximo à Administração Municipal',
    municipality: 'Viana',
    neighborhood: 'Viana Centro',
    lat: -8.9042,
    lng: 13.3721,
    maps_url: 'https://maps.google.com/?q=-8.9042,13.3721',
  },
  {
    name: 'BAI — Aeroporto Doméstico',
    bankMatch: 'BAI',
    address: 'Aeroporto 4 de Fevereiro, Terminal Doméstico',
    municipality: 'Maianga',
    neighborhood: 'Aeroporto',
    lat: -8.8569,
    lng: 13.2335,
    maps_url: 'https://maps.google.com/?q=-8.8569,13.2335',
  },
  // BFA
  {
    name: 'BFA — Sede Avenida 4 de Fevereiro',
    bankMatch: 'BFA',
    address: 'Avenida 4 de Fevereiro 113, Marginal de Luanda',
    municipality: 'Ingombota',
    neighborhood: 'Baixa / Marginal',
    lat: -8.8095,
    lng: 13.2367,
    maps_url: 'https://maps.google.com/?q=-8.8095,13.2367',
  },
  {
    name: 'BFA — Agência Morro Bento',
    bankMatch: 'BFA',
    address: 'Avenida 21 de Janeiro, Morro Bento',
    municipality: 'Samba',
    neighborhood: 'Morro Bento',
    lat: -8.8821,
    lng: 13.2104,
    maps_url: 'https://maps.google.com/?q=-8.8821,13.2104',
  },
  {
    name: 'BFA — Kilamba Central',
    bankMatch: 'BFA',
    address: 'Centralidade do Kilamba, Quarteirão B, Edifício B12',
    municipality: 'Kilamba',
    neighborhood: 'Quarteirão B',
    lat: -8.9952,
    lng: 13.2588,
    maps_url: 'https://maps.google.com/?q=-8.9952,13.2588',
  },
  {
    name: 'BFA — Cazenga Cuca',
    bankMatch: 'BFA',
    address: 'Estrada de Deolinda Rodrigues, junto à antiga Cuca',
    municipality: 'Cazenga',
    neighborhood: 'Hoji-ya-Henda',
    lat: -8.8351,
    lng: 13.2792,
    maps_url: 'https://maps.google.com/?q=-8.8351,13.2792',
  },
  // Banco BIC
  {
    name: 'BIC — Sede Luanda Baixa',
    bankMatch: 'BIC',
    address: 'Rua Amílcar Cabral 58',
    municipality: 'Ingombota',
    neighborhood: 'Mutamba',
    lat: -8.8164,
    lng: 13.2309,
    maps_url: 'https://maps.google.com/?q=-8.8164,13.2309',
  },
  {
    name: 'BIC — Agência Maculusso',
    bankMatch: 'BIC',
    address: 'Rua Frederico Welwitsch, Maculusso',
    municipality: 'Ingombota',
    neighborhood: 'Maculusso',
    lat: -8.8239,
    lng: 13.2355,
    maps_url: 'https://maps.google.com/?q=-8.8239,13.2355',
  },
  {
    name: 'BIC — Cacuaco Vila',
    bankMatch: 'BIC',
    address: 'Estrada Nacional 100, Vila de Cacuaco',
    municipality: 'Cacuaco',
    neighborhood: 'Cacuaco Vila',
    lat: -8.7812,
    lng: 13.3645,
    maps_url: 'https://maps.google.com/?q=-8.7812,13.3645',
  },
  // BPC
  {
    name: 'BPC — Agência Central Mutamba',
    bankMatch: 'BPC',
    address: 'Avenida 4 de Fevereiro / Largo Saydi Mingas',
    municipality: 'Ingombota',
    neighborhood: 'Mutamba',
    lat: -8.8118,
    lng: 13.2338,
    maps_url: 'https://maps.google.com/?q=-8.8118,13.2338',
  },
  {
    name: 'BPC — São Paulo',
    bankMatch: 'BPC',
    address: 'Largo de São Paulo, Bairro São Paulo',
    municipality: 'Sambizanga',
    neighborhood: 'São Paulo',
    lat: -8.8189,
    lng: 13.2541,
    maps_url: 'https://maps.google.com/?q=-8.8189,13.2541',
  },
  // Banco Sol
  {
    name: 'Sol — Sede Talatona',
    bankMatch: 'Sol',
    address: 'Rua do Centro de Convenções de Talatona',
    municipality: 'Talatona',
    neighborhood: 'Talatona',
    lat: -8.9212,
    lng: 13.1934,
    maps_url: 'https://maps.google.com/?q=-8.9212,13.1934',
  },
  {
    name: 'Sol — Rangel Terra Nova',
    bankMatch: 'Sol',
    address: 'Avenida Deolinda Rodrigues, Paragem da Terra Nova',
    municipality: 'Rangel',
    neighborhood: 'Terra Nova',
    lat: -8.8283,
    lng: 13.2612,
    maps_url: 'https://maps.google.com/?q=-8.8283,13.2612',
  },
  // Standard Bank Angola
  {
    name: 'Standard Bank — Edifício Sky One',
    bankMatch: 'Standard Bank',
    address: 'Rua Marechal Brós Tito 35, Sky One',
    municipality: 'Ingombota',
    neighborhood: 'Kinaxixi',
    lat: -8.8188,
    lng: 13.2318,
    maps_url: 'https://maps.google.com/?q=-8.8188,13.2318',
  },
  // Banco Keve
  {
    name: 'Keve — Agência Palanca',
    bankMatch: 'Keve',
    address: 'Avenida Pedro de Castro Van-Dúnem Loy, Palanca',
    municipality: 'Kilamba Kiaxi',
    neighborhood: 'Palanca',
    lat: -8.8694,
    lng: 13.2678,
    maps_url: 'https://maps.google.com/?q=-8.8694,13.2678',
  },
  // Icolo e Bengo (Catete)
  {
    name: 'BPC — Agência Catete Sede',
    bankMatch: 'BPC',
    address: 'Estrada Nacional 230, Vila de Catete',
    municipality: 'Catete',
    neighborhood: 'Catete Centro',
    lat: -9.1311,
    lng: 13.7022,
    maps_url: 'https://maps.google.com/?q=-9.1311,13.7022',
  },
  {
    name: 'BFA — Agência Bom Jesus',
    bankMatch: 'BFA',
    address: 'Estrada do Polo Industrial de Bom Jesus',
    municipality: 'Bom Jesus',
    neighborhood: 'Polo Industrial',
    lat: -9.1602,
    lng: 13.5654,
    maps_url: 'https://maps.google.com/?q=-9.1602,13.5654',
  }
];

async function main() {
  console.log('🔍 A carregar bancos do Supabase...');
  const banksRes = await fetch(`${SUPABASE_URL}/rest/v1/banks?select=id,name,short_code`, { headers });
  const banks = await banksRes.json();

  console.log('🔍 A carregar municípios...');
  const munsRes = await fetch(`${SUPABASE_URL}/rest/v1/municipalities?select=id,name`, { headers });
  const muns = await munsRes.json();
  const munMap = new Map(muns.map(m => [m.name.toLowerCase(), m.id]));

  console.log(`🏦 ${banks.length} bancos e ${muns.length} municípios carregados.`);

  let inserted = 0;
  for (const atm of REAL_ATMS) {
    const bank = banks.find(b => 
      b.name.toLowerCase().includes(atm.bankMatch.toLowerCase()) || 
      (b.short_code && b.short_code.toLowerCase() === atm.bankMatch.toLowerCase())
    );

    if (!bank) {
      console.warn(`⚠️ Banco não encontrado para: ${atm.bankMatch}`);
      continue;
    }

    const municipalityId = munMap.get(atm.municipality.toLowerCase()) || null;

    // Verificar se já existe
    const checkRes = await fetch(`${SUPABASE_URL}/rest/v1/atms?name=eq.${encodeURIComponent(atm.name)}&select=id`, { headers });
    const existing = await checkRes.json();

    if (existing && existing.length > 0) {
      continue;
    }

    const payload = {
      bank_id: bank.id,
      name: atm.name,
      address: atm.address,
      municipality: atm.municipality,
      neighborhood: atm.neighborhood,
      municipality_id: municipalityId,
      lat: atm.lat,
      lng: atm.lng,
      maps_url: atm.maps_url,
      status: 'approved',
      approved_at: new Date().toISOString()
    };

    const insertRes = await fetch(`${SUPABASE_URL}/rest/v1/atms`, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload)
    });

    if (insertRes.ok) {
      inserted++;
      console.log(`✅ [${atm.municipality}] ${atm.name}`);
    } else {
      console.error(`❌ Erro ao inserir ${atm.name}:`, await insertRes.text());
    }
  }

  console.log(`\n🎉 Total de novos ATMs reais inseridos: ${inserted}`);

  // Verificar contagem final
  const countRes = await fetch(`${SUPABASE_URL}/rest/v1/atms?select=id`, { headers });
  const total = await countRes.json();
  console.log(`📍 Total de ATMs aprovados na base de dados: ${total.length}`);
}

main().catch(console.error);
