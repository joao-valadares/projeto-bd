-- 1. VIEW: CANDIDATOS POR VAGA COM STATUS DO PROCESSO

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

-- 2. VIEW: PERFIL COMPLETO DO CANDIDATO

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

-- 3. VIEW: RELATÓRIO DE PROCESSOS SELETIVOS


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

