-- 1. TOP 10 EMPRESAS COM MAIS VAGAS ABERTAS

SELECT 
    e.nome_fantasia AS empresa,
    e.setor_atividade,
    COUNT(v.id_vaga) AS total_vagas_abertas,
    ROUND(AVG(v.salario_max), 2) AS salario_medio_oferecido
FROM empresas e
INNER JOIN vagas v ON e.id_empresa = v.id_empresa
WHERE v.status_vaga = 'aberta'
AND v.data_expiracao >= CURRENT_DATE
GROUP BY e.id_empresa, e.nome_fantasia, e.setor_atividade
ORDER BY total_vagas_abertas DESC
LIMIT 10;

-- 2. CANDIDATOS MAIS ATIVOS (ÚLTIMOS 6 MESES)

SELECT 
    c.nome_completo AS candidato,
    c.nivel_experiencia,
    COUNT(cand.id_candidatura) AS total_candidaturas,
    COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) AS aprovacoes,
    ROUND((COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
           COUNT(cand.id_candidatura)), 1) AS taxa_sucesso_percent
FROM candidatos c
INNER JOIN candidaturas cand ON c.id_candidato = cand.id_candidato
WHERE cand.data_candidatura >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY c.id_candidato, c.nome_completo, c.nivel_experiencia
HAVING COUNT(cand.id_candidatura) >= 3
ORDER BY total_candidaturas DESC, taxa_sucesso_percent DESC
LIMIT 10;

-- 3. ANÁLISE DE SALÁRIOS POR ÁREA E NÍVEL

SELECT 
    cv.nome_categoria AS area,
    v.nivel_experiencia,
    COUNT(v.id_vaga) AS total_vagas,
    MIN(v.salario_min) AS menor_salario,
    MAX(v.salario_max) AS maior_salario,
    ROUND(AVG(v.salario_max), 2) AS media_salario_max,
    v.modalidade_trabalho AS modalidade_comum
FROM vagas v
INNER JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
WHERE v.salario_min IS NOT NULL 
AND v.salario_max IS NOT NULL
AND v.data_publicacao >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY cv.nome_categoria, v.nivel_experiencia, v.modalidade_trabalho
HAVING COUNT(v.id_vaga) >= 3
ORDER BY cv.nome_categoria, v.nivel_experiencia;

-- 4. PROCESSOS SELETIVOS - ANÁLISE DE EFICIÊNCIA

SELECT 
    e.nome_fantasia AS empresa,
    v.titulo AS vaga,
    COUNT(ps.id_processo) AS total_processos,
    ROUND(AVG(EXTRACT(DAY FROM (ps.data_fim - ps.data_inicio))), 1) AS tempo_medio_dias,
    COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) AS contratacoes,
    ROUND((COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
           COUNT(ps.id_processo)), 1) AS taxa_contratacao_percent
FROM vagas v
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN candidaturas c ON v.id_vaga = c.id_vaga
INNER JOIN processos_seletivos ps ON c.id_candidatura = ps.id_candidatura
WHERE ps.data_fim IS NOT NULL
AND ps.data_inicio >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY e.nome_fantasia, v.titulo
HAVING COUNT(ps.id_processo) >= 2
ORDER BY tempo_medio_dias DESC;

-- 5. HABILIDADES MAIS DEMANDADAS

SELECT 
    h.nome_habilidade AS habilidade,
    h.categoria,
    COUNT(DISTINCT vh.id_vaga) AS vagas_que_exigem,
    COUNT(CASE WHEN vh.obrigatoria = true THEN 1 END) AS vagas_obrigatorias,
    COUNT(DISTINCT ch.id_candidato) AS candidatos_que_possuem,
    ROUND(AVG(v.salario_max), 2) AS salario_medio_vagas
FROM habilidades h
LEFT JOIN vagas_habilidades vh ON h.id_habilidade = vh.id_habilidade
LEFT JOIN candidatos_habilidades ch ON h.id_habilidade = ch.id_habilidade
LEFT JOIN vagas v ON vh.id_vaga = v.id_vaga
WHERE v.data_publicacao >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY h.id_habilidade, h.nome_habilidade, h.categoria
HAVING COUNT(DISTINCT vh.id_vaga) > 0
ORDER BY vagas_que_exigem DESC
LIMIT 15;

