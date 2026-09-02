-- VORTEX — estrutura legada de referência
-- Fonte: DOC-20260901-WA0127.xlsx
-- IMPORTANTE: esta migration cria SOMENTE tabelas/colunas. Nenhum dado da planilha é inserido.

create schema if not exists legacy;

create table if not exists legacy.tb_insumos (
  id_insumo bigint,
  nome_insumo text,
  unidade_compra text,
  custo_total numeric(14,4),
  custo_kg_l numeric(18,8),
  custo_100g_ml numeric(18,8),
  estoque_atual numeric(18,4),
  qt_embalagem numeric(18,4),
  custo_embalagem numeric(14,4),
  estoque_minimo numeric(18,4)
);

create table if not exists legacy.lixeira (
  id bigint,
  dados text,
  data timestamptz,
  payload jsonb
);

create table if not exists legacy.tb_caixa (
  id_turno bigint,
  data_abertura timestamptz,
  fundo_inicial numeric(14,2),
  data_fechamento timestamptz,
  total_vendas numeric(14,2),
  diferenca_caixa numeric(14,2),
  status text,
  valor_esperado numeric(14,2),
  valor_contado numeric(14,2),
  historico_status text
);

create table if not exists legacy.tb_comandas (
  id_comanda bigint,
  data_abertura timestamptz,
  numero_mesa integer,
  itens_json jsonb,
  total_parcial numeric(14,2),
  status text
);

create table if not exists legacy.tb_clientes (
  id_cliente bigint,
  telefone text,
  nome text,
  pontos_fidelidade numeric(14,2),
  data_cadastro timestamptz
);

create table if not exists legacy.tb_perdas (
  id bigint,
  data timestamptz,
  produto text,
  qtd_descartada numeric(18,4),
  motivo text
);

create table if not exists legacy.tb_fornecedores (
  id bigint,
  razao_social text,
  cnpj_cpf text,
  telefone text,
  pix text,
  ativo text
);

create table if not exists legacy.tb_historico_compras (
  id bigint,
  data timestamptz,
  id_fornecedor bigint,
  nome_insumo text,
  quantidade numeric(18,4),
  valor_total numeric(14,2),
  ativo text
);

create table if not exists legacy.tb_bebidas (
  id bigint,
  nome text,
  qtd_emb numeric(18,4),
  unidade text,
  custo numeric(14,4),
  preco numeric(14,2),
  estoque numeric(18,4)
);

create table if not exists legacy.tb_producao (
  id_lote bigint,
  data_producao timestamptz,
  produto text,
  qtd_produzida numeric(18,4),
  custo_lote numeric(14,4),
  vencimento date,
  status text
);

create table if not exists legacy.tb_encomendas (
  id_encomenda bigint,
  data_registro timestamptz,
  cliente_nome text,
  cliente_telefone text,
  data_entrega date,
  hora_entrega time,
  itens_pedido text,
  valor_bolo numeric(14,2),
  taxa_entrega numeric(14,2),
  motoboy text,
  total numeric(14,2),
  status_pagamento text,
  status_entrega text,
  origem text
);

create table if not exists legacy.tb_contas_pagar (
  id_conta bigint,
  descricao text,
  categoria text,
  valor numeric(14,2),
  vencimento date,
  status text,
  data_pagamento date
);

create table if not exists legacy.tb_contas_receber (
  id_conta bigint,
  cliente text,
  valor numeric(14,2),
  vencimento date,
  status text,
  data_recebimento date
);

create table if not exists legacy.tb_usuarios (
  id_usuario bigint,
  nome text,
  login text,
  senha text,
  perfil text,
  status text
);

create table if not exists legacy.tb_produtos (
  id bigint,
  nome_produto text,
  categoria text,
  preco_venda numeric(14,2),
  status text,
  rendimento numeric(18,4),
  validade_dias integer,
  tipo_producao text
);

create table if not exists legacy.tb_ficha_tecnica (
  id_relacao bigint,
  id_produto bigint,
  id_insumo bigint,
  qtd_utilizada numeric(18,6)
);

create table if not exists legacy.tb_financeiro (
  id_transacao bigint,
  data_hora timestamptz,
  tipo_movimento text,
  valor_total numeric(14,2),
  descricao_lote text
);

create table if not exists legacy.tb_vendas (
  id bigint,
  data_hora timestamptz,
  itens_vendidos text,
  valor_total numeric(14,2),
  ticket_medio numeric(14,2),
  descricao_pagamento_fidelidade text,
  id_turno bigint
);

create table if not exists legacy.tb_custos_fixos (
  id bigint,
  descricao text,
  valor numeric(14,2)
);

create table if not exists legacy.tb_configuracoes (
  chave text,
  valor text
);

create table if not exists legacy.tb_categorias (
  categorias text
);

create table if not exists legacy.tb_historico_metricas (
  id bigint,
  data_hora timestamptz,
  meta_salario numeric(14,2),
  horas_mensais numeric(12,2),
  eficiencia numeric(12,4),
  perda_insumos numeric(12,4)
);

create table if not exists legacy.tb_tempo_produtos (
  id_produto bigint,
  minutos_preparo numeric(12,2)
);

create table if not exists legacy.tb_movimentacoes_caixa (
  id bigint,
  data_hora timestamptz,
  id_turno bigint,
  tipo text,
  valor numeric(14,2),
  motivo text,
  status text
);

comment on schema legacy is 'Estrutura de referência do Google Sheets legado. Nenhuma linha de dados da cliente foi importada.';
