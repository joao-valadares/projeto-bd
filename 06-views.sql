-- ============================================================================
-- SISTEMA DE RECRUTAMENTO - VIEWS
-- Banco de Dados: PostgreSQL
-- Descrição: Views para consultas específicas e relatórios do sistema
-- ============================================================================

-- ============================================================================
-- 1. VIEW: VAGAS ABERTAS COM DETALHES COMPLETOS
-- Descrição: Mostra todas as vagas abertas com informações da empresa e localização
-- ============================================================================

CREATE OR REPLACE VIEW vw_vagas_abertas_detalhadas AS
SELECT 
    v.id_vaga,
    v.titulo,
    v.descricao,
    v.requisitos,
    v.beneficios,
    v.salario_min,
    v.salario_max,
    CASE 
        WHEN v.salario_min IS NOT NULL AND v.salario_max IS NOT NULL THEN
            'R$ ' || TO_CHAR(v.salario_min, 'FM999,999.00') || ' - R$ ' || TO_CHAR(v.salario_max, 'FM999,999.00')
        WHEN v.salario_min IS NOT NULL THEN
            'A partir de R$ ' || TO_CHAR(v.salario_min, 'FM999,999.00')
        WHEN v.salario_max IS NOT NULL THEN
            'Até R$ ' || TO_CHAR(v.salario_max, 'FM999,999.00')
        ELSE 'A combinar'
    END AS faixa_salarial,
    v.tipo_contrato,
    v.modalidade_trabalho,
    v.nivel_experiencia,
    v.data_publicacao,
    v.data_expiracao,
    EXTRACT(DAY FROM (v.data_expiracao - CURRENT_DATE)) AS dias_para_expirar,
    v.quantidade_vagas,
    
    -- Dados da empresa
    e.nome_fantasia AS empresa,
    e.razao_social,
    e.setor_atividade,
    e.tamanho_empresa,
    e.site_url AS site_empresa,
    
    -- Dados do recrutador
    r.nome_completo AS recrutador,
    r.cargo AS cargo_recrutador,
    
    -- Dados da categoria
    cv.nome_categoria AS categoria,
    
    -- Dados da localização
    l.cidade,
    l.estado,
    l.pais,
    CASE 
        WHEN l.cidade IS NOT NULL AND l.estado IS NOT NULL THEN
            l.cidade || ', ' || l.estado
        ELSE 'Não informado'
    END AS localizacao_completa,
    
    -- Contadores
    (SELECT COUNT(*) FROM candidaturas c WHERE c.id_vaga = v.id_vaga) AS total_candidatos,
    (SELECT COUNT(*) FROM candidaturas c WHERE c.id_vaga = v.id_vaga AND c.status_candidatura = 'pendente') AS candidatos_pendentes,
    
    -- Habilidades requeridas (concatenadas)
    (SELECT STRING_AGG(h.nome_habilidade || 
        CASE WHEN vh.obrigatoria THEN ' (Obrigatória)' ELSE ' (Desejável)' END, 
        ', ' ORDER BY vh.obrigatoria DESC, h.nome_habilidade)
     FROM vagas_habilidades vh 
     INNER JOIN habilidades h ON vh.id_habilidade = h.id_habilidade
     WHERE vh.id_vaga = v.id_vaga
    ) AS habilidades_requeridas

FROM vagas v
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN recrutadores r ON v.id_recrutador = r.id_recrutador
LEFT JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
LEFT JOIN localizacoes l ON v.id_localizacao = l.id_localizacao
WHERE v.status_vaga = 'aberta'
AND v.data_expiracao >= CURRENT_DATE;

-- ============================================================================
-- 2. VIEW: CANDIDATOS POR VAGA COM STATUS DO PROCESSO
-- Descrição: Mostra candidatos e seus status nos processos seletivos
-- ============================================================================