-- 6. CANDIDATOS COMPATÍVEIS COM UMA VAGA ESPECÍFICA

SELECT 
    c.nome_completo AS candidato,
    c.nivel_experiencia,
    c.salario_pretendido,
    v.salario_max AS salario_oferecido,
    COUNT(DISTINCT ch.id_habilidade) AS habilidades_em_comum,
    COUNT(DISTINCT vh.id_habilidade) AS habilidades_necessarias,
    ROUND((COUNT(DISTINCT ch.id_habilidade) * 100.0 / 
           NULLIF(COUNT(DISTINCT vh.id_habilidade), 0)), 1) AS percentual_compatibilidade
FROM candidatos c
CROSS JOIN (SELECT 1 AS id_vaga_especifica) vaga_filtro  -- Altere o ID conforme necessário
INNER JOIN vagas v ON vaga_filtro.id_vaga_especifica = v.id_vaga
LEFT JOIN vagas_habilidades vh ON v.id_vaga = vh.id_vaga
LEFT JOIN candidatos_habilidades ch ON c.id_candidato = ch.id_candidato 
                                    AND vh.id_habilidade = ch.id_habilidade
WHERE c.disponibilidade = true
AND (c.salario_pretendido IS NULL OR c.salario_pretendido <= v.salario_max * 1.2)
AND NOT EXISTS (
    SELECT 1 FROM candidaturas cand 
    WHERE cand.id_candidato = c.id_candidato 
    AND cand.id_vaga = v.id_vaga
)
GROUP BY c.id_candidato, c.nome_completo, c.nivel_experiencia, 
         c.salario_pretendido, v.salario_max
HAVING COUNT(DISTINCT vh.id_habilidade) > 0  -- Apenas se a vaga tem habilidades definidas
ORDER BY percentual_compatibilidade DESC, c.nivel_experiencia DESC
LIMIT 10;

-- 7. EMPRESAS MAIS EFICIENTES EM CONTRATAÇÃO

SELECT 
    e.nome_fantasia AS empresa,
    e.setor_atividade,
    COUNT(DISTINCT c.id_candidatura) AS total_candidaturas,
    COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) AS contratacoes,
    ROUND((COUNT(CASE WHEN c.status_candidatura = 'aprovado' THEN 1 END) * 100.0 / 
           COUNT(c.id_candidatura)), 1) AS taxa_aprovacao_percent,
    ROUND(AVG(v.salario_max), 2) AS salario_medio_oferecido,
    COUNT(DISTINCT v.id_vaga) AS vagas_publicadas
FROM empresas e
INNER JOIN vagas v ON e.id_empresa = v.id_empresa
INNER JOIN candidaturas c ON v.id_vaga = c.id_vaga
WHERE c.data_candidatura >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY e.id_empresa, e.nome_fantasia, e.setor_atividade
HAVING COUNT(c.id_candidatura) >= 10  -- Pelo menos 10 candidaturas
ORDER BY taxa_aprovacao_percent DESC, contratacoes DESC
LIMIT 10;

-- 8. MODALIDADES DE TRABALHO POR CATEGORIA

SELECT 
    cv.nome_categoria AS categoria,
    v.modalidade_trabalho,
    COUNT(*) AS total_vagas,
    ROUND(AVG(v.salario_max), 2) AS salario_medio,
    ROUND((COUNT(*) * 100.0 / 
           SUM(COUNT(*)) OVER (PARTITION BY cv.nome_categoria)), 1) AS percentual_na_categoria
FROM vagas v
INNER JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
WHERE v.data_publicacao >= CURRENT_DATE - INTERVAL '6 months'
AND v.status_vaga = 'aberta'
GROUP BY cv.nome_categoria, v.modalidade_trabalho
HAVING COUNT(*) >= 2
ORDER BY cv.nome_categoria, total_vagas DESC;

-- 9. USUÁRIOS MAIS CONECTADOS NA REDE

