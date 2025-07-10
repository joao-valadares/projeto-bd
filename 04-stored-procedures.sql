-- 1. FUNÇÃO: CADASTRAR CANDIDATO

CREATE OR REPLACE FUNCTION sp_cadastrar_candidato(
    p_email VARCHAR(255),
    p_senha VARCHAR(255),
    p_cpf VARCHAR(14),
    p_nome_completo VARCHAR(255),
    p_telefone VARCHAR(20) DEFAULT NULL,
    p_nivel_experiencia VARCHAR(20) DEFAULT 'junior'
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_usuario INTEGER;
BEGIN
    -- Valida se email já existe
    IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
        RAISE EXCEPTION 'Email já cadastrado no sistema';
    END IF;
    
    -- Insere usuário
    INSERT INTO usuarios (email, senha, tipo_usuario)
    VALUES (p_email, p_senha, 'candidato')
    RETURNING id_usuario INTO v_id_usuario;
    
    -- Insere candidato
    INSERT INTO candidatos (
        id_candidato, cpf, nome_completo, telefone, nivel_experiencia
    )
    VALUES (
        v_id_usuario, p_cpf, p_nome_completo, p_telefone, p_nivel_experiencia
    );
    
    RETURN v_id_usuario;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao cadastrar candidato: %', SQLERRM;
END;
$$;

-- 2. FUNÇÃO: BUSCAR VAGAS PARA CANDIDATO

CREATE OR REPLACE FUNCTION sp_buscar_vagas_candidato(
    p_id_candidato INTEGER,
    p_limite INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_vaga INTEGER,
    titulo VARCHAR(255),
    empresa VARCHAR(255),
    salario_max DECIMAL(10,2),
    modalidade_trabalho VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.id_vaga,
        v.titulo,
        e.nome_fantasia as empresa,
        v.salario_max,
        v.modalidade_trabalho
    FROM vagas v
    INNER JOIN empresas e ON v.id_empresa = e.id_empresa
    INNER JOIN candidatos c ON c.id_candidato = p_id_candidato
    WHERE v.status_vaga = 'aberta'
    AND v.data_expiracao >= CURRENT_DATE
    AND (v.nivel_experiencia = c.nivel_experiencia OR v.nivel_experiencia IS NULL)
    -- Não mostra vagas que o candidato já se candidatou
    AND NOT EXISTS (
        SELECT 1 FROM candidaturas ca 
        WHERE ca.id_vaga = v.id_vaga 
        AND ca.id_candidato = p_id_candidato
    )
    ORDER BY v.data_publicacao DESC
    LIMIT p_limite;
END;
$$;

-- 3. FUNÇÃO: CRIAR CANDIDATURA

CREATE OR REPLACE FUNCTION sp_criar_candidatura(
    p_id_candidato INTEGER,
    p_id_vaga INTEGER,
    p_carta_apresentacao TEXT DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_candidatura INTEGER;
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
    
    RETURN v_id_candidatura;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao registrar candidatura: %', SQLERRM;
END;
$$;


-- 4. FUNÇÃO: ATUALIZAR STATUS VAGA

CREATE OR REPLACE FUNCTION sp_atualizar_status_vaga(
    p_id_vaga INTEGER,
    p_novo_status VARCHAR(20)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verifica se a vaga existe
    IF NOT EXISTS (SELECT 1 FROM vagas WHERE id_vaga = p_id_vaga) THEN
        RAISE EXCEPTION 'Vaga não encontrada';
    END IF;
    
    -- Atualiza o status
    UPDATE vagas
    SET status_vaga = p_novo_status
    WHERE id_vaga = p_id_vaga;
    
    -- Se a vaga foi fechada, rejeita candidaturas pendentes
    IF p_novo_status = 'fechada' THEN
        UPDATE candidaturas
        SET status_candidatura = 'rejeitado'
        WHERE id_vaga = p_id_vaga
        AND status_candidatura = 'pendente';
    END IF;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao atualizar status da vaga: %', SQLERRM;
END;
$$;

-- 5. FUNÇÃO: APROVAR CANDIDATURA

CREATE OR REPLACE FUNCTION sp_aprovar_candidatura(
    p_id_candidatura INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verifica se a candidatura existe
    IF NOT EXISTS (SELECT 1 FROM candidaturas WHERE id_candidatura = p_id_candidatura) THEN
        RAISE EXCEPTION 'Candidatura não encontrada';
    END IF;
    
    -- Atualiza o status para aprovado
    UPDATE candidaturas
    SET status_candidatura = 'aprovado'
    WHERE id_candidatura = p_id_candidatura;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao aprovar candidatura: %', SQLERRM;
END;
$$;

-- 6. FUNÇÃO: RELATÓRIO CANDIDATO

CREATE OR REPLACE FUNCTION sp_relatorio_candidato(
    p_id_candidato INTEGER
)
RETURNS TABLE (
    total_candidaturas INTEGER,
    candidaturas_aprovadas INTEGER,
    candidaturas_rejeitadas INTEGER,
    taxa_aprovacao DECIMAL(5,2),
    ultima_candidatura DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_candidaturas,
        COUNT(CASE WHEN status_candidatura = 'aprovado' THEN 1 END)::INTEGER as candidaturas_aprovadas,
        COUNT(CASE WHEN status_candidatura = 'rejeitado' THEN 1 END)::INTEGER as candidaturas_rejeitadas,
        CASE 
            WHEN COUNT(*) > 0 THEN 
                (COUNT(CASE WHEN status_candidatura = 'aprovado' THEN 1 END) * 100.0 / COUNT(*))::DECIMAL(5,2)
            ELSE 0::DECIMAL(5,2)
        END as taxa_aprovacao,
        MAX(data_candidatura::DATE) as ultima_candidatura
    FROM candidaturas
    WHERE id_candidato = p_id_candidato;
END;
$$;

