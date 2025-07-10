-- ============================================================================
-- SISTEMA DE RECRUTAMENTO - ÍNDICES PARA OTIMIZAÇÃO
-- Banco de Dados: PostgreSQL
-- Descrição: Criação de índices para otimizar as consultas do sistema
-- ============================================================================

-- ============================================================================
-- ANÁLISE ANTES DA CRIAÇÃO DE ÍNDICES
-- ============================================================================

-- Verifica índices existentes (apenas chaves primárias e únicas por padrão)
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- ============================================================================
-- 1. ÍNDICES PARA TABELA DE USUÁRIOS
-- Justificativa: Login frequente e busca por tipo de usuário
-- ============================================================================

-- Índice para login (email é único, mas otimiza busca com senha)
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

COMMENT ON INDEX idx_usuarios_email_ativo IS 'Otimiza login de usuários ativos';
COMMENT ON INDEX idx_usuarios_tipo_status IS 'Otimiza consultas por tipo e status de usuário';
COMMENT ON INDEX idx_usuarios_ultimo_login IS 'Otimiza relatórios de atividade de usuários';

-- ============================================================================
-- 2. ÍNDICES PARA TABELA DE VAGAS
-- Justificativa: Consultas mais críticas do sistema
-- ============================================================================

-- Índice composto para busca de vagas abertas (consulta mais comum)
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

-- Índice para modalidade de trabalho (tendência crescente)
CREATE INDEX idx_vagas_modalidade_publicacao 
ON vagas(modalidade_trabalho, data_publicacao DESC)
WHERE status_vaga = 'aberta';

COMMENT ON INDEX idx_vagas_abertas_ativas IS 'Otimiza busca principal de vagas abertas';
COMMENT ON INDEX idx_vagas_empresa_status IS 'Otimiza consultas de vagas por empresa';
COMMENT ON INDEX idx_vagas_categoria_localizacao IS 'Otimiza busca por categoria e localização';
COMMENT ON INDEX idx_vagas_salario_nivel IS 'Otimiza consultas de análise salarial';
COMMENT ON INDEX idx_vagas_modalidade_publicacao IS 'Otimiza análise de modalidades de trabalho';

-- ============================================================================
-- 3. ÍNDICES PARA TABELA DE CANDIDATURAS
-- Justificativa: Volume alto de transações e consultas de status
-- ============================================================================

-- Índice composto para dashboard do candidato
CREATE INDEX idx_candidaturas_candidato_status 
ON candidaturas(id_candidato, status_candidatura, data_candidatura DESC);

-- Índice composto para dashboard da vaga/empresa
CREATE INDEX idx_candidaturas_vaga_status 
ON candidaturas(id_vaga, status_candidatura, data_candidatura DESC);

-- Índice temporal para relatórios de período
CREATE INDEX idx_candidaturas_data_status 
ON candidaturas(data_candidatura DESC, status_candidatura);

-- Índice para busca de candidaturas únicas (evita duplicatas)
CREATE UNIQUE INDEX idx_candidaturas_unica 
ON candidaturas(id_candidato, id_vaga);

COMMENT ON INDEX idx_candidaturas_candidato_status IS 'Otimiza dashboard do candidato';
COMMENT ON INDEX idx_candidaturas_vaga_status IS 'Otimiza dashboard da empresa/vaga';
COMMENT ON INDEX idx_candidaturas_data_status IS 'Otimiza relatórios temporais';
COMMENT ON INDEX idx_candidaturas_unica IS 'Garante unicidade e otimiza verificação de duplicatas';

-- ============================================================================
-- 4. ÍNDICES PARA TABELA DE HABILIDADES E RELACIONAMENTOS
-- Justificativa: Consultas de matching e compatibilidade
-- ============================================================================

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