CREATE OR REPLACE VIEW vw_candidatos_por_vaga AS
SELECT 
    v.id_vaga,
    v.titulo AS titulo_vaga,
    e.nome_fantasia AS empresa,
    
    -- Dados do candidato
    cand.id_candidato,
    cand.nome_completo AS candidato,
    cand.email,
    cand.telefone,
    cand.nivel_experiencia,
    cand.salario_pretendido,
    
    -- Dados da candidatura
    c.id_candidatura,
    c.data_candidatura,
    c.status_candidatura,
    c.carta_apresentacao,
    
    -- Dados do processo seletivo
    ps.id_processo,
    ps.etapa_atual,
    ep.nome_etapa AS etapa_atual_nome,
    ep.ordem_execucao AS ordem_etapa_atual,
    ps.data_inicio AS inicio_processo,
    ps.data_fim AS fim_processo,
    ps.status_processo,
    
    -- Cálculo de tempo no processo
    CASE 
        WHEN ps.data_fim IS NOT NULL THEN
            EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))
        ELSE 
            EXTRACT(DAY FROM (CURRENT_TIMESTAMP - ps.data_inicio))
    END AS dias_no_processo,
    
    -- Última avaliação
    (SELECT ac.nota 
     FROM avaliacoes_candidatos ac 
     WHERE ac.id_processo = ps.id_processo 
     ORDER BY ac.data_avaliacao DESC 
     LIMIT 1) AS ultima_nota,
    
    (SELECT ac.comentarios 
     FROM avaliacoes_candidatos ac 
     WHERE ac.id_processo = ps.id_processo 
     ORDER BY ac.data_avaliacao DESC 
     LIMIT 1) AS ultimo_feedback,
    
    -- Contadores de avaliações
    (SELECT COUNT(*) 
     FROM avaliacoes_candidatos ac 
     WHERE ac.id_processo = ps.id_processo) AS total_avaliacoes,
    
    -- Média das notas
    (SELECT ROUND(AVG(ac.nota), 2)
     FROM avaliacoes_candidatos ac 
     WHERE ac.id_processo = ps.id_processo) AS media_avaliacoes,
    
    -- Compatibilidade de habilidades
    (SELECT ROUND(
        (COUNT(CASE WHEN ch.id_habilidade IS NOT NULL THEN 1 END) * 100.0 / 
         NULLIF(COUNT(vh.id_habilidade), 0)), 2)
     FROM vagas_habilidades vh
     LEFT JOIN candidatos_habilidades ch ON vh.id_habilidade = ch.id_habilidade 
                                         AND ch.id_candidato = cand.id_candidato
     WHERE vh.id_vaga = v.id_vaga
    ) AS percentual_match_habilidades

FROM vagas v
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN candidaturas c ON v.id_vaga = c.id_vaga
INNER JOIN candidatos cand ON c.id_candidato = cand.id_candidato
INNER JOIN usuarios u ON cand.id_candidato = u.id_usuario
LEFT JOIN processos_seletivos ps ON c.id_candidatura = ps.id_candidatura
LEFT JOIN etapas_processo ep ON ps.etapa_atual = ep.id_etapa;

-- ============================================================================
-- 3. VIEW: DASHBOARD EMPRESAS
-- Descrição: Métricas e estatísticas importantes para empresas
-- ============================================================================

