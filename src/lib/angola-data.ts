// ============================================================
// KUSANGA KITADI — Dados de Angola (Nova Divisão Político-Administrativa)
// Província de Luanda (16 Municípios) e Província do Icolo e Bengo (7 Municípios)
// Lista Oficial de Bancos Comerciais de Angola
// ============================================================

export interface ProvinceData {
  code: string
  name: string
  capital: string
  municipalities: string[]
}

export interface BankData {
  name: string
  shortCode: string
  primaryColor: string
  websiteUrl: string
}

// ----------------------------------------------------------------
// Províncias e Municípios de Angola (DPA Actualizada)
// Foco: Província de Luanda (16) e Província do Icolo e Bengo (7)
// ----------------------------------------------------------------

export const ANGOLA_PROVINCES: ProvinceData[] = [
  {
    code: 'LUA',
    name: 'Luanda',
    capital: 'Ingombota',
    municipalities: [
      'Belas',
      'Cacuaco',
      'Camama',
      'Cazenga',
      'Hoji-ya-Henda',
      'Ingombota', // Capital da província de Luanda
      'Kilamba',
      'Kilamba Kiaxi',
      'Maianga',
      'Mulenvos',
      'Mussulo',
      'Rangel',
      'Samba',
      'Sambizanga',
      'Talatona',
      'Viana', // Inclui Zango e arredores
    ],
  },
  {
    code: 'ICB',
    name: 'Icolo e Bengo',
    capital: 'Catete',
    municipalities: [
      'Bom Jesus',
      'Cabiri',
      'Cabo Ledo',
      'Calumbo',
      'Catete', // Capital da província do Icolo e Bengo
      'Quiçama',
      'Sequele',
    ],
  },
]

/** Mapa rápido de code → ProvinceData */
export const PROVINCE_BY_CODE = Object.fromEntries(
  ANGOLA_PROVINCES.map((p) => [p.code, p]),
) as Record<string, ProvinceData>

/** Lista plana de todos os municípios com referência à província */
export const ALL_MUNICIPALITIES = ANGOLA_PROVINCES.flatMap((province) =>
  province.municipalities.map((name) => ({
    name,
    provinceCode: province.code,
    provinceName: province.name,
    isCapital: name === province.capital,
  })),
)

/** Lista com todos os nomes de municípios únicos ordenados */
export const MUNICIPALITY_NAMES = ALL_MUNICIPALITIES.map((m) => m.name).sort()

// ----------------------------------------------------------------
// Lista Completa de Bancos Comerciais e de Desenvolvimento em Angola (BNA)
// ----------------------------------------------------------------

export const ANGOLA_BANKS: BankData[] = [
  { name: 'Banco Angolano de Investimentos',    shortCode: 'BAI',       primaryColor: '#E30613', websiteUrl: 'https://www.bai.ao' },
  { name: 'Banco de Fomento Angola',            shortCode: 'BFA',       primaryColor: '#00529B', websiteUrl: 'https://www.bfa.ao' },
  { name: 'Banco Internacional de Crédito',     shortCode: 'BIC',       primaryColor: '#0066CC', websiteUrl: 'https://www.bic.ao' },
  { name: 'Banco Atlântico',                    shortCode: 'ATLANTICO', primaryColor: '#004B8D', websiteUrl: 'https://www.bancatlantico.ao' },
  { name: 'Millennium Atlântico',               shortCode: 'MATLANT',   primaryColor: '#CE0000', websiteUrl: 'https://www.millenniumatlantico.ao' },
  { name: 'Sol Banco',                          shortCode: 'SOL',       primaryColor: '#F7A800', websiteUrl: 'https://www.solbanco.ao' },
  { name: 'Caixa Angola',                       shortCode: 'CAIXA',     primaryColor: '#004B1C', websiteUrl: 'https://www.caixaangola.ao' },
  { name: 'Banco de Negócios Internacional',    shortCode: 'BNI',       primaryColor: '#1B4F72', websiteUrl: 'https://www.bni.ao' },
  { name: 'Standard Bank de Angola',            shortCode: 'SBA',       primaryColor: '#0033A0', websiteUrl: 'https://www.standardbank.co.ao' },
  { name: 'Banco Económico',                    shortCode: 'BECON',     primaryColor: '#8B0000', websiteUrl: 'https://www.bancoeconomico.ao' },
  { name: 'Banco de Poupança e Crédito',        shortCode: 'BPC',       primaryColor: '#003B70', websiteUrl: 'https://www.bpc.ao' },
  { name: 'Banco de Desenvolvimento de Angola', shortCode: 'BDA',       primaryColor: '#2E6B3E', websiteUrl: 'https://www.bda.ao' },
  { name: 'Banco Yetu',                         shortCode: 'YETU',      primaryColor: '#FF6B00', websiteUrl: 'https://www.bancoyetu.ao' },
  { name: 'Banco Keve',                         shortCode: 'KEVE',      primaryColor: '#006633', websiteUrl: 'https://www.bancokeve.ao' },
  { name: 'Banco de Comércio e Indústria',      shortCode: 'BCI',       primaryColor: '#8B4513', websiteUrl: 'https://www.bci.ao' },
  { name: 'Access Bank Angola',                 shortCode: 'ACCESS',    primaryColor: '#001E62', websiteUrl: 'https://angola.accessbankplc.com' },
  { name: 'Standard Chartered Angola',          shortCode: 'SCB',       primaryColor: '#0E7AC4', websiteUrl: 'https://www.sc.com/ao' },
  { name: 'First National Bank Angola',         shortCode: 'FNB',       primaryColor: '#004B87', websiteUrl: 'https://www.fnbangola.ao' },
  { name: 'Finibanco Angola',                   shortCode: 'FINI',      primaryColor: '#C0392B', websiteUrl: 'https://www.finibanco.ao' },
  { name: 'Banco BAI Microfinanças',            shortCode: 'BAIM',      primaryColor: '#E30613', websiteUrl: 'https://www.baim.ao' },
  { name: 'Banco Valor',                        shortCode: 'VALOR',     primaryColor: '#2C3E50', websiteUrl: 'https://www.bancovalor.ao' },
  { name: 'Banco Prestígio',                    shortCode: 'PREST',     primaryColor: '#6B2D8B', websiteUrl: 'https://www.bancoprestigio.ao' },
  { name: 'Banco VTB África',                   shortCode: 'VTB',       primaryColor: '#002882', websiteUrl: 'https://www.vtb.ao' },
  { name: 'Banco Comercial do Huambo',          shortCode: 'BCH',       primaryColor: '#165B33', websiteUrl: 'https://www.bch.ao' },
]

/** Nomes de todos os bancos para selects */
export const BANK_NAMES = ANGOLA_BANKS.map((b) => b.name).sort()

/** Mapa rápido de shortCode → BankData */
export const BANK_BY_SHORT_CODE = Object.fromEntries(
  ANGOLA_BANKS.map((b) => [b.shortCode, b]),
) as Record<string, BankData>
