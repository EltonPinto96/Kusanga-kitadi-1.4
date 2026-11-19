# KUSANGA KITADI — A força está na ligação. Saiba onde levantar. 🇦🇴

Plataforma comunitária angolana para localização em tempo real de caixas automáticos (ATM / Multicaixa) e monitorização colaborativa de notas disponíveis e filas em Luanda e Icolo e Bengo.

---

## 🗺️ Cobertura Territorial (Nova Divisão Administrativa de Angola)

### 📍 Província de Luanda (16 Municípios)
- **Sede (Capital Provincial):** Ingombota
- **Municípios:** Belas, Cacuaco, Camama, Cazenga, Hoji-ya-Henda, **Ingombota**, Kilamba, Kilamba Kiaxi, Maianga, Mulenvos, Mussulo, Rangel, Samba, Sambizanga, Talatona, Viana (inclui Zango).

### 📍 Província do Icolo e Bengo (7 Municípios)
- **Sede (Capital Provincial):** Catete
- **Municípios:** Bom Jesus, Cabiri, Cabo Ledo, Calumbo, **Catete**, Quiçama, Sequele.

---

## 🏦 Bancos Suportados (Rede Multicaixa / BNA)
BAI, BFA, BIC, Banco Atlântico, Millennium Atlântico, Sol Banco, Caixa Angola, BNI, Standard Bank de Angola, Banco Económico, BPC, BDA, Banco Yetu, Banco Keve, BCI, Access Bank Angola, Standard Chartered Angola, FNB Angola, Finibanco, BAI Microfinanças, Banco Valor, Banco Prestígio, Banco VTB África e Banco Comercial do Huambo.

---

## ⚡ Tecnologias

- **Frontend:** React 19, TypeScript, TanStack Start, TanStack Query, Tailwind CSS v4, Lucide Icons, Leaflet / OpenStreetMap
- **Backend & Autenticação:** Supabase (PostgreSQL, Row Level Security, Google OAuth, Triggers e Funções PL/pgSQL)
- **Infraestrutura Web:** Cloudflare Workers (SSR nativo com Nitro)
- **Aplicação Android:** Trusted Web Activity (TWA) com Bubblewrap CLI e Digital Asset Links

---

## 🚀 Instalação e Desenvolvimento Local

```sh
# Instalar dependências
npm install

# Iniciar servidor de desenvolvimento (porta 3000)
npm run dev

# Compilar para produção
npm run build

# Publicar no Cloudflare Workers
npm run deploy
```

---

## 📱 Google OAuth & Configurações
Consulta o guia detalhado em [GOOGLE_OAUTH_SETUP.md](file:///docs/GOOGLE_OAUTH_SETUP.md).

## ☁️ Guia de Publicação Cloudflare & Android TWA
Consulta o guia detalhado em [CLOUDFLARE_DEPLOY.md](file:///docs/CLOUDFLARE_DEPLOY.md).
