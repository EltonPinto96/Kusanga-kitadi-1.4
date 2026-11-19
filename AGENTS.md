# KUSANGA KITADI — Regras do Projecto

## Visão e Filosofia
- **Plataforma Comunitária:** KUSANGA KITADI ("A força está na ligação. Saiba onde levantar.")
- **Território de Actuação:** Província de Luanda (16 Municípios, Sede: Ingombota) e Província do Icolo e Bengo (7 Municípios, Sede: Catete), de acordo com a Nova Divisão Político-Administrativa de Angola (Lei nº 3/22).
- **Rede Bancária:** Apoio e catálogo de todos os bancos comerciais e de desenvolvimento autorizados pelo Banco Nacional de Angola (BNA).
- **Sem Vínculo Lovable:** Projecto 100% independente, com Vite nativo, TanStack Start, Supabase e deployment directo no Cloudflare Workers / Pages e Android TWA (Bubblewrap).

## Regras de Dados e Interface
- Manter registos de demonstração claramente isolados dos dados reais e visivelmente rotulados, para que nunca sejam confundidos com ATMs verificados.
- O ecrã inicial é público e permite descoberta imediata de caixas automáticos sem exigir autenticação prévia.
- Autenticação necessária apenas para reportes comunitários (disponibilidade de numerário, filas) e gestão de favoritos.
- Apoio directo a login com Conta Google (Google OAuth) e credenciais por email/palavra-passe.
- Reportes comunitários expiram após 2 horas e são auditáveis por administradores e moderadores.

## Regra de Git & Sincronização
- A cada funcionalidade ou conjunto de modificações concluídas, realizar `git add`, `git commit` com mensagem descritiva em português/inglês e `git push origin main`.
