# VORTEX

ERP/PDV premium multiempresa para cafeterias e operações de alimentação.

## Estado atual

Este repositório está em migração do backend Apps Script/Google Sheets para Supabase/PostgreSQL, com a **UI/UX atual preservada como contrato visual**.

### Regra de importação da planilha

A planilha de referência foi utilizada **somente para descobrir tabelas e colunas**. Nenhuma linha de dados da cliente é importada nesta fundação.

## Estrutura planejada

- `frontend/` — interface web Vortex
- `supabase/migrations/` — schema, RLS, RPCs e evolução do banco
- `supabase/functions/` — integrações sensíveis/fiscais
- `bridge/` — VortexBridge.exe para hardware local
- `docs/` — arquitetura e mapeamentos

Veja `docs/ARCHITECTURE.md` e `docs/legacy-sheet-schema.md`.
