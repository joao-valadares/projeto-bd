-- ============================================================================
-- SISTEMA DE RECRUTAMENTO - TRIGGERS
-- Banco de Dados: PostgreSQL
-- Descrição: Triggers para automatizações e regras de negócio
-- ============================================================================

-- ============================================================================
-- 1. TRIGGER: ATUALIZAÇÃO AUTOMÁTICA DE TIMESTAMP EM CURRÍCULOS
-- Descrição: Atualiza automaticamente data_atualizacao quando currículo é modificado
-- ============================================================================

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


-- ============================================================================
-- 2. TRIGGER: HISTÓRICO AUTOMÁTICO DE STATUS DE CANDIDATURAS
-- Descrição: Registra automaticamente mudanças de status em candidaturas
-- ============================================================================

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

-- ============================================================================
-- 3. TRIGGER: VALIDAÇÃO DE EXPERIÊNCIA PROFISSIONAL
-- Descrição: Valida datas e consistência de experiências profissionais
-- ============================================================================

-- Função do trigger para validação de experiência
CREATE OR REPLACE FUNCTION trg_validar_experiencia_profissional()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Valida se data de início não é no futuro
    IF NEW.data_inicio > CURRENT_DATE THEN
        RAISE EXCEPTION 'Data de início da experiência não pode ser no futuro';
    END IF;
    
    -- Se não é emprego atual, deve ter data de fim
    IF NEW.emprego_atual = false AND NEW.data_fim IS NULL THEN
        RAISE EXCEPTION 'Experiências que não são emprego atual devem ter data de fim';
    END IF;
    
    -- Se é emprego atual, não pode ter data de fim
    IF NEW.emprego_atual = true AND NEW.data_fim IS NOT NULL THEN
        RAISE EXCEPTION 'Emprego atual não pode ter data de fim';
    END IF;
    
    -- Valida se existe apenas um emprego atual por currículo
    IF NEW.emprego_atual = true THEN
        IF EXISTS (
            SELECT 1 
            FROM experiencias_profissionais ep
            WHERE ep.id_curriculo = NEW.id_curriculo
            AND ep.emprego_atual = true
            AND ep.id_experiencia != COALESCE(NEW.id_experiencia, -1)
        ) THEN
            RAISE EXCEPTION 'Apenas uma experiência pode ser marcada como emprego atual';
        END IF;
    END IF;
    
    -- Valida se data de fim é posterior à data de início
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        RAISE EXCEPTION 'Data de fim deve ser posterior à data de início';
    END IF;
    
    RETURN NEW;
END;
$$;

-- Criação do trigger
CREATE TRIGGER trigger_validar_experiencia
    BEFORE INSERT OR UPDATE ON experiencias_profissionais
    FOR EACH ROW
    EXECUTE FUNCTION trg_validar_experiencia_profissional();


-- ============================================================================
-- 4. TRIGGER: ATUALIZAÇÃO DE ÚLTIMO LOGIN
-- Descrição: Atualiza automaticamente o campo ultimo_login ao fazer login
-- ============================================================================

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


-- ============================================================================
-- 5. TRIGGER: CONTROLE DE VAGAS EXPIRADAS
-- Descrição: Atualiza automaticamente status de vagas expiradas
-- ============================================================================

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


-- ============================================================================
-- 6. TRIGGER: VALIDAÇÃO DE CONEXÕES DUPLICADAS
-- Descrição: Evita conexões duplicadas e bidirecionais
-- ============================================================================

-- Função do trigger para validar conexões
CREATE OR REPLACE FUNCTION trg_validar_conexoes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Não permite conexão consigo mesmo
    IF NEW.id_solicitante = NEW.id_receptor THEN
        RAISE EXCEPTION 'Usuário não pode se conectar com ele mesmo';
    END IF;
    
    -- Verifica se já existe conexão no sentido inverso
    IF EXISTS (
        SELECT 1 FROM conexoes
        WHERE id_solicitante = NEW.id_receptor
        AND id_receptor = NEW.id_solicitante
        AND status_conexao IN ('pendente', 'aceita')
    ) THEN
        RAISE EXCEPTION 'Conexão já existe no sentido inverso';
    END IF;
    
    -- Verifica se já existe conexão no mesmo sentido
    IF EXISTS (
        SELECT 1 FROM conexoes
        WHERE id_solicitante = NEW.id_solicitante
        AND id_receptor = NEW.id_receptor
        AND id_conexao != COALESCE(NEW.id_conexao, -1)
        AND status_conexao IN ('pendente', 'aceita')
    ) THEN
        RAISE EXCEPTION 'Conexão já existe entre estes usuários';
    END IF;
    
    RETURN NEW;
END;
$$;

