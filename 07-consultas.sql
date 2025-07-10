-- ============================================================================
-- SISTEMA DE RECRUTAMENTO - CONSULTAS SQL CONTEXTUALIZADAS
-- Banco de Dados: PostgreSQL
-- Descrição: 10 consultas úteis e interessantes para o sistema de recrutamento
-- ============================================================================

-- ============================================================================
-- 1. TOP 10 EMPRESAS COM MAIS VAGAS ABERTAS
-- Descrição: Ranking das empresas mais ativas no momento
-- ============================================================================

SELECT 
    e.nome_fantasia AS empresa,
    e.setor_atividade,
    e.tamanho_empresa,
    COUNT(v.id_vaga) AS total_vagas_abertas,
    COUNT(c.id_candidatura) AS total_candidaturas_recebidas,
    ROUND(AVG(v.salario_max), 2) AS salario_medio_maximo,
    MIN(v.data_publicacao) AS primeira_vaga_publicada,
    MAX(v.data_publicacao) AS ultima_vaga_publicada
FROM empresas e
INNER JOIN vagas v ON e.id_empresa = v.id_empresa
LEFT JOIN candidaturas c ON v.id_vaga = c.id_vaga
WHERE v.status_vaga = 'aberta'
AND v.data_expiracao >= CURRENT_DATE
GROUP BY e.id_empresa, e.nome_fantasia, e.setor_atividade, e.tamanho_empresa
ORDER BY total_vagas_abertas DESC, total_candidaturas_recebidas DESC
LIMIT 10;

-- ============================================================================
-- 2. CANDIDATOS MAIS ATIVOS (COM MAIS CANDIDATURAS NOS ÚLTIMOS 6 MESES)
-- Descrição: Identifica candidatos mais engajados na busca por emprego
-- ============================================================================

SELECT 
    c.nome_completo AS candidato,
    c.nivel_experiencia,
    c.salario_pretendido,
    COUNT(cand.id_candidatura) AS candidaturas_6_meses,
    COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) AS aprovacoes,
    COUNT(CASE WHEN cand.status_candidatura = 'em_processo' THEN 1 END) AS em_processo,
    COUNT(CASE WHEN cand.status_candidatura = 'rejeitado' THEN 1 END) AS rejeicoes,
    
    -- Taxa de sucesso
    CASE 
        WHEN COUNT(cand.id_candidatura) > 0 THEN
            ROUND((COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
                   COUNT(cand.id_candidatura)), 2)
        ELSE 0
    END AS taxa_sucesso_percent,
    
    -- Última candidatura
    MAX(cand.data_candidatura) AS ultima_candidatura,
    
    -- Habilidades do candidato
    (SELECT STRING_AGG(h.nome_habilidade, ', ')
     FROM candidatos_habilidades ch
     INNER JOIN habilidades h ON ch.id_habilidade = h.id_habilidade
     WHERE ch.id_candidato = c.id_candidato
     AND h.categoria = 'tecnica'
     LIMIT 5
    ) AS principais_habilidades

FROM candidatos c
INNER JOIN candidaturas cand ON c.id_candidato = cand.id_candidato
WHERE cand.data_candidatura >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY c.id_candidato, c.nome_completo, c.nivel_experiencia, c.salario_pretendido
HAVING COUNT(cand.id_candidatura) >= 3  -- Pelo menos 3 candidaturas
ORDER BY candidaturas_6_meses DESC, taxa_sucesso_percent DESC
LIMIT 15;

-- ============================================================================
-- 3. ANÁLISE DE SALÁRIOS POR ÁREA E NÍVEL DE EXPERIÊNCIA
-- Descrição: Estudo de mercado salarial por categoria e senioridade
-- ============================================================================