COMMENT ON INDEX idx_habilidades_categoria_nome IS 'Otimiza busca de habilidades por categoria';
COMMENT ON INDEX idx_candidatos_habilidades_nivel IS 'Otimiza matching de habilidades do candidato';
COMMENT ON INDEX idx_vagas_habilidades_obrigatoria IS 'Otimiza busca de requisitos da vaga';
COMMENT ON INDEX idx_vagas_habilidades_demanda IS 'Otimiza análise de demanda por habilidades';

-- ============================================================================
-- 5. ÍNDICES PARA PROCESSOS SELETIVOS E AVALIAÇÕES
-- Justificativa: Acompanhamento de processos em tempo real
-- ============================================================================

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

COMMENT ON INDEX idx_processos_candidatura_status IS 'Otimiza consultas de processo por candidatura';
COMMENT ON INDEX idx_processos_etapa_data IS 'Otimiza consultas de processos em andamento';
COMMENT ON INDEX idx_avaliacoes_processo_data IS 'Otimiza busca de avaliações por processo';
COMMENT ON INDEX idx_avaliacoes_etapa_nota IS 'Otimiza análise de avaliações por etapa';

-- ============================================================================
-- 6. ÍNDICES PARA CURRÍCULOS E EXPERIÊNCIAS
-- Justificativa: Busca de perfis e análise de experiências
-- ============================================================================

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

COMMENT ON INDEX idx_curriculos_atualizacao IS 'Otimiza busca de currículos por atualização';
COMMENT ON INDEX idx_experiencias_atuais IS 'Otimiza busca de empregos atuais';
COMMENT ON INDEX idx_experiencias_periodo IS 'Otimiza consultas temporais de experiência';
COMMENT ON INDEX idx_formacoes_grau_conclusao IS 'Otimiza busca de formações por grau';

-- ============================================================================
-- 7. ÍNDICES PARA SISTEMA DE MENSAGENS E CONEXÕES
-- Justificativa: Funcionalidades de networking e comunicação
-- ============================================================================

-- Índice para mensagens do usuário (recebidas e enviadas)
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

COMMENT ON INDEX idx_mensagens_destinatario_lida IS 'Otimiza caixa de entrada de mensagens';
COMMENT ON INDEX idx_mensagens_remetente_data IS 'Otimiza mensagens enviadas';
COMMENT ON INDEX idx_conexoes_solicitante_status IS 'Otimiza conexões enviadas pelo usuário';
COMMENT ON INDEX idx_conexoes_receptor_status IS 'Otimiza conexões recebidas pelo usuário';
COMMENT ON INDEX idx_conexoes_ativas_data IS 'Otimiza análise de networking';

-- ============================================================================
-- 8. ÍNDICES PARA HISTÓRICO E AUDITORIA
-- Justificativa: Consultas de auditoria e rastreamento
-- ============================================================================

-- Índice para histórico por tabela e registro
CREATE INDEX idx_historico_tabela_registro 
ON historico_status(tabela_origem, id_registro, data_mudanca DESC);

-- Índice temporal para auditoria
CREATE INDEX idx_historico_data_usuario 
ON historico_status(data_mudanca DESC, id_usuario_responsavel);

-- Índice por status para análise de tendências
CREATE INDEX idx_historico_status_novo_data 
ON historico_status(status_novo, data_mudanca DESC);

COMMENT ON INDEX idx_historico_tabela_registro IS 'Otimiza consultas de histórico por registro';
COMMENT ON INDEX idx_historico_data_usuario IS 'Otimiza auditoria temporal';
COMMENT ON INDEX idx_historico_status_novo_data IS 'Otimiza análise de mudanças de status';

-- ============================================================================
-- 9. ÍNDICES PARA LOCALIZAÇÃO E CATEGORIAS
-- Justificativa: Filtros geográficos e categóricos frequentes
-- ============================================================================

-- Índice para busca geográfica
CREATE INDEX idx_localizacoes_estado_cidade 
ON localizacoes(estado, cidade);

-- Índice para categorias mais buscadas
CREATE INDEX idx_categorias_nome 
ON categorias_vaga(nome_categoria);

