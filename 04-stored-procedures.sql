-- ============================================================================
-- 1. FUNÇÃO: CADASTRAR CANDIDATO COMPLETO
-- Descrição: Cadastra um candidato com usuário, dados pessoais e currículo
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_cadastrar_candidato(
    p_email VARCHAR(255),
    p_senha VARCHAR(255),
    p_cpf VARCHAR(14),
    p_nome_completo VARCHAR(255),
    p_data_nascimento DATE DEFAULT NULL,
    p_telefone VARCHAR(20) DEFAULT NULL,
    p_endereco TEXT DEFAULT NULL,
    p_linkedin_url VARCHAR(255) DEFAULT NULL,
    p_github_url VARCHAR(255) DEFAULT NULL,
    p_nivel_experiencia VARCHAR(20) DEFAULT 'junior',
    p_salario_pretendido DECIMAL(10,2) DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_usuario INTEGER;
    v_id_candidato INTEGER;
    v_id_curriculo INTEGER;
BEGIN
    -- Valida se email já existe
    IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email já cadastrado no sistema';
    END IF;
    
    -- Valida se CPF já existe
    IF EXISTS (SELECT 1 FROM candidatos WHERE cpf = p_cpf) THEN
        RAISE EXCEPTION 'CPF já cadastrado no sistema';
    END IF;
    
    -- Insere usuário
    INSERT INTO usuarios (email, senha, tipo_usuario)
    VALUES (p_email, p_senha, 'candidato')
    RETURNING id_usuario INTO v_id_usuario;
    
    -- Insere candidato
    INSERT INTO candidatos (
        id_candidato, cpf, nome_completo, data_nascimento, 
        telefone, endereco, linkedin_url, github_url, 
        nivel_experiencia, salario_pretendido
    )
    VALUES (
        v_id_usuario, p_cpf, p_nome_completo, p_data_nascimento,
        p_telefone, p_endereco, p_linkedin_url, p_github_url,
        p_nivel_experiencia, p_salario_pretendido
    )
    RETURNING id_candidato INTO v_id_candidato;
    
    -- Cria currículo básico
    INSERT INTO curriculos (id_candidato)
    VALUES (v_id_candidato)
    RETURNING id_curriculo INTO v_id_curriculo;
    
    -- Log da operação
    INSERT INTO historico_status (
        tabela_origem, id_registro, status_novo, 
        id_usuario_responsavel, motivo
    )
    VALUES (
        'candidatos', v_id_candidato, 'cadastrado',
        v_id_usuario, 'Cadastro inicial do candidato'
    );
    
    RETURN v_id_candidato;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, rollback automático
        RAISE EXCEPTION 'Erro ao cadastrar candidato: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 2. FUNÇÃO: BUSCAR VAGAS COMPATÍVEIS
-- Descrição: Busca vagas compatíveis com o perfil do candidato
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_buscar_vagas_compativeis(
    p_id_candidato INTEGER,
    p_limite INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_vaga INTEGER,
    titulo VARCHAR(255),
    empresa VARCHAR(255),
    salario_min DECIMAL(10,2),
    salario_max DECIMAL(10,2),
    modalidade_trabalho VARCHAR(20),
    compatibilidade_percent DECIMAL(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH candidato_info AS (
        SELECT 
            c.nivel_experiencia,
            c.salario_pretendido
        FROM candidatos c
        WHERE c.id_candidato = p_id_candidato
    ),
    candidato_habilidades AS (
        SELECT ch.id_habilidade
        FROM candidatos_habilidades ch
        WHERE ch.id_candidato = p_id_candidato
    ),
    vaga_compatibilidade AS (
        SELECT 
            v.id_vaga,
            v.titulo,
            e.nome_fantasia as empresa,
            v.salario_min,
            v.salario_max,
            v.modalidade_trabalho,
            -- Calcula compatibilidade baseada em habilidades
            CASE 
                WHEN COUNT(vh.id_habilidade) = 0 THEN 50.0 -- Vagas sem habilidades específicas
                ELSE (COUNT(ch.id_habilidade) * 100.0 / COUNT(vh.id_habilidade))
            END as compatibilidade_percent
        FROM vagas v
        INNER JOIN empresas e ON v.id_empresa = e.id_empresa
        CROSS JOIN candidato_info ci
        LEFT JOIN vagas_habilidades vh ON v.id_vaga = vh.id_vaga
        LEFT JOIN candidato_habilidades ch ON vh.id_habilidade = ch.id_habilidade
        WHERE v.status_vaga = 'aberta'
        AND v.data_expiracao >= CURRENT_DATE
        AND (v.nivel_experiencia = ci.nivel_experiencia OR v.nivel_experiencia IS NULL)
        AND (ci.salario_pretendido IS NULL OR v.salario_max >= ci.salario_pretendido OR v.salario_max IS NULL)
        -- Não mostra vagas que o candidato já se candidatou
        AND NOT EXISTS (
            SELECT 1 FROM candidaturas ca 
            WHERE ca.id_vaga = v.id_vaga 
            AND ca.id_candidato = p_id_candidato
        )
        GROUP BY v.id_vaga, v.titulo, e.nome_fantasia, v.salario_min, v.salario_max, v.modalidade_trabalho
    )
    SELECT 
        vc.id_vaga,
        vc.titulo,
        vc.empresa,
        vc.salario_min,
        vc.salario_max,
        vc.modalidade_trabalho,
        vc.compatibilidade_percent
    FROM vaga_compatibilidade vc
    ORDER BY vc.compatibilidade_percent DESC, vc.salario_max DESC
    LIMIT p_limite;
END;
$$;

-- ============================================================================
-- 3. FUNÇÃO: REGISTRAR CANDIDATURA
-- Descrição: Registra uma candidatura e inicia o processo seletivo
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_registrar_candidatura(
    p_id_candidato INTEGER,
    p_id_vaga INTEGER,
    p_carta_apresentacao TEXT DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_candidatura INTEGER;
    v_id_processo INTEGER;
    v_primeira_etapa INTEGER;
BEGIN
    -- Verifica se a vaga está aberta
    IF NOT EXISTS (
        SELECT 1 FROM vagas 
        WHERE id_vaga = p_id_vaga 
        AND status_vaga = 'aberta' 
        AND data_expiracao >= CURRENT_DATE
    ) THEN
        RAISE EXCEPTION 'Vaga não está disponível para candidatura';
    END IF;
    
    -- Verifica se já não se candidatou
    IF EXISTS (
        SELECT 1 FROM candidaturas 
        WHERE id_candidato = p_id_candidato 
        AND id_vaga = p_id_vaga
    ) THEN
        RAISE EXCEPTION 'Candidato já se candidatou para esta vaga';
    END IF;
    
    -- Registra a candidatura
    INSERT INTO candidaturas (
        id_candidato, id_vaga, carta_apresentacao
    )
    VALUES (
        p_id_candidato, p_id_vaga, p_carta_apresentacao
    )
    RETURNING id_candidatura INTO v_id_candidatura;
    
    -- Busca a primeira etapa do processo
    SELECT id_etapa INTO v_primeira_etapa
    FROM etapas_processo
    ORDER BY ordem_execucao
    LIMIT 1;
    
    -- Inicia o processo seletivo
    INSERT INTO processos_seletivos (
        id_candidatura, etapa_atual
    )
    VALUES (
        v_id_candidatura, v_primeira_etapa
    )
    RETURNING id_processo INTO v_id_processo;
    
    -- Log da operação
    INSERT INTO historico_status (
        tabela_origem, id_registro, status_novo,
        id_usuario_responsavel, motivo
    )
    VALUES (
        'candidaturas', v_id_candidatura, 'pendente',
        p_id_candidato, 'Nova candidatura registrada'
    );
    
    RETURN v_id_candidatura;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao registrar candidatura: %', SQLERRM;
END;
$$;


-- ============================================================================
-- 4. FUNÇÃO: ATUALIZAR STATUS VAGA
-- Descrição: Atualiza o status de uma vaga e gera histórico
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_atualizar_status_vaga(
    p_id_vaga INTEGER,
    p_novo_status VARCHAR(20),
    p_id_usuario_responsavel INTEGER,
    p_motivo TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_anterior VARCHAR(20);
    v_empresa_vaga INTEGER;
BEGIN
    -- Busca o status atual e verifica se o usuário tem permissão
    SELECT v.status_vaga, v.id_empresa
    INTO v_status_anterior, v_empresa_vaga
    FROM vagas v
    WHERE v.id_vaga = p_id_vaga;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Vaga não encontrada';
    END IF;
    
    -- Verifica se o usuário é da empresa ou recrutador da vaga
    IF NOT EXISTS (
        SELECT 1 FROM empresas e
        WHERE e.id_empresa = v_empresa_vaga
        AND e.id_empresa = p_id_usuario_responsavel
    ) AND NOT EXISTS (
        SELECT 1 FROM recrutadores r
        INNER JOIN vagas v ON r.id_recrutador = v.id_recrutador
        WHERE v.id_vaga = p_id_vaga
        AND r.id_recrutador = p_id_usuario_responsavel
    ) THEN
        RAISE EXCEPTION 'Usuário não tem permissão para alterar esta vaga';
    END IF;
    
    -- Atualiza o status
    UPDATE vagas
    SET status_vaga = p_novo_status
    WHERE id_vaga = p_id_vaga;
    
    -- Registra no histórico
    INSERT INTO historico_status (
        tabela_origem, id_registro, status_anterior, status_novo,
        id_usuario_responsavel, motivo
    )
    VALUES (
        'vagas', p_id_vaga, v_status_anterior, p_novo_status,
        p_id_usuario_responsavel, p_motivo
    );
    
    -- Se a vaga foi fechada, atualiza candidaturas pendentes
    IF p_novo_status = 'fechada' THEN
        UPDATE candidaturas
        SET status_candidatura = 'rejeitado'
        WHERE id_vaga = p_id_vaga
        AND status_candidatura IN ('pendente', 'em_analise');
    END IF;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao atualizar status da vaga: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 5. FUNÇÃO: APROVAR EMPRESA
-- Descrição: Aprova uma empresa para publicar vagas (workflow de aprovação)
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_aprovar_empresa(
    p_id_empresa INTEGER,
    p_id_admin INTEGER,
    p_observacoes TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_atual VARCHAR(20);
BEGIN
    -- Verifica se o admin tem permissão (simplificado - em prod seria mais complexo)
    IF NOT EXISTS (
        SELECT 1 FROM usuarios 
        WHERE id_usuario = p_id_admin 
        AND tipo_usuario = 'recrutador' -- Assumindo que recrutadores podem aprovar
    ) THEN
        RAISE EXCEPTION 'Usuário não tem permissão para aprovar empresas';
    END IF;
    
    -- Busca status atual da empresa
    SELECT status_conta INTO v_status_atual
    FROM usuarios u
    INNER JOIN empresas e ON u.id_usuario = e.id_empresa
    WHERE e.id_empresa = p_id_empresa;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Empresa não encontrada';
    END IF;
    
    -- Ativa a conta da empresa
    UPDATE usuarios
    SET status_conta = 'ativo'
    WHERE id_usuario = p_id_empresa;
    
    -- Registra no histórico
    INSERT INTO historico_status (
        tabela_origem, id_registro, status_anterior, status_novo,
        id_usuario_responsavel, motivo
    )
    VALUES (
        'empresas', p_id_empresa, v_status_atual, 'ativo',
        p_id_admin, COALESCE(p_observacoes, 'Empresa aprovada para publicar vagas')
    );
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao aprovar empresa: %', SQLERRM;
END;
$$;

-- ============================================================================
-- 6. FUNÇÃO: ESTATÍSTICAS DO CANDIDATO
-- Descrição: Retorna estatísticas completas de um candidato
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_estatisticas_candidato(
    p_id_candidato INTEGER
)
RETURNS TABLE (
    total_candidaturas INTEGER,
    candidaturas_aprovadas INTEGER,
    candidaturas_rejeitadas INTEGER,
    candidaturas_em_processo INTEGER,
    taxa_aprovacao DECIMAL(5,2),
    ultima_candidatura DATE,
    total_conexoes INTEGER,
    visualizacoes_perfil INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH estatisticas AS (
        SELECT 
            COUNT(*) as total_candidaturas,
            COUNT(CASE WHEN status_candidatura = 'aprovado' THEN 1 END) as candidaturas_aprovadas,
            COUNT(CASE WHEN status_candidatura = 'rejeitado' THEN 1 END) as candidaturas_rejeitadas,
            COUNT(CASE WHEN status_candidatura IN ('em_processo', 'em_analise') THEN 1 END) as candidaturas_em_processo,
            MAX(data_candidatura::DATE) as ultima_candidatura
        FROM candidaturas
        WHERE id_candidato = p_id_candidato
    ),
    conexoes_info AS (
        SELECT COUNT(*) as total_conexoes
        FROM conexoes
        WHERE (id_solicitante = p_id_candidato OR id_receptor = p_id_candidato)
        AND status_conexao = 'aceita'
    )
    SELECT 
        e.total_candidaturas::INTEGER,
        e.candidaturas_aprovadas::INTEGER,
        e.candidaturas_rejeitadas::INTEGER,
        e.candidaturas_em_processo::INTEGER,
        CASE 
            WHEN e.total_candidaturas > 0 THEN 
                (e.candidaturas_aprovadas * 100.0 / e.total_candidaturas)::DECIMAL(5,2)
            ELSE 0::DECIMAL(5,2)
        END as taxa_aprovacao,
        e.ultima_candidatura,
        c.total_conexoes::INTEGER,
        0::INTEGER as visualizacoes_perfil
    FROM estatisticas e
    CROSS JOIN conexoes_info c;
END;
$$;

SELECT 'Stored Procedures criadas com sucesso!' as status,
       'Total: 6 funções implementadas' as detalhes;