SELECT 
    cv.nome_categoria AS area,
    v.nivel_experiencia,
    COUNT(v.id_vaga) AS total_vagas,
    
    -- Estatísticas salariais
    MIN(v.salario_min) AS menor_salario_min,
    MAX(v.salario_max) AS maior_salario_max,
    ROUND(AVG(v.salario_min), 2) AS media_salario_min,
    ROUND(AVG(v.salario_max), 2) AS media_salario_max,
    
    -- Mediana (aproximada usando percentis)
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY v.salario_min) AS mediana_salario_min,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY v.salario_max) AS mediana_salario_max,
    
    -- Modalidade de trabalho mais comum
    MODE() WITHIN GROUP (ORDER BY v.modalidade_trabalho) AS modalidade_mais_comum,
    
    -- Tipo de contrato mais comum
    MODE() WITHIN GROUP (ORDER BY v.tipo_contrato) AS contrato_mais_comum,
    
    -- Competitividade (quantidade de candidatos por vaga)
    ROUND(AVG(candidatos_por_vaga.total), 2) AS media_candidatos_por_vaga

FROM vagas v
INNER JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
LEFT JOIN (
    SELECT id_vaga, COUNT(*) as total
    FROM candidaturas
    GROUP BY id_vaga
) candidatos_por_vaga ON v.id_vaga = candidatos_por_vaga.id_vaga
WHERE v.salario_min IS NOT NULL 
AND v.salario_max IS NOT NULL
AND v.data_publicacao >= CURRENT_DATE - INTERVAL '1 year'  -- Último ano
GROUP BY cv.id_categoria, cv.nome_categoria, v.nivel_experiencia
HAVING COUNT(v.id_vaga) >= 5  -- Pelo menos 5 vagas para ser significativo
ORDER BY cv.nome_categoria, 
         CASE v.nivel_experiencia 
             WHEN 'junior' THEN 1
             WHEN 'pleno' THEN 2
             WHEN 'senior' THEN 3
             WHEN 'especialista' THEN 4
         END;

-- ============================================================================
-- 4. PROCESSOS SELETIVOS MAIS LONGOS E EFICIENTES
-- Descrição: Análise de tempo e eficiência dos processos seletivos
-- ============================================================================

SELECT 
    e.nome_fantasia AS empresa,
    v.titulo AS vaga,
    v.nivel_experiencia,
    
    -- Métricas de tempo
    COUNT(ps.id_processo) AS total_processos,
    ROUND(AVG(EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))), 1) AS tempo_medio_dias,
    MIN(EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))) AS processo_mais_rapido,
    MAX(EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))) AS processo_mais_longo,
    
    -- Taxa de aprovação
    COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) AS contratacoes,
    ROUND((COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
           COUNT(ps.id_processo)), 2) AS taxa_contratacao_percent,
    
    -- Etapa onde mais candidatos são eliminados
    (SELECT ep.nome_etapa
     FROM avaliacoes_candidatos ac
     INNER JOIN etapas_processo ep ON ac.id_etapa = ep.id_etapa
     INNER JOIN processos_seletivos ps2 ON ac.id_processo = ps2.id_processo
     INNER JOIN candidaturas c2 ON ps2.id_candidatura = c2.id_candidatura
     WHERE c2.id_vaga = v.id_vaga
     AND c2.status_candidatura = 'rejeitado'
     GROUP BY ep.id_etapa, ep.nome_etapa
     ORDER BY COUNT(*) DESC
     LIMIT 1
    ) AS etapa_maior_eliminacao,
    
    -- Média de avaliações
    (SELECT ROUND(AVG(ac.nota), 2)
     FROM avaliacoes_candidatos ac
     INNER JOIN processos_seletivos ps2 ON ac.id_processo = ps2.id_processo
     INNER JOIN candidaturas c2 ON ps2.id_candidatura = c2.id_candidatura
     WHERE c2.id_vaga = v.id_vaga
    ) AS nota_media_candidatos

FROM vagas v
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN candidaturas c ON v.id_vaga = c.id_vaga
INNER JOIN processos_seletivos ps ON c.id_candidatura = ps.id_candidatura
WHERE ps.data_fim IS NOT NULL  -- Apenas processos finalizados
AND ps.data_inicio >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY e.id_empresa, e.nome_fantasia, v.id_vaga, v.titulo, v.nivel_experiencia
HAVING COUNT(ps.id_processo) >= 3  -- Pelo menos 3 processos para análise
ORDER BY tempo_medio_dias DESC, taxa_contratacao_percent DESC;

