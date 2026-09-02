# Vortex — arquitetura alvo

## Princípios

1. **UI/UX atual é contrato visual.** A migração backend não autoriza redesign.
2. **PostgreSQL é a autoridade de dados.** Nada de lógica contábil baseada em strings soltas.
3. **RLS isola organizações/unidades.** Botões escondidos são UX, não segurança.
4. **RPCs transacionais executam operações compostas.** Venda, cancelamento, fechamento de caixa e estoque precisam ser atômicos.
5. **Bridge controla hardware local.** Impressoras, gaveta, Bluetooth/COM/TEF não ficam no navegador.
6. **Fiscal é integração separada.** Emissão legítima usa provedor/SEFAZ; Bridge apenas imprime.

## Camadas

```text
Frontend Vortex (UI atual preservada)
        |
        +--> Supabase Auth
        +--> Supabase PostgreSQL + RLS
        +--> Supabase RPC / Edge Functions
        +--> Supabase Realtime
        +--> Supabase Storage (logos/ícones)
        |
        +--> localhost --> VortexBridge.exe --> hardware
```

## Multiempresa

Uma única aplicação Vortex atende várias organizações. Todas as entidades operacionais carregam `organization_id` e, quando aplicável, `unit_id`.

## Branding

Cada organização possui logo, ícone e tokens de tema próprios. O frontend carrega o branding depois de resolver o tenant/slug.

## Estado da migração

A planilha enviada foi usada somente para estruturar o modelo legado de referência. Nenhuma linha foi importada.