COMMENT ON INDEX idx_localizacoes_estado_cidade IS 'Otimiza busca geográfica';
COMMENT ON INDEX idx_categorias_nome IS 'Otimiza busca por categoria';

-- ============================================================================
-- 10. ÍNDICES PARCIAIS PARA OTIMIZAÇÕES ESPECÍFICAS
-- Justificativa: Otimização de consultas específicas das views e queries
-- ============================================================================

-- Índice parcial para candidatos disponíveis
CREATE INDEX idx_candidatos_disponiveis 
ON candidatos(nivel_experiencia, salario_pretendido)
WHERE disponibilidade = true;

-- Índice parcial para empresas ativas
CREATE INDEX idx_empresas_ativas_setor 
ON empresas(setor_atividade, tamanho_empresa)
WHERE id_empresa IN (SELECT id_usuario FROM usuarios WHERE status_conta = 'ativo');

-- Índice para recrutadores por empresa
CREATE INDEX idx_recrutadores_empresa 
ON recrutadores(id_empresa, cargo);

COMMENT ON INDEX idx_candidatos_disponiveis IS 'Otimiza busca de candidatos disponíveis';
COMMENT ON INDEX idx_empresas_ativas_setor IS 'Otimiza busca de empresas ativas por setor';
COMMENT ON INDEX idx_recrutadores_empresa IS 'Otimiza busca de recrutadores por empresa';

-- ============================================================================
-- 11. ANÁLISE DE IMPACTO DOS ÍNDICES
-- ============================================================================

-- Função para análise de uso de índices
CREATE OR REPLACE FUNCTION analisar_uso_indices()
RETURNS TABLE (
    schemaname TEXT,
    tablename TEXT,
    indexname TEXT,
    idx_scan BIGINT,
    idx_tup_read BIGINT,
    idx_tup_fetch BIGINT
)
LANGUAGE SQL
AS $$
    SELECT 
        schemaname::TEXT,
        tablename::TEXT,
        indexname::TEXT,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'public'
    ORDER BY idx_scan DESC;
$$;

COMMENT ON FUNCTION analisar_uso_indices IS 'Analisa estatísticas de uso dos índices';

-- ============================================================================
-- 12. MANUTENÇÃO DOS ÍNDICES
-- ============================================================================

-- Script para reindexação (executar periodicamente)
CREATE OR REPLACE FUNCTION reindexar_sistema()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    -- Reindexação de tabelas críticas
    REINDEX TABLE usuarios;
    REINDEX TABLE vagas;
    REINDEX TABLE candidaturas;
    REINDEX TABLE candidatos_habilidades;
    REINDEX TABLE vagas_habilidades;
    
    -- Atualiza estatísticas
    ANALYZE usuarios;
    ANALYZE vagas;
    ANALYZE candidaturas;
    ANALYZE candidatos_habilidades;
    ANALYZE vagas_habilidades;
    
    RETURN 'Reindexação concluída com sucesso';
END;
$$;

COMMENT ON FUNCTION reindexar_sistema IS 'Reindexação e atualização de estatísticas do sistema';

-- ============================================================================
-- 13. DOCUMENTAÇÃO DOS ÍNDICES CRIADOS
-- ============================================================================

-- View para documentação dos índices
CREATE OR REPLACE VIEW vw_documentacao_indices AS
SELECT 
    t.table_name AS tabela,
    i.indexname AS indice,
    i.indexdef AS definicao,
    obj_description(c.oid) AS comentario,
    CASE 
        WHEN i.indexdef LIKE '%UNIQUE%' THEN 'UNIQUE'
        WHEN i.indexdef LIKE '%WHERE%' THEN 'PARTIAL'
        WHEN i.indexdef LIKE '%gin%' THEN 'GIN'
        WHEN i.indexdef LIKE '%gist%' THEN 'GIST'
        ELSE 'BTREE'
    END AS tipo_indice,
    pg_size_pretty(pg_relation_size(c.oid)) AS tamanho