-- ============================================================================
-- 5. HABILIDADES MAIS DEMANDADAS NO MERCADO
-- Descrição: Ranking das competências mais requisitadas pelas empresas
-- ============================================================================

SELECT 
    h.nome_habilidade AS habilidade,
    h.categoria,
    
    -- Demanda por habilidade
    COUNT(DISTINCT vh.id_vaga) AS vagas_que_exigem,
    COUNT(CASE WHEN vh.obrigatoria = true THEN 1 END) AS vagas_obrigatorias,
    COUNT(CASE WHEN vh.obrigatoria = false THEN 1 END) AS vagas_desejaveis,
    
    -- Oferta (candidatos que possuem)
    COUNT(DISTINCT ch.id_candidato) AS candidatos_que_possuem,
    
    -- Relação oferta/demanda
    CASE 
        WHEN COUNT(DISTINCT ch.id_candidato) > 0 THEN
            ROUND((COUNT(DISTINCT vh.id_vaga) * 1.0 / COUNT(DISTINCT ch.id_candidato)), 2)
        ELSE 999.99  -- Demanda muito alta, oferta zero
    END AS ratio_demanda_oferta,
    
    -- Níveis mais exigidos
    MODE() WITHIN GROUP (ORDER BY vh.nivel_requerido) AS nivel_mais_exigido,
    
    -- Salário médio das vagas que exigem esta habilidade
    (SELECT ROUND(AVG(v.salario_max), 2)
     FROM vagas_habilidades vh2
     INNER JOIN vagas v ON vh2.id_vaga = v.id_vaga
     WHERE vh2.id_habilidade = h.id_habilidade
     AND v.salario_max IS NOT NULL
    ) AS salario_medio_vagas,
    
    -- Áreas que mais demandam
    (SELECT STRING_AGG(DISTINCT cv.nome_categoria, ', ')
     FROM vagas_habilidades vh2
     INNER JOIN vagas v ON vh2.id_vaga = v.id_vaga
     INNER JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
     WHERE vh2.id_habilidade = h.id_habilidade
    ) AS principais_areas

FROM habilidades h
LEFT JOIN vagas_habilidades vh ON h.id_habilidade = vh.id_habilidade
LEFT JOIN candidatos_habilidades ch ON h.id_habilidade = ch.id_habilidade
LEFT JOIN vagas v ON vh.id_vaga = v.id_vaga
WHERE v.data_publicacao >= CURRENT_DATE - INTERVAL '6 months'  -- Últimos 6 meses
OR v.data_publicacao IS NULL  -- Inclui habilidades sem vagas recentes
GROUP BY h.id_habilidade, h.nome_habilidade, h.categoria
HAVING COUNT(DISTINCT vh.id_vaga) > 0  -- Apenas habilidades com demanda
ORDER BY vagas_que_exigem DESC, ratio_demanda_oferta DESC
LIMIT 20;

-- ============================================================================
-- 6. CANDIDATOS COM MELHOR COMPATIBILIDADE POR VAGA
-- Descrição: Matching inteligente entre candidatos e vagas específicas
-- ============================================================================

