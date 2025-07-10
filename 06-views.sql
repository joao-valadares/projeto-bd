-- 1. VIEW: CANDIDATOS POR VAGA

CREATE OR REPLACE VIEW vw_candidatos_por_vaga AS
SELECT 
    v.id_vaga,
    v.titulo AS titulo_vaga,
    e.nome_fantasia AS empresa,
    c.id_candidato,
    c.nome_completo AS candidato,
    u.email,
    c.telefone,
    c.nivel_experiencia,
    cand.data_candidatura,
    cand.status_candidatura
FROM vagas v
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN candidaturas cand ON v.id_vaga = cand.id_vaga
INNER JOIN candidatos c ON cand.id_candidato = c.id_candidato
INNER JOIN usuarios u ON c.id_candidato = u.id_usuario
ORDER BY v.id_vaga, cand.data_candidatura;

-- 2. VIEW: VAGAS ABERTAS DETALHADAS

CREATE OR REPLACE VIEW vw_vagas_abertas AS
SELECT 
    v.id_vaga,
    v.titulo,
    e.nome_fantasia AS empresa,
    e.setor_atividade,
    cv.nome_categoria AS categoria,
    v.descricao,
    v.nivel_experiencia,
    v.salario_min,
    v.salario_max,
    v.modalidade_trabalho,
    v.tipo_contrato,
    v.data_publicacao,
    v.data_expiracao,
    COUNT(c.id_candidatura) AS total_candidaturas
FROM vagas v
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN categorias_vaga cv ON v.id_categoria = cv.id_categoria
LEFT JOIN candidaturas c ON v.id_vaga = c.id_vaga
WHERE v.status_vaga = 'aberta'
AND v.data_expiracao >= CURRENT_DATE
GROUP BY v.id_vaga, v.titulo, e.nome_fantasia, e.setor_atividade, 
         cv.nome_categoria, v.descricao, v.nivel_experiencia,
         v.salario_min, v.salario_max, v.modalidade_trabalho,
         v.tipo_contrato, v.data_publicacao, v.data_expiracao
ORDER BY v.data_publicacao DESC;

-- 3. VIEW: PERFIL BÁSICO DO CANDIDATO

CREATE OR REPLACE VIEW vw_perfil_candidato AS
SELECT 
    c.id_candidato,
    c.nome_completo,
    u.email,
    c.telefone,
    c.nivel_experiencia,
    c.salario_pretendido,
    c.disponibilidade,
    u.data_cadastro,
    COUNT(cand.id_candidatura) AS total_candidaturas,
    COUNT(CASE WHEN cand.status_candidatura = 'aprovado' THEN 1 END) AS candidaturas_aprovadas,
    COUNT(CASE WHEN cand.status_candidatura = 'rejeitado' THEN 1 END) AS candidaturas_rejeitadas,
    MAX(cand.data_candidatura) AS ultima_candidatura
FROM candidatos c
INNER JOIN usuarios u ON c.id_candidato = u.id_usuario
LEFT JOIN candidaturas cand ON c.id_candidato = cand.id_candidato
WHERE u.status_conta = 'ativo'
GROUP BY c.id_candidato, c.nome_completo, u.email, c.telefone,
         c.nivel_experiencia, c.salario_pretendido, c.disponibilidade,
         u.data_cadastro
ORDER BY c.nome_completo;

-- 4. VIEW: PROCESSOS SELETIVOS ATIVOS

CREATE OR REPLACE VIEW vw_processos_ativos AS
SELECT 
    ps.id_processo,
    v.titulo AS vaga,
    e.nome_fantasia AS empresa,
    c.nome_completo AS candidato,
    cand.data_candidatura,
    ps.data_inicio,
    ps.status_processo,
    (CURRENT_DATE - ps.data_inicio::DATE) AS dias_em_processo
FROM processos_seletivos ps
INNER JOIN candidaturas cand ON ps.id_candidatura = cand.id_candidatura
INNER JOIN vagas v ON cand.id_vaga = v.id_vaga
INNER JOIN empresas e ON v.id_empresa = e.id_empresa
INNER JOIN candidatos c ON cand.id_candidato = c.id_candidato
WHERE ps.status_processo = 'em_andamento'
ORDER BY ps.data_inicio;