FROM information_schema.tables t
LEFT JOIN pg_indexes i ON t.table_name = i.tablename
LEFT JOIN pg_class c ON i.indexname = c.relname
WHERE t.table_schema = 'public'
AND t.table_type = 'BASE TABLE'
AND i.indexname IS NOT NULL
AND i.indexname NOT LIKE '%_pkey'  -- Exclui chaves primárias
ORDER BY t.table_name, i.indexname;

COMMENT ON VIEW vw_documentacao_indices IS 'Documentação completa dos índices do sistema';

-- ============================================================================
-- 14. TESTES DE PERFORMANCE
-- ============================================================================

-- Função para testar performance das consultas principais
CREATE OR REPLACE FUNCTION testar_performance_consultas()
RETURNS TABLE (
    consulta TEXT,
    tempo_execucao INTERVAL,
    custo_estimado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    inicio TIMESTAMP;
    fim TIMESTAMP;
BEGIN
    -- Teste 1: Busca de vagas abertas
    inicio := clock_timestamp();
    PERFORM * FROM vw_vagas_abertas_detalhadas LIMIT 10;
    fim := clock_timestamp();
    
    RETURN QUERY SELECT 
        'Busca vagas abertas'::TEXT,
        (fim - inicio)::INTERVAL,
        'Verificar com EXPLAIN ANALYZE'::TEXT;
    
    -- Teste 2: Matching de candidatos
    inicio := clock_timestamp();
    PERFORM * FROM sp_buscar_vagas_compativeis(1, 5);
    fim := clock_timestamp();
    
    RETURN QUERY SELECT 
        'Matching candidato-vaga'::TEXT,
        (fim - inicio)::INTERVAL,
        'Verificar com EXPLAIN ANALYZE'::TEXT;
    
    -- Adicione mais testes conforme necessário
END;
$$;

COMMENT ON FUNCTION testar_performance_consultas IS 'Testa performance das consultas principais';

-- ============================================================================
-- FINALIZAÇÃO E RESUMO
-- ============================================================================

-- Contagem final de índices criados
SELECT 
    'Índices criados com sucesso!' as status,
    COUNT(*) as total_indices_sistema
FROM pg_indexes 
WHERE schemaname = 'public' 
AND indexname NOT LIKE '%_pkey'
AND indexname NOT LIKE '%_key';

-- Relatório de índices por tabela
SELECT 
    tablename,
    COUNT(*) as quantidade_indices,
    STRING_AGG(indexname, ', ') as nomes_indices
FROM pg_indexes 
WHERE schemaname = 'public'
AND indexname NOT LIKE '%_pkey'
AND indexname NOT LIKE '%_key'
GROUP BY tablename
ORDER BY quantidade_indices DESC;

-- ============================================================================
-- INSTRUÇÕES DE USO
-- ============================================================================

/*
INSTRUÇÕES PARA USO DOS ÍNDICES:

1. MONITORAMENTO:
   - Execute periodicamente: SELECT * FROM analisar_uso_indices();
   - Monitore índices não utilizados para possível remoção

2. MANUTENÇÃO:
   - Execute mensalmente: SELECT reindexar_sistema();
   - Monitore o crescimento dos índices

3. ANÁLISE DE PERFORMANCE:
   - Use EXPLAIN ANALYZE nas consultas principais
   - Execute: SELECT * FROM testar_performance_consultas();

4. DOCUMENTAÇÃO:
   - Consulte: SELECT * FROM vw_documentacao_indices;

5. REMOÇÃO DE ÍNDICES NÃO UTILIZADOS:
   - Identifique índices com idx_scan = 0 após período de uso
   - Remova com cuidado após análise

EXEMPLO DE ANÁLISE:
EXPLAIN ANALYZE SELECT * FROM vw_vagas_abertas_detalhadas 
WHERE cidade = 'São Paulo' LIMIT 10;
*/

SELECT 'Sistema de índices implementado com sucesso!' as status_final,
       'Monitoramento e manutenção necessários' as observacao;
