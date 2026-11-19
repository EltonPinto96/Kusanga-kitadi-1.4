# Deploy Cloudflare Workers — Kusanga Kitadi

Guia completo para fazer o deploy da aplicação Kusanga Kitadi no Cloudflare Workers, incluindo a versão Android via TWA (Trusted Web Activity) com Bubblewrap.

---

## Pré-requisitos

- Node.js 18+
- npm (incluído com Node.js)
- Conta Cloudflare com Workers e Pages activados
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/) (instalado automaticamente via npx)

---

## Build e Deploy Web (Cloudflare Workers)

### 1. Instalar dependências

```bash
npm install
```

### 2. Build da aplicação

```bash
npm run build
```

O output será gerado em `.output/`:
- `.output/server/index.mjs` — Worker server entry point
- `.output/public/` — Assets estáticos

### 3. Autenticar no Cloudflare

```bash
npx wrangler login
```

Abre o browser para autenticação. Após login, as credenciais ficam guardadas localmente.

### 4. Deploy

```bash
npm run deploy
```

Ou manualmente:

```bash
npx wrangler deploy
```

### 5. Deploy rápido (build + deploy)

```bash
npm run deploy
```

### 6. Deploy em modo preview

```bash
npm run deploy:preview
```

---

## URL de Produção

```
https://kusanga-kitadi.eltonpintoprinceso.workers.dev
```

---

## Configurar Secrets no Cloudflare

As variáveis de ambiente sensíveis devem ser configuradas como secrets (não ficam no código):

```bash
npx wrangler secret put VITE_SUPABASE_URL
# Introduzir o valor quando solicitado

npx wrangler secret put VITE_SUPABASE_ANON_KEY
# Introduzir o valor quando solicitado
```

Alternativamente, configurar no **Cloudflare Dashboard**:
1. Aceder a [dash.cloudflare.com](https://dash.cloudflare.com)
2. Workers & Pages → `kusanga-kitadi`
3. Settings → Variables and Secrets
4. Adicionar `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`

---

## Estrutura do wrangler.json

```json
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "kusanga-kitadi",
  "main": ".output/server/index.mjs",
  "compatibility_date": "2024-11-01",
  "compatibility_flags": ["nodejs_compat"],
  "assets": {
    "binding": "ASSETS",
    "directory": ".output/public"
  },
  "vars": {
    "VITE_SUPABASE_URL": "",
    "VITE_SUPABASE_ANON_KEY": ""
  }
}
```

> **Nota:** Os valores de `vars` em `wrangler.json` são placeholders. Os valores reais devem ser configurados via `wrangler secret put` ou no dashboard.

---

## Deploy Android — TWA com Bubblewrap

A aplicação Android é gerada como TWA (Trusted Web Activity) a partir da PWA web.

### Pré-requisitos Android

- Java Development Kit (JDK) 8 ou superior
- Android SDK (Android Studio recomendado)
- Keystore para assinar o APK

### 1. Instalar Bubblewrap CLI

```bash
npm install -g @bubblewrap/cli
```

### 2. Inicializar projecto TWA

```bash
bubblewrap init --manifest https://kusanga-kitadi.eltonpintoprinceso.workers.dev/manifest.json
```

O Bubblewrap lê o `manifest.json` da PWA e configura automaticamente:
- Package ID: `ao.kusangakitadi.app`
- Nome: `Kusanga Kitadi`
- Cores, ícones e orientação do manifest

### 3. Build do APK

```bash
bubblewrap build
```

O APK assinado será gerado em:
```
./app-release-signed.apk
```

### 4. Testar o APK

```bash
# Instalar num dispositivo/emulador Android conectado via USB
adb install app-release-signed.apk
```

---

## Configurar Digital Asset Links (assetlinks.json)

Para que a TWA funcione correctamente sem barra de endereço, o servidor web deve verificar a identidade do app Android via Digital Asset Links.

### 1. Obter o SHA-256 do keystore

```bash
keytool -list -v -keystore android.keystore -alias kusanga-kitadi
```

Copiar o valor `SHA256:` da saída.

### 2. Actualizar public/.well-known/assetlinks.json

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "ao.kusangakitadi.app",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:EE:FF:..." 
      ]
    }
  }
]
```

> Substituir `AA:BB:CC:DD:EE:FF:...` pelo SHA-256 real do keystore.

### 3. Verificar a configuração

Após o deploy, verificar em:
```
https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://kusanga-kitadi.eltonpintoprinceso.workers.dev
```

Ou usando a ferramenta oficial:
```
https://developers.google.com/digital-asset-links/tools/generator
```

---

## CI/CD (Opcional)

Para automatizar o deploy via GitHub Actions:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Cloudflare Workers

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm install
      - run: npm run build
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

Configurar `CLOUDFLARE_API_TOKEN` em GitHub → Settings → Secrets.

---

## Troubleshooting

| Problema | Solução |
|---------|---------|
| `Missing entry-point` | Verificar que `npm run build` correu com sucesso e `.output/` existe |
| `Error: No route matched` | Verificar `assets.directory` no `wrangler.json` |
| TWA mostra barra de endereço | Verificar `assetlinks.json` e SHA-256 do keystore |
| Build falha em CI | Garantir que `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` estão como secrets |
| `wrangler login` falha | Usar `CLOUDFLARE_API_TOKEN` como variável de ambiente em vez de login interactivo |