WITH vaga_especifica AS (
    SELECT 1 as id_vaga_filtro  -- Pode ser parametrizado
),
compatibilidade_candidatos AS (
    SELECT 
        c.id_candidato,
        c.nome_completo,
        c.nivel_experiencia,
        c.salario_pretendido,
        v.salario_max,
        v.nivel_experiencia AS nivel_vaga_requerido,
        
        -- Score de habilidades
        COUNT(CASE WHEN vh.id_habilidade IS NOT NULL AND ch.id_habilidade IS NOT NULL THEN 1 END) AS habilidades_matching,
        COUNT(vh.id_habilidade) AS habilidades_requeridas_total,
        COUNT(CASE WHEN vh.obrigatoria = true AND ch.id_habilidade IS NOT NULL THEN 1 END) AS habilidades_obrigatorias_atendidas,
        COUNT(CASE WHEN vh.obrigatoria = true THEN 1 END) AS habilidades_obrigatorias_total,
        
        -- Score de experiência
        CASE 
            WHEN c.nivel_experiencia = v.nivel_experiencia THEN 100
            WHEN (c.nivel_experiencia = 'pleno' AND v.nivel_experiencia = 'junior') THEN 95
            WHEN (c.nivel_experiencia = 'senior' AND v.nivel_experiencia IN ('junior', 'pleno')) THEN 90
            WHEN (c.nivel_experiencia = 'especialista' AND v.nivel_experiencia IN ('junior', 'pleno', 'senior')) THEN 85
            WHEN (c.nivel_experiencia = 'junior' AND v.nivel_experiencia = 'pleno') THEN 70
            WHEN (c.nivel_experiencia IN ('junior', 'pleno') AND v.nivel_experiencia = 'senior') THEN 60
            ELSE 50
        END AS score_experiencia,
        
        -- Score salarial
        CASE 
            WHEN c.salario_pretendido IS NULL OR v.salario_max IS NULL THEN 80  -- Neutro
            WHEN c.salario_pretendido <= v.salario_max THEN 100
            WHEN c.salario_pretendido <= v.salario_max * 1.1 THEN 85  -- 10% acima
            WHEN c.salario_pretendido <= v.salario_max * 1.2 THEN 70  -- 20% acima
            ELSE 40  -- Muito acima
        END AS score_salario
        
    FROM candidatos c
    CROSS JOIN vaga_especifica ve
    INNER JOIN vagas v ON ve.id_vaga_filtro = v.id_vaga
    LEFT JOIN vagas_habilidades vh ON v.id_vaga = vh.id_vaga
    LEFT JOIN candidatos_habilidades ch ON c.id_candidato = ch.id_candidato 
                                        AND vh.id_habilidade = ch.id_habilidade
    WHERE c.disponibilidade = true
    -- Exclui candidatos que já se candidataram
    AND NOT EXISTS (
        SELECT 1 FROM candidaturas cand 
        WHERE cand.id_candidato = c.id_candidato 
        AND cand.id_vaga = v.id_vaga
    )
    GROUP BY c.id_candidato, c.nome_completo, c.nivel_experiencia, c.salario_pretendido,
             v.salario_max, v.nivel_experiencia
)
SELECT 
    nome_completo AS candidato,
    nivel_experiencia,
    salario_pretendido,
    
    -- Scores individuais
    score_experiencia,
    score_salario,
    
    -- Score de habilidades
    CASE 
        WHEN habilidades_requeridas_total = 0 THEN 80  -- Vaga sem habilidades específicas
        ELSE ROUND((habilidades_matching * 100.0 / habilidades_requeridas_total), 2)
    END AS score_habilidades,
    
    -- Score de habilidades obrigatórias
    CASE 
        WHEN habilidades_obrigatorias_total = 0 THEN 100  -- Sem habilidades obrigatórias
        ELSE ROUND((habilidades_obrigatorias_atendidas * 100.0 / habilidades_obrigatorias_total), 2)
    END AS score_habilidades_obrigatorias,
    
    -- Score total ponderado
    ROUND((
        score_experiencia * 0.3 +  -- 30% experiência
        score_salario * 0.2 +      -- 20% salário
        CASE 
            WHEN habilidades_requeridas_total = 0 THEN 80
            ELSE (habilidades_matching * 100.0 / habilidades_requeridas_total)
        END * 0.4 +               -- 40% habilidades gerais
        CASE 
            WHEN habilidades_obrigatorias_total = 0 THEN 100
            ELSE (habilidades_obrigatorias_atendidas * 100.0 / habilidades_obrigatorias_total)
        END * 0.1                 -- 10% habilidades obrigatórias
    ), 2) AS score_total_compatibilidade,
    
    habilidades_matching || '/' || habilidades_requeridas_total AS habilidades_match,
    habilidades_obrigatorias_atendidas || '/' || habilidades_obrigatorias_total AS obrigatorias_match