-- Criação do trigger
CREATE TRIGGER trigger_validar_conexoes
    BEFORE INSERT OR UPDATE ON conexoes
    FOR EACH ROW
    EXECUTE FUNCTION trg_validar_conexoes();


-- ============================================================================
-- 7. FUNÇÃO AUXILIAR: EXECUTAR VERIFICAÇÃO DIÁRIA DE VAGAS EXPIRADAS
-- Descrição: Função para ser executada diariamente via cron job
-- ============================================================================

CREATE OR REPLACE FUNCTION sp_processar_vagas_expiradas()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_vagas_atualizadas INTEGER := 0;
BEGIN
    -- Atualiza vagas expiradas que ainda estão abertas
    WITH vagas_para_fechar AS (
        UPDATE vagas
        SET status_vaga = 'fechada'
        WHERE data_expiracao < CURRENT_DATE
        AND status_vaga = 'aberta'
        RETURNING id_vaga, id_empresa
    )
    SELECT COUNT(*) INTO v_vagas_atualizadas FROM vagas_para_fechar;
    
    -- Atualiza candidaturas das vagas fechadas
    UPDATE candidaturas
    SET status_candidatura = 'rejeitado'
    WHERE id_vaga IN (
        SELECT id_vaga FROM vagas
        WHERE data_expiracao < CURRENT_DATE
        AND status_vaga = 'fechada'
    )
    AND status_candidatura IN ('pendente', 'em_analise');
    
    -- Registra no histórico
    IF v_vagas_atualizadas > 0 THEN
        INSERT INTO historico_status (
            tabela_origem,
            id_registro,
            status_novo,
            data_mudanca,
            motivo
        ) VALUES (
            'sistema',
            0,
            'processamento_concluido',
            CURRENT_TIMESTAMP,
            format('Processadas %s vagas expiradas automaticamente', v_vagas_atualizadas)
        );
    END IF;
    
    RETURN v_vagas_atualizadas;
END;
$$;


-- ============================================================================
-- 8. EXEMPLOS DE TESTE DOS TRIGGERS
-- ============================================================================

/*
-- Teste 1: Trigger de atualização de currículo
UPDATE curriculos SET resumo_profissional = 'Novo resumo' WHERE id_curriculo = 1;
SELECT data_atualizacao FROM curriculos WHERE id_curriculo = 1;

-- Teste 2: Trigger de histórico de candidatura
UPDATE candidaturas SET status_candidatura = 'em_analise' WHERE id_candidatura = 1;
SELECT * FROM historico_status WHERE tabela_origem = 'candidaturas' ORDER BY data_mudanca DESC LIMIT 5;

-- Teste 3: Processamento de vagas expiradas
SELECT sp_processar_vagas_expiradas();
*/

-- ============================================================================
-- 9. TRIGGER PARA AUDITORIA GERAL (BONUS)
-- Descrição: Trigger genérico de auditoria para tabelas importantes
-- ============================================================================

-- Função de auditoria geral
CREATE OR REPLACE FUNCTION trg_auditoria_geral()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_operacao VARCHAR(10);
    v_dados_antigos JSONB;
    v_dados_novos JSONB;
BEGIN
    -- Determina o tipo de operação
    IF TG_OP = 'DELETE' THEN
        v_operacao = 'DELETE';
        v_dados_antigos = to_jsonb(OLD);
        v_dados_novos = NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        v_operacao = 'UPDATE';
        v_dados_antigos = to_jsonb(OLD);
        v_dados_novos = to_jsonb(NEW);
    ELSIF TG_OP = 'INSERT' THEN
        v_operacao = 'INSERT';
        v_dados_antigos = NULL;
        v_dados_novos = to_jsonb(NEW);
    END IF;
    
    -- Registra a operação (simplificado - em produção seria uma tabela de auditoria específica)
    INSERT INTO historico_status (
        tabela_origem,
        id_registro,
        status_anterior,
        status_novo,
        data_mudanca,
        motivo
    ) VALUES (
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.id_vaga::TEXT
            ELSE NEW.id_vaga::TEXT
        END::INTEGER,
        v_operacao || '_old',
        v_operacao || '_new',
        CURRENT_TIMESTAMP,
        format('Operação %s na tabela %s', v_operacao, TG_TABLE_NAME)
    );
    
    -- Retorna o registro apropriado
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

-- Aplica auditoria na tabela de vagas (exemplo)
CREATE TRIGGER trigger_auditoria_vagas
    AFTER INSERT OR UPDATE OR DELETE ON vagas
    FOR EACH ROW
    EXECUTE FUNCTION trg_auditoria_geral();

-- ============================================================================
-- FINALIZAÇÃO
-- ============================================================================

SELECT 'Triggers criados com sucesso!' as status,
       'Total: 8 triggers implementados' as detalhes,
       'Funcionalidades: Timestamps automáticos, Histórico, Validações, Controle de expiração' as recursos;