CREATE OR REPLACE VIEW vw_dashboard_empresas AS
SELECT 
    e.id_empresa,
    e.nome_fantasia AS empresa,
    e.setor_atividade,
    e.tamanho_empresa,
    
    -- Estatísticas de vagas
    COUNT(v.id_vaga) AS total_vagas_publicadas,
    COUNT(CASE WHEN v.status_vaga = 'aberta' THEN 1 END) AS vagas_abertas,
    COUNT(CASE WHEN v.status_vaga = 'fechada' THEN 1 END) AS vagas_fechadas,
    COUNT(CASE WHEN v.status_vaga = 'pausada' THEN 1 END) AS vagas_pausadas,
    
    -- Estatísticas de candidaturas
    COUNT(c.id_candidatura) AS total_candidaturas_recebidas,
    COUNT(CASE WHEN c.status_candidatura = 'pendente' THEN 1 END) AS candidaturas_pendentes,
    COUNT(CASE WHEN c.status_candidatura = 'em_analise' THEN 1 END) AS candidaturas_em_analise,
    COUNT(CASE WHEN c.status_candidatura = 'em_processo' THEN 1 END) AS candidaturas_em_processo,
    COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) AS candidaturas_aprovadas,
    COUNT(CASE WHEN c.status_candidatura = 'rejeitado' THEN 1 END) AS candidaturas_rejeitadas,
    
    -- Métricas de desempenho
    CASE 
        WHEN COUNT(c.id_candidatura) > 0 THEN
            ROUND((COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
                   COUNT(c.id_candidatura)), 2)
        ELSE 0
    END AS taxa_aprovacao_percent,
    
    CASE 
        WHEN COUNT(v.id_vaga) > 0 THEN
            ROUND((COUNT(c.id_candidatura) * 1.0 / COUNT(v.id_vaga)), 2)
        ELSE 0
    END AS media_candidatos_por_vaga,
    
    -- Tempo médio de contratação (em dias)
    (SELECT ROUND(AVG(EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))))
     FROM candidaturas c2
     INNER JOIN vagas v2 ON c2.id_vaga = v2.id_vaga
     INNER JOIN processos_seletivos ps ON c2.id_candidatura = ps.id_candidatura
     WHERE v2.id_empresa = e.id_empresa
     AND c2.status_candidatura = 'aprovado'
     AND ps.data_fim IS NOT NULL
    ) AS tempo_medio_contratacao_dias,
    
    -- Dados temporais
    MIN(v.data_publicacao) AS primeira_vaga_publicada,
    MAX(v.data_publicacao) AS ultima_vaga_publicada,
    COUNT(CASE WHEN v.data_publicacao >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS vagas_ultimo_mes,
    COUNT(CASE WHEN c.data_candidatura >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS candidaturas_ultimo_mes,
    
    -- Top categoria de vagas
    (SELECT cv.nome_categoria
     FROM vagas v2
     INNER JOIN categorias_vaga cv ON v2.id_categoria = cv.id_categoria
     WHERE v2.id_empresa = e.id_empresa
     GROUP BY cv.nome_categoria
     ORDER BY COUNT(*) DESC
     LIMIT 1
    ) AS categoria_mais_publicada,
    
    -- Recrutadores ativos
    COUNT(DISTINCT r.id_recrutador) AS total_recrutadores

FROM empresas e
LEFT JOIN vagas v ON e.id_empresa = v.id_empresa
LEFT JOIN candidaturas c ON v.id_vaga = c.id_vaga
LEFT JOIN recrutadores r ON e.id_empresa = r.id_empresa
GROUP BY e.id_empresa, e.nome_fantasia, e.setor_atividade, e.tamanho_empresa;

-- ============================================================================
-- 4. VIEW: PERFIL COMPLETO DO CANDIDATO
-- Descrição: Visão unificada do perfil completo do candidato
-- ============================================================================

CREATE OR REPLACE VIEW vw_perfil_completo_candidato AS
SELECT 
    c.id_candidato,
    c.nome_completo,
    u.email,
    c.telefone,
    c.data_nascimento,
    EXTRACT(YEAR FROM AGE(c.data_nascimento)) AS idade,
    c.nivel_experiencia,
    c.salario_pretendido,
    c.disponibilidade,
    c.linkedin_url,
    c.github_url,
    
    -- Dados do currículo
    cur.resumo_profissional,
    cur.objetivo,
    cur.data_atualizacao AS curriculo_atualizado_em,
    
    -- Estatísticas de candidaturas
    COUNT(DISTINCT cand.id_candidatura) AS total_candidaturas,
    COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) AS candidaturas_aprovadas,
    COUNT(CASE WHEN cand.status_candidatura = 'rejeitado' THEN 1 END) AS candidaturas_rejeitadas,
    COUNT(CASE WHEN cand.status_candidatura IN ('pendente', 'em_analise', 'em_processo') THEN 1 END) AS candidaturas_ativas,
    
    -- Taxa de sucesso
    CASE 
        WHEN COUNT(DISTINCT cand.id_candidatura) > 0 THEN
            ROUND((COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
                   COUNT(DISTINCT cand.id_candidatura)), 2)
        ELSE 0
    END AS taxa_sucesso_percent,
    
    -- Experiência profissional
    COUNT(DISTINCT ep.id_experiencia) AS total_experiencias,
    (SELECT ep2.empresa || ' - ' || ep2.cargo
     FROM experiencias_profissionais ep2
     WHERE ep2.id_curriculo = cur.id_curriculo
     AND ep2.emprego_atual = true
     LIMIT 1
    ) AS emprego_atual,
    
    -- Formação acadêmica
    COUNT(DISTINCT fa.id_formacao) AS total_formacoes,
    (SELECT fa2.grau || ' em ' || fa2.curso || ' - ' || fa2.instituicao
     FROM formacoes_academicas fa2
     WHERE fa2.id_curriculo = cur.id_curriculo
     ORDER BY 
        CASE fa2.grau 
            WHEN 'doutorado' THEN 5
            WHEN 'mestrado' THEN 4
            WHEN 'pos-graduacao' THEN 3
            WHEN 'graduacao' THEN 2
            WHEN 'tecnico' THEN 1
            ELSE 0
        END DESC,
        fa2.data_conclusao DESC NULLS FIRST
     LIMIT 1
    ) AS maior_formacao,
    
    -- Habilidades
    COUNT(DISTINCT ch.id_habilidade) AS total_habilidades,
    (SELECT STRING_AGG(h.nome_habilidade, ', ' ORDER BY ch.nivel_proficiencia DESC, h.nome_habilidade)
     FROM candidatos_habilidades ch2
     INNER JOIN habilidades h ON ch2.id_habilidade = h.id_habilidade
     WHERE ch2.id_candidato = c.id_candidato
     AND h.categoria = 'tecnica'
    ) AS habilidades_tecnicas,
    
    (SELECT STRING_AGG(h.nome_habilidade, ', ' ORDER BY h.nome_habilidade)
     FROM candidatos_habilidades ch2
     INNER JOIN habilidades h ON ch2.id_habilidade = h.id_habilidade
     WHERE ch2.id_candidato = c.id_candidato
     AND h.categoria = 'idioma'
    ) AS idiomas,
    
    -- Networking
    (SELECT COUNT(*)
     FROM conexoes con
     WHERE (con.id_solicitante = c.id_candidato OR con.id_receptor = c.id_candidato)
     AND con.status_conexao = 'aceita'
    ) AS total_conexoes,
    
    -- Atividade recente
    MAX(cand.data_candidatura) AS ultima_candidatura,
    u.ultimo_login,
    u.data_cadastro

FROM candidatos c
INNER JOIN usuarios u ON c.id_candidato = u.id_usuario
LEFT JOIN curriculos cur ON c.id_candidato = cur.id_candidato
LEFT JOIN candidaturas cand ON c.id_candidato = cand.id_candidato
LEFT JOIN experiencias_profissionais ep ON cur.id_curriculo = ep.id_curriculo
LEFT JOIN formacoes_academicas fa ON cur.id_curriculo = fa.id_curriculo
LEFT JOIN candidatos_habilidades ch ON c.id_candidato = ch.id_candidato
GROUP BY 
    c.id_candidato, c.nome_completo, u.email, c.telefone, c.data_nascimento,
    c.nivel_experiencia, c.salario_pretendido, c.disponibilidade, c.linkedin_url, c.github_url,
    cur.id_curriculo, cur.resumo_profissional, cur.objetivo, cur.data_atualizacao,
    u.ultimo_login, u.data_cadastro;

-- ============================================================================
-- 5. VIEW: RELATÓRIO DE PROCESSOS SELETIVOS
-- Descrição: Acompanhamento detalhado dos processos seletivos
-- ============================================================================

CREATE OR REPLACE VIEW vw_relatorio_processos_seletivos AS
SELECT 
    ps.id_processo,
    
    -- Dados da vaga
    v.titulo AS vaga,
    e.nome_fantasia AS empresa,
    v.nivel_experiencia AS nivel_vaga,
    
    -- Dados do candidato
    cand.nome_completo AS candidato,
    cand.nivel_experiencia AS nivel_candidato,
    
    -- Dados da candidatura
    c.data_candidatura,
    c.status_candidatura,
    
    -- Dados do processo
    ps.data_inicio AS inicio_processo,
    ps.data_fim AS fim_processo,
    ps.status_processo,
    
    -- Etapa atual
    ep_atual.nome_etapa AS etapa_atual,
    ep_atual.ordem_execucao AS ordem_etapa_atual,
    (SELECT COUNT(*) FROM etapas_processo) AS total_etapas,
    ROUND((ep_atual.ordem_execucao * 100.0 / (SELECT COUNT(*) FROM etapas_processo)), 2) AS progresso_percent,
    
    -- Tempos
    EXTRACT(DAY FROM (COALESCE(ps.data_fim, CURRENT_TIMESTAMP) - ps.data_inicio)) AS dias_no_processo,
    
    -- Avaliações
    COUNT(ac.id_avaliacao) AS total_avaliacoes,
    ROUND(AVG(ac.nota), 2) AS media_avaliacoes,
    MAX(ac.nota) AS melhor_nota,
    MIN(ac.nota) AS pior_nota,
    
    -- Última avaliação
    (SELECT ac2.nota 
     FROM avaliacoes_candidatos ac2 
     WHERE ac2.id_processo = ps.id_processo 
     ORDER BY ac2.data_avaliacao DESC 
     LIMIT 1) AS ultima_nota,
    
    (SELECT ac2.comentarios 
     FROM avaliacoes_candidatos ac2 
     WHERE ac2.id_processo = ps.id_processo 
     ORDER BY ac2.data_avaliacao DESC 
     LIMIT 1) AS ultimo_comentario,
    
    -- Próxima etapa
    (SELECT ep_prox.nome_etapa
     FROM etapas_processo ep_prox
     WHERE ep_prox.ordem_execucao = ep_atual.ordem_execucao + 1
     LIMIT 1
    ) AS proxima_etapa,
    
    -- Status geral
    CASE 
        WHEN ps.status_processo = 'concluido' AND c.status_candidatura = 'aprovado' THEN 'Contratado'
        WHEN ps.status_processo = 'concluido' AND c.status_candidatura = 'rejeitado' THEN 'Rejeitado'
        WHEN ps.status_processo = 'cancelado' THEN 'Cancelado'
        WHEN ps.status_processo = 'em_andamento' THEN 'Em Andamento'
        ELSE 'Iniciado'
    END AS status_legivel

FROM processos_seletivos ps
INNER JOIN candidaturas c ON ps.id_candidatura = c.id_candidatura
INNER JOIN vagas v ON c.id_vaga = v.id_vaga
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN candidatos cand ON c.id_candidato = cand.id_candidato
LEFT JOIN etapas_processo ep_atual ON ps.etapa_atual = ep_atual.id_etapa
LEFT JOIN avaliacoes_candidatos ac ON ps.id_processo = ac.id_processo
GROUP BY 
    ps.id_processo, v.titulo, e.nome_fantasia, v.nivel_experiencia,
    cand.nome_completo, cand.nivel_experiencia, c.data_candidatura, c.status_candidatura,
    ps.data_inicio, ps.data_fim, ps.status_processo,
    ep_atual.id_etapa, ep_atual.nome_etapa, ep_atual.ordem_execucao;

-- ============================================================================
-- 6. EXEMPLOS DE USO DAS VIEWS
-- ============================================================================

/*
-- Exemplo 1: Buscar vagas abertas em São Paulo
SELECT * FROM vw_vagas_abertas_detalhadas 
WHERE cidade = 'São Paulo' 
ORDER BY data_publicacao DESC;

-- Exemplo 2: Ver candidatos de uma vaga específica
SELECT * FROM vw_candidatos_por_vaga 
WHERE id_vaga = 1 
ORDER BY percentual_match_habilidades DESC;

-- Exemplo 3: Dashboard de uma empresa
SELECT * FROM vw_dashboard_empresas 
WHERE id_empresa = 1;

-- Exemplo 4: Perfil de um candidato
SELECT * FROM vw_perfil_completo_candidato 
WHERE id_candidato = 1;

-- Exemplo 5: Processos seletivos em andamento
SELECT * FROM vw_relatorio_processos_seletivos 
WHERE status_processo = 'em_andamento'
ORDER BY dias_no_processo DESC;
*/

-- ============================================================================
-- FINALIZAÇÃO
-- ============================================================================

SELECT 'Views criadas com sucesso!' as status,
       'Total: 5 views implementadas' as detalhes,
       'Funcionalidades: Vagas abertas, Candidatos, Dashboard empresas, Perfil candidatos, Processos seletivos' as recursos;