FROM compatibilidade_candidatos
ORDER BY score_total_compatibilidade DESC
LIMIT 10;

-- ============================================================================
-- 7. ANÁLISE DE RETENÇÃO: EMPRESAS VS CANDIDATOS APROVADOS
-- Descrição: Verifica quais empresas conseguem manter candidatos aprovados
-- ============================================================================

SELECT 
    e.nome_fantasia AS empresa,
    e.setor_atividade,
    COUNT(DISTINCT c.id_candidato) AS candidatos_aprovados,
    
    -- Tempo médio de processo até aprovação
    ROUND(AVG(EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))), 1) AS tempo_medio_aprovacao_dias,
    
    -- Distribuição por nível
    COUNT(CASE WHEN cand.nivel_experiencia = 'junior' THEN 1 END) AS aprovados_junior,
    COUNT(CASE WHEN cand.nivel_experiencia = 'pleno' THEN 1 END) AS aprovados_pleno,
    COUNT(CASE WHEN cand.nivel_experiencia = 'senior' THEN 1 END) AS aprovados_senior,
    COUNT(CASE WHEN cand.nivel_experiencia = 'especialista' THEN 1 END) AS aprovados_especialista,
    
    -- Salário médio oferecido
    ROUND(AVG(v.salario_max), 2) AS salario_medio_oferecido,
    
    -- Taxa de aprovação da empresa
    ROUND((COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
           COUNT(c.id_candidatura)), 2) AS taxa_aprovacao_empresa,
    
    -- Nota média dos candidatos aprovados
    (SELECT ROUND(AVG(ac.nota), 2)
     FROM avaliacoes_candidatos ac
     INNER JOIN processos_seletivos ps2 ON ac.id_processo = ps2.id_processo
     INNER JOIN candidaturas c2 ON ps2.id_candidatura = c2.id_candidatura
     INNER JOIN vagas v2 ON c2.id_vaga = v2.id_vaga
     WHERE v2.id_empresa = e.id_empresa
     AND c2.status_candidatura = 'aprovado'
    ) AS nota_media_aprovados,
    
    -- Categorias de vagas com mais aprovações
    (SELECT cv.nome_categoria
     FROM vagas v2
     INNER JOIN candidaturas c2 ON v2.id_vaga = c2.id_vaga
     INNER JOIN categorias_vaga cv ON v2.id_categoria = cv.id_categoria
     WHERE v2.id_empresa = e.id_empresa
     AND c2.status_candidatura = 'aprovado'
     GROUP BY cv.nome_categoria
     ORDER BY COUNT(*) DESC
     LIMIT 1
    ) AS categoria_mais_contrata

FROM empresas e
INNER JOIN vagas v ON e.id_empresa = v.id_empresa
INNER JOIN candidaturas c ON v.id_vaga = c.id_vaga
INNER JOIN candidatos cand ON c.id_candidato = cand.id_candidato
LEFT JOIN processos_seletivos ps ON c.id_candidatura = ps.id_candidatura
WHERE c.status_candidatura = 'aprovado'
AND c.data_candidatura >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY e.id_empresa, e.nome_fantasia, e.setor_atividade
HAVING COUNT(DISTINCT c.id_candidato) >= 2  -- Pelo menos 2 aprovações
ORDER BY candidatos_aprovados DESC, taxa_aprovacao_empresa DESC;

-- ============================================================================
-- 8. TENDÊNCIAS DE MODALIDADE DE TRABALHO POR SETOR
-- Descrição: Análise da evolução das modalidades de trabalho
-- ============================================================================

