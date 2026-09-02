# Roadmap de migração Vortex

## Fase 0 — Baseline
- congelar UI atual como referência visual
- manter fonte legada arquivada
- adicionar testes visuais antes do redesign (redesign não faz parte da migração)

## Fase 1 — Banco
- schema legado de referência sem dados
- schema relacional Vortex
- Auth, Organizations, Units
- RLS e permission engine

## Fase 2 — Frontend
- remover dependência de `google.script.run`
- introduzir `VortexAPI`
- preservar HTML/CSS/UX 1:1

## Fase 3 — Operação multiusuário
- múltiplos usuários
- múltiplos terminais
- múltiplos caixas simultâneos
- mesas, comandas, garçom e autorização gerencial
- 10% opcional e gorjetas por CPF do garçom

## Fase 4 — KDS / produção / estoque
- estações de produção
- realtime
- fichas técnicas
- perdas e auditoria

## Fase 5 — White-label
- Vortex como marca do produto
- logo/ícone por cliente
- Theme Engine e paletas

## Fase 6 — Vortex Bridge
- multi-impressora
- gaveta
- múltiplos terminais de pagamento
- adapters Getnet/PagBank conforme SDK/protocolo suportado

## Fase 7 — Fiscal
- NFC-e/NF-e legítimas via provedor compatível
- status fiscal persistente
- DANFE/impressão/e-mail
- fidelidade no comprovante complementar