SELECT 
    CASE 
        WHEN u.tipo_usuario = 'candidato' THEN c.nome_completo
        WHEN u.tipo_usuario = 'empresa' THEN e.nome_fantasia
        WHEN u.tipo_usuario = 'recrutador' THEN r.nome_completo
    END AS nome_usuario,
    u.tipo_usuario,
    COUNT(CASE WHEN con.status_conexao = 'aceita' THEN 1 END) AS conexoes_ativas,
    COUNT(CASE WHEN con.status_conexao = 'pendente' 
               AND con.id_solicitante = u.id_usuario THEN 1 END) AS convites_enviados,
    COUNT(CASE WHEN con.status_conexao = 'pendente' 
               AND con.id_receptor = u.id_usuario THEN 1 END) AS convites_recebidos,
    MAX(con.data_conexao) AS ultima_conexao
FROM usuarios u
LEFT JOIN candidatos c ON u.id_usuario = c.id_candidato
LEFT JOIN empresas e ON u.id_usuario = e.id_empresa
LEFT JOIN recrutadores r ON u.id_usuario = r.id_recrutador
LEFT JOIN conexoes con ON (u.id_usuario = con.id_solicitante 
                          OR u.id_usuario = con.id_receptor)
WHERE u.status_conta = 'ativo'
GROUP BY u.id_usuario, u.tipo_usuario, 
         c.nome_completo, e.nome_fantasia, r.nome_completo
HAVING COUNT(CASE WHEN con.status_conexao = 'aceita' THEN 1 END) >= 3
ORDER BY conexoes_ativas DESC
LIMIT 15;

-- 10. RESUMO GERAL DO SISTEMA

SELECT 
    -- Contadores básicos
    COUNT(DISTINCT u.id_usuario) AS total_usuarios,
    COUNT(DISTINCT CASE WHEN u.tipo_usuario = 'candidato' THEN u.id_usuario END) AS total_candidatos,
    COUNT(DISTINCT CASE WHEN u.tipo_usuario = 'empresa' THEN u.id_usuario END) AS total_empresas,
    COUNT(DISTINCT CASE WHEN u.tipo_usuario = 'recrutador' THEN u.id_usuario END) AS total_recrutadores,
    
    -- Vagas e candidaturas
    COUNT(DISTINCT v.id_vaga) AS vagas_ativas,
    COUNT(DISTINCT c.id_candidatura) AS total_candidaturas,
    COUNT(DISTINCT CASE WHEN c.status_candidatura = 'aprovado' THEN c.id_candidatura END) AS total_contratacoes,
    
    -- Taxas importantes
    ROUND((COUNT(DISTINCT CASE WHEN c.status_candidatura = 'aprovado' THEN c.id_candidatura END) * 100.0 / 
           NULLIF(COUNT(DISTINCT c.id_candidatura), 0)), 2) AS taxa_conversao_geral,
    
    -- Valores médios
    ROUND(AVG(v.salario_max), 2) AS salario_medio_vagas,
    ROUND((COUNT(DISTINCT c.id_candidatura) * 1.0 / 
           NULLIF(COUNT(DISTINCT v.id_vaga), 0)), 1) AS candidaturas_por_vaga,
    
    -- Atividade recente (últimos 30 dias)
    COUNT(DISTINCT CASE WHEN u.data_cadastro >= CURRENT_DATE - INTERVAL '30 days' 
                       THEN u.id_usuario END) AS novos_usuarios_mes,
    COUNT(DISTINCT CASE WHEN v.data_publicacao >= CURRENT_DATE - INTERVAL '30 days' 
                       THEN v.id_vaga END) AS novas_vagas_mes,
    COUNT(DISTINCT CASE WHEN c.data_candidatura >= CURRENT_DATE - INTERVAL '30 days' 
                       THEN c.id_candidatura END) AS candidaturas_mes,
    
    -- Data do relatório
    CURRENT_DATE AS data_relatorio
    
FROM usuarios u
LEFT JOIN vagas v ON (u.tipo_usuario = 'empresa' AND u.id_usuario = v.id_empresa)
                  OR (u.tipo_usuario = 'recrutador' AND u.id_usuario = v.id_recrutador)
LEFT JOIN candidaturas c ON v.id_vaga = c.id_vaga
WHERE u.status_conta = 'ativo'
AND (v.status_vaga = 'aberta' OR v.status_vaga IS NULL);