SELECT 
    cv.nome_categoria AS setor,
    v.modalidade_trabalho,
    
    -- Contadores por período
    COUNT(*) as total_vagas,
    COUNT(CASE WHEN v.data_publicacao >= CURRENT_DATE - INTERVAL '3 months' THEN 1 END) AS ultimos_3_meses,
    COUNT(CASE WHEN v.data_publicacao >= CURRENT_DATE - INTERVAL '6 months' 
                AND v.data_publicacao < CURRENT_DATE - INTERVAL '3 months' THEN 1 END) AS meses_4_a_6,
    COUNT(CASE WHEN v.data_publicacao >= CURRENT_DATE - INTERVAL '12 months' 
                AND v.data_publicacao < CURRENT_DATE - INTERVAL '6 months' THEN 1 END) AS meses_7_a_12,
    
    -- Percentual no setor
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY cv.nome_categoria)), 2) AS percentual_no_setor,
    
    -- Salário médio por modalidade
    ROUND(AVG(v.salario_max), 2) AS salario_medio_max,
    
    -- Competitividade (candidatos por vaga)
    (SELECT ROUND(AVG(candidatos_count), 2)
     FROM (
         SELECT COUNT(c.id_candidatura) as candidatos_count
         FROM candidaturas c
         INNER JOIN vagas v2 ON c.id_vaga = v2.id_vaga
         WHERE v2.id_categoria = cv.id_categoria
         AND v2.modalidade_trabalho = v.modalidade_trabalho
         GROUP BY v2.id_vaga
     ) subq
    ) AS media_candidatos_por_vaga

FROM vagas v
INNER JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
WHERE v.data_publicacao >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY cv.id_categoria, cv.nome_categoria, v.modalidade_trabalho
HAVING COUNT(*) >= 5  -- Pelo menos 5 vagas para ser significativo
ORDER BY cv.nome_categoria, 
         COUNT(*) DESC;

-- ============================================================================
-- 9. NETWORK ANALYSIS: CONEXÕES MAIS VALIOSAS
-- Descrição: Identifica usuários com maior potencial de networking
-- ============================================================================

WITH network_stats AS (
    SELECT 
        u.id_usuario,
        u.tipo_usuario,
        CASE 
            WHEN u.tipo_usuario = 'candidato' THEN c.nome_completo
            WHEN u.tipo_usuario = 'empresa' THEN e.nome_fantasia
            WHEN u.tipo_usuario = 'recrutador' THEN r.nome_completo
        END AS nome,
        
        -- Contadores de conexões
        COUNT(CASE WHEN con.status_conexao = 'aceita' THEN 1 END) AS conexoes_ativas,
        COUNT(CASE WHEN con.status_conexao = 'pendente' AND con.id_solicitante = u.id_usuario THEN 1 END) AS convites_enviados,
        COUNT(CASE WHEN con.status_conexao = 'pendente' AND con.id_receptor = u.id_usuario THEN 1 END) AS convites_recebidos,
        
        -- Diversidade de conexões
        COUNT(DISTINCT CASE WHEN con2.tipo_usuario != u.tipo_usuario THEN con2.tipo_usuario END) AS tipos_conexoes_diferentes,
        
        -- Atividade recente
        MAX(con.data_conexao) AS ultima_conexao
        
    FROM usuarios u
    LEFT JOIN candidatos c ON u.id_usuario = c.id_candidato
    LEFT JOIN empresas e ON u.id_usuario = e.id_empresa
    LEFT JOIN recrutadores r ON u.id_usuario = r.id_recrutador
    LEFT JOIN conexoes con ON (u.id_usuario = con.id_solicitante OR u.id_usuario = con.id_receptor)
    LEFT JOIN usuarios con2 ON (
        CASE 
            WHEN con.id_solicitante = u.id_usuario THEN con.id_receptor
            ELSE con.id_solicitante
        END = con2.id_usuario
    )
    GROUP BY u.id_usuario, u.tipo_usuario, nome
),
influenciadores AS (
    SELECT 
        ns.*,
        -- Score de influência
        (conexoes_ativas * 10 + 
         tipos_conexoes_diferentes * 5 + 
         CASE WHEN ultima_conexao >= CURRENT_DATE - INTERVAL '30 days' THEN 20 ELSE 0 END) AS score_influencia,
        
        -- Dados específicos por tipo
        CASE 
            WHEN ns.tipo_usuario = 'candidato' THEN 
                (SELECT STRING_AGG(h.nome_habilidade, ', ')
                 FROM candidatos_habilidades ch
                 INNER JOIN habilidades h ON ch.id_habilidade = h.id_habilidade
                 WHERE ch.id_candidato = ns.id_usuario
                 AND h.categoria = 'tecnica'
                 LIMIT 3)
            WHEN ns.tipo_usuario = 'empresa' THEN 
                (SELECT e2.setor_atividade FROM empresas e2 WHERE e2.id_empresa = ns.id_usuario)
            WHEN ns.tipo_usuario = 'recrutador' THEN 
                (SELECT e2.nome_fantasia FROM recrutadores r2 
                 INNER JOIN empresas e2 ON r2.id_empresa = e2.id_empresa 
                 WHERE r2.id_recrutador = ns.id_usuario)
        END AS info_adicional

    FROM network_stats ns
    WHERE conexoes_ativas >= 5  -- Pelo menos 5 conexões ativas
)
SELECT 
    tipo_usuario,
    nome,
    conexoes_ativas,
    tipos_conexoes_diferentes,
    score_influencia,
    info_adicional,
    ultima_conexao,
    
    -- Ranking dentro do tipo
    ROW_NUMBER() OVER (PARTITION BY tipo_usuario ORDER BY score_influencia DESC) AS ranking_no_tipo

