# Configuração Google OAuth — Kusanga Kitadi

Este guia descreve como configurar o Google OAuth para o projecto Kusanga Kitadi, usando Supabase como backend de autenticação.

---

## Pré-requisitos

- Conta Google (para aceder ao Google Cloud Console)
- Acesso ao Supabase Dashboard do projecto
- URL de produção: `https://kusanga-kitadi.eltonpintoprinceso.workers.dev`

---

## Passo 1 — Criar Projecto no Google Cloud

1. Aceder a [https://console.cloud.google.com](https://console.cloud.google.com)
2. No menu superior, clicar em **"Seleccionar projecto"** → **"Novo projecto"**
3. Nome do projecto: `Kusanga Kitadi`
4. Clicar em **"Criar"**
5. Aguardar a criação e seleccionar o projecto recém-criado

---

## Passo 2 — Activar a Google Identity API

1. No painel do projecto, ir a **"APIs e serviços"** → **"Biblioteca"**
2. Pesquisar por **"Google Identity"** ou **"Google+ API"**
3. Seleccionar **"Google Identity Toolkit API"** e clicar em **"Activar"**
4. Também activar **"People API"** (para acesso ao perfil)

---

## Passo 3 — Configurar Ecrã de Consentimento OAuth

1. Ir a **"APIs e serviços"** → **"Ecrã de consentimento OAuth"**
2. Escolher tipo: **"Externo"** (para utilizadores fora da organização)
3. Preencher os campos obrigatórios:
   - **Nome da app:** `Kusanga Kitadi`
   - **Email de suporte do utilizador:** *(o teu email)*
   - **Domínios autorizados:** `kusanga-kitadi.eltonpintoprinceso.workers.dev`
   - **Contactos de email do programador:** *(o teu email)*
4. Clicar em **"Guardar e continuar"**
5. Nos escopos, adicionar:
   - `email`
   - `profile`
   - `openid`
6. Guardar e continuar até ao fim

---

## Passo 4 — Criar Credenciais OAuth 2.0 Client ID

1. Ir a **"APIs e serviços"** → **"Credenciais"**
2. Clicar em **"+ Criar credenciais"** → **"ID de cliente OAuth 2.0"**
3. Tipo de aplicação: **"Aplicação Web"**
4. Nome: `Kusanga Kitadi Web`

### Origens JavaScript autorizadas:
```
http://localhost:3000
https://kusanga-kitadi.eltonpintoprinceso.workers.dev
```

### URIs de redireccionamento autorizados:
```
https://[SUPABASE_PROJECT_REF].supabase.co/auth/v1/callback
```
> **Substituir `[SUPABASE_PROJECT_REF]`** pelo identificador do projecto Supabase (visível no URL do dashboard, ex: `abcdefghijklmnop`).

5. Clicar em **"Criar"**
6. Copiar o **Client ID** e o **Client Secret** gerados

---

## Passo 5 — Configurar no Supabase Dashboard

1. Aceder ao [Supabase Dashboard](https://supabase.com/dashboard)
2. Seleccionar o projecto Kusanga Kitadi
3. Ir a **"Authentication"** → **"Providers"**
4. Encontrar **"Google"** e clicar em **"Enable"**
5. Colar o **Client ID** e **Client Secret** obtidos no passo anterior
6. Em **"Redirect URL"**, verificar que está:
   ```
   https://[SUPABASE_PROJECT_REF].supabase.co/auth/v1/callback
   ```
7. Clicar em **"Save"**

---

## Passo 6 — Verificação

Após a configuração, testar o fluxo:

1. Abrir a aplicação em `https://kusanga-kitadi.eltonpintoprinceso.workers.dev`
2. Clicar em **"Continuar com o Google"** no modal de autenticação
3. Deve abrir o ecrã de consentimento do Google
4. Após autorizar, o utilizador deve ficar autenticado na aplicação

### Em desenvolvimento local:
- Aceder a `http://localhost:3000`
- O fluxo OAuth deve funcionar com o URI de redireccionamento Supabase
- Certifica-te que `http://localhost:3000` está nas origens JavaScript autorizadas no Google Cloud

---

## Notas de Segurança

- **Nunca** colocar o Client Secret directamente no código da aplicação frontend
- O Client Secret deve ser configurado apenas no Supabase Dashboard
- As variáveis `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` são públicas e seguras para o frontend
- O fluxo OAuth é gerido inteiramente pelo Supabase (intermediário seguro)

---

## Troubleshooting

| Erro | Solução |
|------|---------|
| `redirect_uri_mismatch` | Verificar que o URI de callback do Supabase está nas URIs autorizadas do Google |
| `Error 400: invalid_client` | Client ID ou Secret incorrectos no Supabase Dashboard |
| Popup bloqueado | O utilizador deve permitir popups para o domínio, ou usar redirect flow |
| `OAuth provider not enabled` | Activar o provider Google no Supabase Dashboard |
