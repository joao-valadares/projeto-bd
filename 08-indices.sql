-- 1. ÍNDICES PARA TABELA DE USUÁRIOS

-- Índice para login (email é único)
CREATE INDEX idx_usuarios_email_ativo 
ON usuarios(email) 
WHERE status_conta = 'ativo';

-- Índice para busca por tipo de usuário
CREATE INDEX idx_usuarios_tipo_status 
ON usuarios(tipo_usuario, status_conta);

-- Índice para último login (relatórios de atividade)
CREATE INDEX idx_usuarios_ultimo_login 
ON usuarios(ultimo_login DESC) 
WHERE ultimo_login IS NOT NULL;


-- 2. ÍNDICES PARA TABELA DE VAGAS

-- Índice composto para busca de vagas abertas
CREATE INDEX idx_vagas_abertas_ativas 
ON vagas(status_vaga, data_expiracao, data_publicacao DESC) 
WHERE status_vaga = 'aberta';

-- Índice para busca por empresa
CREATE INDEX idx_vagas_empresa_status 
ON vagas(id_empresa, status_vaga, data_publicacao DESC);

-- Índice para busca por categoria e localização
CREATE INDEX idx_vagas_categoria_localizacao 
ON vagas(id_categoria, id_localizacao, status_vaga)
WHERE status_vaga = 'aberta';

-- Índice para consultas salariais
CREATE INDEX idx_vagas_salario_nivel 
ON vagas(nivel_experiencia, salario_min, salario_max)
WHERE salario_min IS NOT NULL AND salario_max IS NOT NULL;

-- Índice para modalidade de trabalho
CREATE INDEX idx_vagas_modalidade_publicacao 
ON vagas(modalidade_trabalho, data_publicacao DESC)
WHERE status_vaga = 'aberta';


-- 3. ÍNDICES PARA TABELA DE CANDIDATURAS

-- Índice composto para dashboard do candidato
CREATE INDEX idx_candidaturas_candidato_status 
ON candidaturas(id_candidato, status_candidatura, data_candidatura DESC);

-- Índice composto para dashboard da vaga/empresa
CREATE INDEX idx_candidaturas_vaga_status 
ON candidaturas(id_vaga, status_candidatura, data_candidatura DESC);

-- Índice temporal para relatórios de período
CREATE INDEX idx_candidaturas_data_status 
ON candidaturas(data_candidatura DESC, status_candidatura);

-- Índice para busca de candidaturas únicas
CREATE UNIQUE INDEX idx_candidaturas_unica 
ON candidaturas(id_candidato, id_vaga);


-- 4. ÍNDICES PARA TABELA DE HABILIDADES E RELACIONAMENTOS

-- Índice para busca de habilidades por categoria
CREATE INDEX idx_habilidades_categoria_nome 
ON habilidades(categoria, nome_habilidade);

-- Índice composto para matching de habilidades do candidato
CREATE INDEX idx_candidatos_habilidades_nivel 
ON candidatos_habilidades(id_candidato, nivel_proficiencia, anos_experiencia DESC);

-- Índice para busca de habilidades requeridas por vaga
CREATE INDEX idx_vagas_habilidades_obrigatoria 
ON vagas_habilidades(id_vaga, obrigatoria, nivel_requerido);

-- Índice para análise de demanda por habilidade
CREATE INDEX idx_vagas_habilidades_demanda 
ON vagas_habilidades(id_habilidade, obrigatoria, nivel_requerido);


-- 5. ÍNDICES PARA PROCESSOS SELETIVOS E AVALIAÇÕES

-- Índice para busca de processos por candidatura
CREATE INDEX idx_processos_candidatura_status 
ON processos_seletivos(id_candidatura, status_processo, data_inicio DESC);

-- Índice para busca de processos por etapa atual
CREATE INDEX idx_processos_etapa_data 
ON processos_seletivos(etapa_atual, data_inicio DESC)
WHERE status_processo = 'em_andamento';

-- Índice para avaliações por processo
CREATE INDEX idx_avaliacoes_processo_data 
ON avaliacoes_candidatos(id_processo, data_avaliacao DESC);

-- Índice para avaliações por etapa
CREATE INDEX idx_avaliacoes_etapa_nota 
ON avaliacoes_candidatos(id_etapa, nota DESC, data_avaliacao DESC);


-- 6. ÍNDICES PARA CURRÍCULOS E EXPERIÊNCIAS

-- Índice para busca de currículos atualizados
CREATE INDEX idx_curriculos_atualizacao 
ON curriculos(data_atualizacao DESC);

-- Índice para experiências atuais
CREATE INDEX idx_experiencias_atuais 
ON experiencias_profissionais(id_curriculo, emprego_atual, data_inicio DESC)
WHERE emprego_atual = true;

-- Índice temporal para experiências
CREATE INDEX idx_experiencias_periodo 
ON experiencias_profissionais(data_inicio DESC, data_fim DESC NULLS FIRST);

-- Índice para formações por grau
CREATE INDEX idx_formacoes_grau_conclusao 
ON formacoes_academicas(grau, data_conclusao DESC NULLS FIRST);


-- 7. ÍNDICES PARA SISTEMA DE MENSAGENS E CONEXÕES

-- Índice para mensagens do usuário
CREATE INDEX idx_mensagens_destinatario_lida 
ON mensagens(id_destinatario, lida, data_envio DESC);

CREATE INDEX idx_mensagens_remetente_data 
ON mensagens(id_remetente, data_envio DESC);

-- Índice para conexões por usuário
CREATE INDEX idx_conexoes_solicitante_status 
ON conexoes(id_solicitante, status_conexao, data_conexao DESC);

CREATE INDEX idx_conexoes_receptor_status 
ON conexoes(id_receptor, status_conexao, data_conexao DESC);

-- Índice para análise de networking
CREATE INDEX idx_conexoes_ativas_data 
ON conexoes(status_conexao, data_conexao DESC)
WHERE status_conexao = 'aceita';


-- 9. ÍNDICES PARA LOCALIZAÇÃO E CATEGORIAS

-- Índice para busca geográfica
CREATE INDEX idx_localizacoes_estado_cidade 
ON localizacoes(estado, cidade);

-- Índice para categorias mais buscadas
CREATE INDEX idx_categorias_nome 
ON categorias_vaga(nome_categoria);


