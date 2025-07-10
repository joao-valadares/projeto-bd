-- 1. TRIGGER: ATUALIZAÇÃO AUTOMÁTICA DE TIMESTAMP EM CURRÍCULOS

-- Função do trigger
CREATE OR REPLACE FUNCTION trg_atualizar_data_curriculo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza a data de atualização para o timestamp atual
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Criação do trigger
CREATE TRIGGER trigger_atualizar_curriculo
    BEFORE UPDATE ON curriculos
    FOR EACH ROW
    EXECUTE FUNCTION trg_atualizar_data_curriculo();

COMMENT ON FUNCTION trg_atualizar_data_curriculo IS 'Atualiza timestamp de modificação do currículo';


-- 2. TRIGGER: HISTÓRICO AUTOMÁTICO DE STATUS DE CANDIDATURAS

-- Função do trigger para histórico de candidaturas
CREATE OR REPLACE FUNCTION trg_historico_status_candidatura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Só registra se o status realmente mudou
    IF OLD.status_candidatura IS DISTINCT FROM NEW.status_candidatura THEN
        INSERT INTO historico_status (
            tabela_origem,
            id_registro,
            status_anterior,
            status_novo,
            data_mudanca,
            motivo
        ) VALUES (
            'candidaturas',
            NEW.id_candidatura,
            OLD.status_candidatura,
            NEW.status_candidatura,
            CURRENT_TIMESTAMP,
            'Mudança automática de status de candidatura'
        );
        
        -- Atualiza o status do processo seletivo correspondente
        UPDATE processos_seletivos
        SET status_processo = CASE 
            WHEN NEW.status_candidatura = 'aprovado' THEN 'concluido'
            WHEN NEW.status_candidatura = 'rejeitado' THEN 'concluido'
            WHEN NEW.status_candidatura = 'desistiu' THEN 'cancelado'
            WHEN NEW.status_candidatura = 'em_processo' THEN 'em_andamento'
            ELSE status_processo
        END
        WHERE id_candidatura = NEW.id_candidatura;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Criação do trigger
CREATE TRIGGER trigger_historico_candidatura
    AFTER UPDATE ON candidaturas
    FOR EACH ROW
    EXECUTE FUNCTION trg_historico_status_candidatura();


-- 3. TRIGGER: ATUALIZAÇÃO DE ÚLTIMO LOGIN

-- Função do trigger para último login
CREATE OR REPLACE FUNCTION trg_atualizar_ultimo_login()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Este trigger seria acionado por uma função de login
    -- Aqui simula a atualização quando o último login muda
    IF OLD.ultimo_login IS DISTINCT FROM NEW.ultimo_login AND NEW.ultimo_login IS NOT NULL THEN
        -- Log de acesso (opcional)
        INSERT INTO historico_status (
            tabela_origem,
            id_registro,
            status_novo,
            data_mudanca,
            motivo
        ) VALUES (
            'usuarios',
            NEW.id_usuario,
            'login_realizado',
            NEW.ultimo_login,
            'Login do usuário registrado automaticamente'
        );
    END IF;
    
    RETURN NEW;
END;
$$;

-- Criação do trigger
CREATE TRIGGER trigger_ultimo_login
    AFTER UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION trg_atualizar_ultimo_login();


-- 4. TRIGGER: CONTROLE DE VAGAS EXPIRADAS

-- Função do trigger para vagas expiradas
CREATE OR REPLACE FUNCTION trg_controlar_vagas_expiradas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verifica se a data de expiração passou e a vaga ainda está aberta
    IF NEW.data_expiracao < CURRENT_DATE AND NEW.status_vaga = 'aberta' THEN
        NEW.status_vaga = 'fechada';
        
        -- Registra no histórico
        INSERT INTO historico_status (
            tabela_origem,
            id_registro,
            status_anterior,
            status_novo,
            data_mudanca,
            motivo
        ) VALUES (
            'vagas',
            NEW.id_vaga,
            'aberta',
            'fechada',
            CURRENT_TIMESTAMP,
            'Vaga fechada automaticamente por expiração'
        );
        
        -- Atualiza candidaturas pendentes desta vaga
        UPDATE candidaturas
        SET status_candidatura = 'rejeitado'
        WHERE id_vaga = NEW.id_vaga
        AND status_candidatura IN ('pendente', 'em_analise');
    END IF;
    
    RETURN NEW;
END;
$$;

-- Criação do trigger
CREATE TRIGGER trigger_vagas_expiradas
    BEFORE UPDATE ON vagas
    FOR EACH ROW
    EXECUTE FUNCTION trg_controlar_vagas_expiradas();

-- Trigger também para verificação durante INSERT
CREATE TRIGGER trigger_vagas_expiradas_insert
    BEFORE INSERT ON vagas
    FOR EACH ROW
    EXECUTE FUNCTION trg_controlar_vagas_expiradas();