# Estrutura de referência — planilha legada

Fonte: `DOC-20260901-WA0127.xlsx`.

**Regra desta migração:** somente nomes de tabelas/abas e colunas foram usados. Nenhuma linha de dados da cliente é importada.

## Tabelas identificadas

| Aba original | Colunas de referência |
|---|---|
| `tb_Insumos` | `ID_Insumo`, `Nome_Insumo`, `Unidade_Compra`, `Custo_Total`, `Custo_KG_L`, `Custo_100g_ml`, `Estoque_Atual`, `Qt_Embalagem`, `Custo_Embalagem`, `Estoque_Minimo` |
| `Lixeira` | `ID`, `Dados`, `Data`, `Payload` |
| `tb_Caixa` | `ID_Turno`, `Data_Abertura`, `Fundo_Inicial`, `Data_Fechamento`, `Total_Vendas`, `Diferenca_Caixa`, `Status`, `ValorEsperado`, `ValorContado`, `HistoricoStatus` |
| `tb_Comandas` | `ID_Comanda`, `DataAbertura`, `NumeroMesa`, `ItensJSON`, `TotalParcial`, `Status` |
| `tb_Clientes` | `ID_Cliente`, `Telefone`, `Nome`, `PontosFidelidade`, `DataCadastro` |
| `tb_Perdas` | `ID`, `Data`, `Produto`, `Qtd Descartada`, `Motivo` |
| `tb_Fornecedores` | `ID`, `Razao_Social`, `CNPJ_CPF`, `Telefone`, `PIX`, `Ativo` |
| `tb_Historico_Compras` | `ID`, `Data`, `ID_Fornecedor`, `Nome_Insumo`, `Quantidade`, `Valor_Total`, `Ativo` |
| `tb_Bebidas` | `ID`, `Nome`, `Qtd_Emb`, `Unidade`, `Custo`, `Preco`, `Estoque` |
| `tb_Producao` | `ID_Lote`, `Data_Producao`, `Produto`, `Qtd_Produzida`, `Custo_Lote`, `Vencimento`, `Status` |
| `tb_Encomendas` | `ID_Encomenda`, `Data_Registro`, `Cliente_Nome`, `Cliente_Telefone`, `Data_Entrega`, `Hora_Entrega`, `Itens_Pedido`, `Valor_Bolo`, `Taxa_Entrega`, `Motoboy`, `Total`, `Status_Pagamento`, `Status_Entrega`, `Origem (WhatsApp/Local)` |
| `tb_Contas_Pagar` | `ID_Conta`, `Descricao`, `Categoria`, `Valor`, `Vencimento`, `Status (PAGO/ABERTO)`, `Data_Pagamento` |
| `tb_Contas_Receber` | `ID_Conta`, `Cliente`, `Valor`, `Vencimento`, `Status`, `Data_Recebimento` |
| `tb_Usuarios` | `ID_Usuario`, `Nome`, `Login`, `Senha`, `Perfil`, `Status` |
| `tb_Produtos` | `ID`, `Nome_Produto`, `Categoria`, `Preço_Venda`, `Status`, **coluna 6 sem cabeçalho**, **coluna 7 sem cabeçalho**, `Tipo_Producao` |
| `tb_Ficha_Tecnica` | `ID_Relacao`, `ID_Produto`, `ID_Insumo`, `Qtd_Utilizada` |
| `tb_Financeiro` | `ID_Transacao`, `Data_Hora`, `Tipo_Movimento`, `Valor_Total`, `Descricao_Lote` |
| `tb_Vendas` | `ID`, `Data_Hora`, `Itens_Vendidos`, `Valor_Total`, `Ticket_Medio`, **coluna 6 sem cabeçalho**, **coluna 7 sem cabeçalho** |
| `tb_CustosFixos` | `ID`, `Descrição`, `Valor` |
| `tb_Configuracoes` | `Chave`, `Valor` |
| `tb_Categorias` | `CATEGORIAS` |
| `tb_HistoricoMetricas` | `ID`, `DataHora`, `MetaSalario`, `HorasMensais`, `Eficiencia`, `PerdaInsumos` |
| `tb_TempoProdutos` | `ID_Produto`, `MinutosPreparo` |

## Colunas sem cabeçalho resolvidas pelo código atual

O código atual documenta `tb_Produtos` assim:

- coluna 6: `Rendimento`
- coluna 7: `Validade` (dias)
- coluna 8: `Tipo_Producao`

O fluxo atual de vendas grava `tb_Vendas` com sete campos:

- `ID`
- `Data_Hora`
- `Itens_Vendidos`
- `Valor_Total`
- `Ticket_Medio`
- `Descricao_Pagamento_Fidelidade`
- `ID_Turno`

O código atual também cria automaticamente uma tabela não presente na planilha enviada:

- `tb_Movimentacoes_Caixa`: `ID`, `DataHora`, `IDTurno`, `Tipo`, `Valor`, `Motivo`, `Status`

## Abas de apoio não migradas como tabelas operacionais

- `teste`: sem estrutura/headers.
- `HospedagemImagens`: sem estrutura tabular; no Vortex imagens serão armazenadas no Supabase Storage.
- `apoio_Grafico`: planilha auxiliar de gráfico, substituída por consultas/views no PostgreSQL.

## Observação de segurança

A coluna legada `Senha` existe apenas como referência estrutural. O Vortex não reutilizará senhas em texto puro; autenticação será feita pelo Supabase Auth e os perfis de aplicação referenciarão `auth.users.id`.