FROM influenciadores
ORDER BY score_influencia DESC
LIMIT 20;

-- ============================================================================
-- 10. RELATÓRIO EXECUTIVO: MÉTRICAS GERAIS DO SISTEMA
-- Descrição: Dashboard executivo com KPIs principais
-- ============================================================================

WITH metricas_periodo AS (
    SELECT 
        -- Período de análise
        CURRENT_DATE - INTERVAL '30 days' AS inicio_periodo,
        CURRENT_DATE AS fim_periodo
),
kpis_principais AS (
    SELECT 
        -- Usuários
        COUNT(DISTINCT u.id_usuario) AS total_usuarios_ativos,
        COUNT(DISTINCT CASE WHEN u.tipo_usuario = 'candidato' THEN u.id_usuario END) AS total_candidatos,
        COUNT(DISTINCT CASE WHEN u.tipo_usuario = 'empresa' THEN u.id_usuario END) AS total_empresas,
        COUNT(DISTINCT CASE WHEN u.tipo_usuario = 'recrutador' THEN u.id_usuario END) AS total_recrutadores,
        
        -- Vagas
        COUNT(DISTINCT v.id_vaga) AS total_vagas_ativas,
        COUNT(DISTINCT CASE WHEN v.data_publicacao >= (SELECT inicio_periodo FROM metricas_periodo) THEN v.id_vaga END) AS vagas_publicadas_periodo,
        
        -- Candidaturas
        COUNT(DISTINCT c.id_candidatura) AS total_candidaturas,
        COUNT(DISTINCT CASE WHEN c.data_candidatura >= (SELECT inicio_periodo FROM metricas_periodo) THEN c.id_candidatura END) AS candidaturas_periodo,
        COUNT(DISTINCT CASE WHEN c.status_candidatura = 'aprovado' THEN c.id_candidatura END) AS total_contratacoes,
        
        -- Processos
        COUNT(DISTINCT ps.id_processo) AS total_processos,
        COUNT(DISTINCT CASE WHEN ps.status_processo = 'em_andamento' THEN ps.id_processo END) AS processos_em_andamento,
        
        -- Networking
        COUNT(DISTINCT con.id_conexao) AS total_conexoes_ativas
        
    FROM usuarios u
    LEFT JOIN vagas v ON (u.tipo_usuario = 'empresa' AND u.id_usuario = v.id_empresa)
                      OR (u.tipo_usuario = 'recrutador' AND u.id_usuario = v.id_recrutador)
    LEFT JOIN candidaturas c ON v.id_vaga = c.id_vaga
    LEFT JOIN processos_seletivos ps ON c.id_candidatura = ps.id_candidatura
    LEFT JOIN conexoes con ON (u.id_usuario = con.id_solicitante OR u.id_usuario = con.id_receptor)
                           AND con.status_conexao = 'aceita'
    WHERE (v.status_vaga = 'aberta' OR v.status_vaga IS NULL)
    AND u.status_conta = 'ativo'
),
tendencias AS (
    SELECT 
        -- Crescimento mensal de usuários
        COUNT(CASE WHEN u.data_cadastro >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS novos_usuarios_mes,
        COUNT(CASE WHEN u.data_cadastro >= CURRENT_DATE - INTERVAL '60 days' 
                   AND u.data_cadastro < CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS novos_usuarios_mes_anterior,
        
        -- Taxa de conversão (candidaturas para aprovações)
        CASE 
            WHEN COUNT(c.id_candidatura) > 0 THEN
                ROUND((COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
                       COUNT(c.id_candidatura)), 2)
            ELSE 0
        END AS taxa_conversao_geral,
        
        -- Tempo médio de processo
        ROUND(AVG(CASE WHEN ps.data_fim IS NOT NULL 
                      THEN EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio)) END), 1) AS tempo_medio_processo_dias,
        
        -- Salário médio das vagas
        ROUND(AVG(v.salario_max), 2) AS salario_medio_vagas
        
    FROM usuarios u
    LEFT JOIN candidaturas c ON u.tipo_usuario = 'candidato' AND u.id_usuario = c.id_candidato
    LEFT JOIN processos_seletivos ps ON c.id_candidatura = ps.id_candidatura
    LEFT JOIN vagas v ON c.id_vaga = v.id_vaga
    WHERE u.status_conta = 'ativo'
)
SELECT 
    'MÉTRICAS GERAIS DO SISTEMA' AS categoria,
    
    -- KPIs Principais
    kp.total_usuarios_ativos,
    kp.total_candidatos,
    kp.total_empresas,
    kp.total_recrutadores,
    kp.total_vagas_ativas,
    kp.total_candidaturas,
    kp.total_contratacoes,
    kp.total_conexoes_ativas,
    
    -- Atividade do Período (últimos 30 dias)
    kp.vagas_publicadas_periodo,
    kp.candidaturas_periodo,
    kp.processos_em_andamento,
    
    -- Tendências e Taxas
    t.novos_usuarios_mes,
    t.novos_usuarios_mes_anterior,
    CASE 
        WHEN t.novos_usuarios_mes_anterior > 0 THEN
            ROUND(((t.novos_usuarios_mes - t.novos_usuarios_mes_anterior) * 100.0 / 
                   t.novos_usuarios_mes_anterior), 2)
        ELSE 0
    END AS crescimento_usuarios_percent,
    
    t.taxa_conversao_geral,
    t.tempo_medio_processo_dias,
    t.salario_medio_vagas,
    
    -- Ratios importantes
    CASE 
        WHEN kp.total_empresas > 0 THEN
            ROUND((kp.total_vagas_ativas * 1.0 / kp.total_empresas), 2)
        ELSE 0
    END AS vagas_por_empresa,
    
    CASE 
        WHEN kp.total_vagas_ativas > 0 THEN
            ROUND((kp.total_candidaturas * 1.0 / kp.total_vagas_ativas), 2)
        ELSE 0
    END AS candidaturas_por_vaga,
    
    -- Status atual
    CURRENT_TIMESTAMP AS data_relatorio

FROM kpis_principais kp
CROSS JOIN tendencias t;

-- ============================================================================
-- FINALIZAÇÃO
-- ============================================================================

SELECT 'Consultas SQL criadas com sucesso!' as status,
       'Total: 10 consultas contextualizadas' as detalhes,
       'Funcionalidades: Rankings, análises, compatibilidade, tendências, métricas executivas' as recursos;
