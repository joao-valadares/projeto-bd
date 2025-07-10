-- =============================-- ============================================================================
-- 1. CATEGORIAS DE VAGA (dados básicos do sistema)
-- ============================================================================

-- NOTA: As categorias principais já estão inseridas no schema (03-implementacao-sql.sql)
-- Adicionando apenas categorias extras para complementar os testes

INSERT INTO categorias_vaga (nome_categoria, descricao) VALUES
('Design', 'Vagas de design gráfico, UX/UI e criação'),
('Operações', 'Vagas operacionais e de logística');
-- ===================================
-- SISTEMA DE RECRUTAMENTO - DADOS DE TESTE
-- Banco de Dados: PostgreSQL
-- Descrição: Script para popular a base com dados realistas para testes
-- Objetivo: Permitir execução de todas as consultas do arquivo 07-consultas.sql
-- ============================================================================

-- ============================================================================
-- LIMPEZA INICIAL (OPCIONAL - DESCOMENTE SE NECESSÁRIO)
-- ============================================================================

-- COMENTADO PARA EVITAR REMOVER DADOS BÁSICOS DO SCHEMA
-- DESCOMENTE APENAS SE QUISER LIMPAR COMPLETAMENTE A BASE

/*
TRUNCATE TABLE avaliacoes_candidatos CASCADE;
TRUNCATE TABLE processos_seletivos CASCADE;
TRUNCATE TABLE candidaturas CASCADE;
TRUNCATE TABLE vagas_habilidades CASCADE;
TRUNCATE TABLE candidatos_habilidades CASCADE;
TRUNCATE TABLE conexoes CASCADE;
TRUNCATE TABLE experiencias_profissionais CASCADE;
TRUNCATE TABLE formacoes_academicas CASCADE;
TRUNCATE TABLE curriculos CASCADE;
TRUNCATE TABLE vagas CASCADE;
TRUNCATE TABLE habilidades CASCADE;
TRUNCATE TABLE categorias_vaga CASCADE;
TRUNCATE TABLE recrutadores CASCADE;
TRUNCATE TABLE candidatos CASCADE;
TRUNCATE TABLE empresas CASCADE;
TRUNCATE TABLE usuarios CASCADE;
TRUNCATE TABLE etapas_processo CASCADE;
TRUNCATE TABLE historico_status CASCADE;
*/


-- ============================================================================
-- 1. CATEGORIAS DE VAGA (dados básicos do sistema)
-- ============================================================================

-- NOTA: As categorias principais já estão inseridas no schema (03-implementacao-sql.sql)
-- Adicionando apenas categorias extras para complementar os testes

INSERT INTO categorias_vaga (nome_categoria, descricao) VALUES
('Design', 'Vagas de design gráfico, UX/UI e criação'),
('Operações', 'Vagas operacionais e de logística')
ON CONFLICT (nome_categoria) DO NOTHING;

-- ============================================================================
-- 2. HABILIDADES (dados básicos do sistema)
-- ============================================================================

-- NOTA: Habilidades básicas já estão inseridas no schema (03-implementacao-sql.sql)
-- Adicionando apenas habilidades extras para complementar os testes

INSERT INTO habilidades (nome_habilidade, categoria, descricao) VALUES
-- Habilidades Técnicas Extras
('Git', 'tecnica', 'Controle de versão'),
('Docker', 'tecnica', 'Containerização de aplicações'),
('Excel Avançado', 'tecnica', 'Planilhas eletrônicas avançadas'),
('Power BI', 'tecnica', 'Business Intelligence'),
('Photoshop', 'tecnica', 'Editor de imagens'),
('Figma', 'tecnica', 'Design de interfaces'),

-- Habilidades Comportamentais Extras
('Resolução de Problemas', 'comportamental', 'Análise e solução de problemas'),
('Criatividade', 'comportamental', 'Pensamento criativo e inovador'),
('Organização', 'comportamental', 'Capacidade organizacional'),

-- Idiomas Extras
('Francês', 'idioma', 'Idioma francês')
ON CONFLICT (nome_habilidade) DO NOTHING;

-- ============================================================================
-- 3. ETAPAS DO PROCESSO SELETIVO
-- ============================================================================

-- NOTA: As etapas básicas já estão inseridas no schema (03-implementacao-sql.sql)
-- Todas as etapas necessárias já foram criadas lá.

-- ============================================================================
-- 4. USUÁRIOS E EMPRESAS
-- ============================================================================

-- Inserir usuários empresas
INSERT INTO usuarios (email, senha, tipo_usuario, status_conta) VALUES
('tech@techcorp.com', 'senha123', 'empresa', 'ativo'),
('rh@inovacaotech.com', 'senha123', 'empresa', 'ativo'),
('contato@startupxyz.com', 'senha123', 'empresa', 'ativo'),
('admin@megacorp.com', 'senha123', 'empresa', 'ativo'),
('info@digitalagency.com', 'senha123', 'empresa', 'ativo'),
('hr@consultingrh.com', 'senha123', 'empresa', 'ativo'),
('contact@financeplus.com', 'senha123', 'empresa', 'ativo');

-- Inserir empresas (usando os IDs dos usuários correspondentes)
INSERT INTO empresas (id_empresa, cnpj, nome_fantasia, razao_social, setor_atividade, tamanho_empresa, site_url, descricao) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'tech@techcorp.com'), '12.345.678/0001-90', 'TechCorp', 'TechCorp Soluções Ltda', 'Tecnologia', 'media', 'www.techcorp.com', 'Empresa de desenvolvimento de software'),
((SELECT id_usuario FROM usuarios WHERE email = 'rh@inovacaotech.com'), '23.456.789/0001-01', 'InovaçãoTech', 'Inovação Tecnológica S.A.', 'Tecnologia', 'grande', 'www.inovacaotech.com', 'Startup de inteligência artificial'),
((SELECT id_usuario FROM usuarios WHERE email = 'contato@startupxyz.com'), '34.567.890/0001-12', 'StartupXYZ', 'StartupXYZ Ltda', 'Tecnologia', 'pequena', 'www.startupxyz.com', 'Startup de e-commerce'),
((SELECT id_usuario FROM usuarios WHERE email = 'admin@megacorp.com'), '45.678.901/0001-23', 'MegaCorp', 'MegaCorp Indústrias S.A.', 'Industrial', 'grande', 'www.megacorp.com', 'Multinacional industrial'),
((SELECT id_usuario FROM usuarios WHERE email = 'info@digitalagency.com'), '56.789.012/0001-34', 'DigitalAgency', 'Digital Agency Ltda', 'Marketing', 'media', 'www.digitalagency.com', 'Agência de marketing digital'),
((SELECT id_usuario FROM usuarios WHERE email = 'hr@consultingrh.com'), '67.890.123/0001-45', 'ConsultingRH', 'Consulting RH S.A.', 'Consultoria', 'media', 'www.consultingrh.com', 'Consultoria em recursos humanos'),
((SELECT id_usuario FROM usuarios WHERE email = 'contact@financeplus.com'), '78.901.234/0001-56', 'FinancePlus', 'Finance Plus Ltda', 'Financeiro', 'media', 'www.financeplus.com', 'Serviços financeiros');

-- ============================================================================
-- 5. RECRUTADORES
-- ============================================================================

INSERT INTO usuarios (email, senha, tipo_usuario, status_conta) VALUES
('ana.silva@techcorp.com', 'senha123', 'recrutador', 'ativo'),
('carlos.santos@inovacaotech.com', 'senha123', 'recrutador', 'ativo'),
('maria.oliveira@startupxyz.com', 'senha123', 'recrutador', 'ativo'),
('joao.pereira@megacorp.com', 'senha123', 'recrutador', 'ativo'),
('lucia.costa@digitalagency.com', 'senha123', 'recrutador', 'ativo'),
('pedro.rh@consultingrh.com', 'senha123', 'recrutador', 'ativo'),
('carla.finance@financeplus.com', 'senha123', 'recrutador', 'ativo');

INSERT INTO recrutadores (id_recrutador, id_empresa, cpf, nome_completo, cargo, telefone) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@techcorp.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '12.345.678/0001-90'), '100.100.100-10', 'Ana Silva', 'Gerente de RH', '(11) 99999-0001'),
((SELECT id_usuario FROM usuarios WHERE email = 'carlos.santos@inovacaotech.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '23.456.789/0001-01'), '200.200.200-20', 'Carlos Santos', 'Recrutador Sênior', '(21) 99999-0002'),
((SELECT id_usuario FROM usuarios WHERE email = 'maria.oliveira@startupxyz.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '34.567.890/0001-12'), '300.300.300-30', 'Maria Oliveira', 'Coordenadora de RH', '(11) 99999-0003'),
((SELECT id_usuario FROM usuarios WHERE email = 'joao.pereira@megacorp.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '45.678.901/0001-23'), '400.400.400-40', 'João Pereira', 'Diretor de RH', '(19) 99999-0004'),
((SELECT id_usuario FROM usuarios WHERE email = 'lucia.costa@digitalagency.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '56.789.012/0001-34'), '500.500.500-50', 'Lúcia Costa', 'Analista de RH', '(51) 99999-0005'),
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.rh@consultingrh.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '67.890.123/0001-45'), '600.600.600-60', 'Pedro Consultor', 'Gerente de Talentos', '(31) 99999-0006'),
((SELECT id_usuario FROM usuarios WHERE email = 'carla.finance@financeplus.com'), (SELECT id_empresa FROM empresas WHERE cnpj = '78.901.234/0001-56'), '700.700.700-70', 'Carla Finance', 'Coordenadora de RH', '(11) 99999-0007');

-- ============================================================================
-- 6. CANDIDATOS
-- ============================================================================

INSERT INTO usuarios (email, senha, tipo_usuario, status_conta, data_cadastro) VALUES
('pedro.dev@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '3 months'),
('julia.designer@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '2 months'),
('rafael.analista@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '4 months'),
('fernanda.gerente@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '1 month'),
('lucas.vendas@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '5 months'),
('camila.marketing@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '6 months'),
('diego.fullstack@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '2 months'),
('patricia.qa@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '3 months'),
('gustavo.dados@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '1 month'),
('amanda.ux@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '4 months'),
('bruno.backend@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '2 months'),
('caroline.frontend@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '5 months'),
('thiago.mobile@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '3 months'),
('renata.product@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '1 month'),
('felipe.devops@email.com', 'senha123', 'candidato', 'ativo', CURRENT_DATE - INTERVAL '6 months');

INSERT INTO candidatos (id_candidato, cpf, nome_completo, data_nascimento, telefone, endereco, nivel_experiencia, salario_pretendido, disponibilidade, linkedin_url, github_url) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.dev@email.com'), '111.111.111-11', 'Pedro Desenvolvedor', '1995-05-15', '(11) 99999-1001', 'Rua A, 100 - São Paulo/SP', 'pleno', 8000.00, true, 'linkedin.com/in/pedro-dev', 'github.com/pedro-dev'),
((SELECT id_usuario FROM usuarios WHERE email = 'julia.designer@email.com'), '222.222.222-22', 'Julia Designer', '1992-08-20', '(11) 99999-1002', 'Rua B, 200 - São Paulo/SP', 'senior', 10000.00, true, 'linkedin.com/in/julia-designer', null),
((SELECT id_usuario FROM usuarios WHERE email = 'rafael.analista@email.com'), '333.333.333-33', 'Rafael Analista', '1990-12-10', '(21) 99999-1003', 'Rua C, 300 - Rio de Janeiro/RJ', 'senior', 12000.00, true, 'linkedin.com/in/rafael-analista', null),
((SELECT id_usuario FROM usuarios WHERE email = 'fernanda.gerente@email.com'), '444.444.444-44', 'Fernanda Gerente', '1988-03-25', '(11) 99999-1004', 'Rua D, 400 - São Paulo/SP', 'especialista', 15000.00, false, 'linkedin.com/in/fernanda-gerente', null),
((SELECT id_usuario FROM usuarios WHERE email = 'lucas.vendas@email.com'), '555.555.555-55', 'Lucas Vendas', '1993-07-12', '(19) 99999-1005', 'Rua E, 500 - Campinas/SP', 'pleno', 7000.00, true, 'linkedin.com/in/lucas-vendas', null),
((SELECT id_usuario FROM usuarios WHERE email = 'camila.marketing@email.com'), '666.666.666-66', 'Camila Marketing', '1991-11-08', '(51) 99999-1006', 'Rua F, 600 - Porto Alegre/RS', 'pleno', 8500.00, true, 'linkedin.com/in/camila-marketing', null),
((SELECT id_usuario FROM usuarios WHERE email = 'diego.fullstack@email.com'), '777.777.777-77', 'Diego Fullstack', '1994-02-18', '(11) 99999-1007', 'Rua G, 700 - São Paulo/SP', 'pleno', 9000.00, true, 'linkedin.com/in/diego-fullstack', 'github.com/diego-fullstack'),
((SELECT id_usuario FROM usuarios WHERE email = 'patricia.qa@email.com'), '888.888.888-88', 'Patricia QA', '1989-06-30', '(21) 99999-1008', 'Rua H, 800 - Rio de Janeiro/RJ', 'senior', 11000.00, true, 'linkedin.com/in/patricia-qa', null),
((SELECT id_usuario FROM usuarios WHERE email = 'gustavo.dados@email.com'), '999.999.999-99', 'Gustavo Dados', '1996-09-14', '(31) 99999-1009', 'Rua I, 900 - Belo Horizonte/MG', 'junior', 5000.00, true, 'linkedin.com/in/gustavo-dados', 'github.com/gustavo-dados'),
((SELECT id_usuario FROM usuarios WHERE email = 'amanda.ux@email.com'), '000.000.000-00', 'Amanda UX', '1992-04-22', '(11) 99999-1010', 'Rua J, 1000 - São Paulo/SP', 'pleno', 9500.00, true, 'linkedin.com/in/amanda-ux', null),
((SELECT id_usuario FROM usuarios WHERE email = 'bruno.backend@email.com'), '111.222.333-44', 'Bruno Backend', '1993-01-05', '(21) 99999-1011', 'Rua K, 1100 - Rio de Janeiro/RJ', 'pleno', 8500.00, true, 'linkedin.com/in/bruno-backend', 'github.com/bruno-backend'),
((SELECT id_usuario FROM usuarios WHERE email = 'caroline.frontend@email.com'), '222.333.444-55', 'Caroline Frontend', '1994-10-16', '(11) 99999-1012', 'Rua L, 1200 - São Paulo/SP', 'junior', 4500.00, true, 'linkedin.com/in/caroline-frontend', 'github.com/caroline-frontend'),
((SELECT id_usuario FROM usuarios WHERE email = 'thiago.mobile@email.com'), '333.444.555-66', 'Thiago Mobile', '1991-12-28', '(19) 99999-1013', 'Rua M, 1300 - Campinas/SP', 'senior', 12500.00, true, 'linkedin.com/in/thiago-mobile', 'github.com/thiago-mobile'),
((SELECT id_usuario FROM usuarios WHERE email = 'renata.product@email.com'), '444.555.666-77', 'Renata Product', '1990-08-07', '(51) 99999-1014', 'Rua N, 1400 - Porto Alegre/RS', 'senior', 13000.00, false, 'linkedin.com/in/renata-product', null),
((SELECT id_usuario FROM usuarios WHERE email = 'felipe.devops@email.com'), '555.666.777-88', 'Felipe DevOps', '1987-05-19', '(31) 99999-1015', 'Rua O, 1500 - Belo Horizonte/MG', 'especialista', 16000.00, true, 'linkedin.com/in/felipe-devops', 'github.com/felipe-devops');

-- ============================================================================
-- 7. HABILIDADES DOS CANDIDATOS
-- ============================================================================

-- Pedro Desenvolvedor (JavaScript, React, Node.js, Inglês, AWS)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.dev@email.com'), 1, 'avancado'),      -- JavaScript
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.dev@email.com'), 5, 'avancado'),      -- React
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.dev@email.com'), 6, 'intermediario'), -- Node.js
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.dev@email.com'), 10, 'avancado'),     -- Inglês
((SELECT id_usuario FROM usuarios WHERE email = 'pedro.dev@email.com'), 12, 'avancado');     -- AWS

-- Julia Designer (Comunicação, Liderança, Trabalho em Equipe)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'julia.designer@email.com'), 7, 'avancado'),     -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'julia.designer@email.com'), 8, 'especialista'), -- Liderança
((SELECT id_usuario FROM usuarios WHERE email = 'julia.designer@email.com'), 9, 'especialista'), -- Trabalho em Equipe
((SELECT id_usuario FROM usuarios WHERE email = 'julia.designer@email.com'), 10, 'avancado'),    -- Inglês
((SELECT id_usuario FROM usuarios WHERE email = 'julia.designer@email.com'), 12, 'avancado');    -- AWS

-- Rafael Analista (SQL, Inglês, AWS)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'rafael.analista@email.com'), 3, 'especialista'), -- SQL
((SELECT id_usuario FROM usuarios WHERE email = 'rafael.analista@email.com'), 10, 'avancado'),    -- Inglês
((SELECT id_usuario FROM usuarios WHERE email = 'rafael.analista@email.com'), 12, 'intermediario'); -- AWS

-- Fernanda Gerente (Liderança, Comunicação, Inglês)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'fernanda.gerente@email.com'), 8, 'especialista'), -- Liderança
((SELECT id_usuario FROM usuarios WHERE email = 'fernanda.gerente@email.com'), 7, 'especialista'), -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'fernanda.gerente@email.com'), 10, 'avancado'),    -- Inglês
((SELECT id_usuario FROM usuarios WHERE email = 'fernanda.gerente@email.com'), 9, 'especialista'); -- Trabalho em Equipe

-- Lucas Vendas (Comunicação, Inglês, Trabalho em Equipe)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'lucas.vendas@email.com'), 7, 'avancado'),      -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'lucas.vendas@email.com'), 10, 'intermediario'), -- Inglês
((SELECT id_usuario FROM usuarios WHERE email = 'lucas.vendas@email.com'), 9, 'avancado');       -- Trabalho em Equipe

-- Camila Marketing (Comunicação, Liderança, Espanhol)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'camila.marketing@email.com'), 7, 'avancado'),  -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'camila.marketing@email.com'), 8, 'avancado'),  -- Liderança
((SELECT id_usuario FROM usuarios WHERE email = 'camila.marketing@email.com'), 11, 'avancado'); -- Espanhol

-- Diego Fullstack (JavaScript, Python, Java, React, Node.js)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'diego.fullstack@email.com'), 1, 'avancado'),      -- JavaScript
((SELECT id_usuario FROM usuarios WHERE email = 'diego.fullstack@email.com'), 2, 'avancado'),      -- Python
((SELECT id_usuario FROM usuarios WHERE email = 'diego.fullstack@email.com'), 4, 'avancado'),      -- Java
((SELECT id_usuario FROM usuarios WHERE email = 'diego.fullstack@email.com'), 5, 'avancado'),      -- React
((SELECT id_usuario FROM usuarios WHERE email = 'diego.fullstack@email.com'), 6, 'intermediario'); -- Node.js

-- Patricia QA (JavaScript, Python, Comunicação)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'patricia.qa@email.com'), 1, 'intermediario'), -- JavaScript
((SELECT id_usuario FROM usuarios WHERE email = 'patricia.qa@email.com'), 2, 'intermediario'), -- Python
((SELECT id_usuario FROM usuarios WHERE email = 'patricia.qa@email.com'), 7, 'avancado');     -- Comunicação

-- Gustavo Dados (Python, SQL, AWS)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'gustavo.dados@email.com'), 2, 'intermediario'), -- Python
((SELECT id_usuario FROM usuarios WHERE email = 'gustavo.dados@email.com'), 3, 'avancado'),      -- SQL
((SELECT id_usuario FROM usuarios WHERE email = 'gustavo.dados@email.com'), 12, 'intermediario'); -- AWS

-- Amanda UX (Comunicação, Liderança, Inglês)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'amanda.ux@email.com'), 7, 'avancado'),     -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'amanda.ux@email.com'), 8, 'especialista'), -- Liderança
((SELECT id_usuario FROM usuarios WHERE email = 'amanda.ux@email.com'), 10, 'avancado');    -- Inglês

-- Bruno Backend (Java, Python, SQL, Inglês)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'bruno.backend@email.com'), 4, 'especialista'), -- Java
((SELECT id_usuario FROM usuarios WHERE email = 'bruno.backend@email.com'), 2, 'avancado'),     -- Python
((SELECT id_usuario FROM usuarios WHERE email = 'bruno.backend@email.com'), 3, 'avancado'),     -- SQL
((SELECT id_usuario FROM usuarios WHERE email = 'bruno.backend@email.com'), 10, 'intermediario'); -- Inglês

-- Caroline Frontend (JavaScript, React, Comunicação)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'caroline.frontend@email.com'), 1, 'intermediario'), -- JavaScript
((SELECT id_usuario FROM usuarios WHERE email = 'caroline.frontend@email.com'), 5, 'intermediario'), -- React
((SELECT id_usuario FROM usuarios WHERE email = 'caroline.frontend@email.com'), 7, 'avancado');      -- Comunicação

-- Thiago Mobile (JavaScript, Java, React, Comunicação)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'thiago.mobile@email.com'), 1, 'avancado'),     -- JavaScript
((SELECT id_usuario FROM usuarios WHERE email = 'thiago.mobile@email.com'), 4, 'especialista'), -- Java
((SELECT id_usuario FROM usuarios WHERE email = 'thiago.mobile@email.com'), 5, 'avancado'),     -- React
((SELECT id_usuario FROM usuarios WHERE email = 'thiago.mobile@email.com'), 7, 'avancado');     -- Comunicação

-- Renata Product (Liderança, Comunicação, Inglês)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'renata.product@email.com'), 8, 'especialista'), -- Liderança
((SELECT id_usuario FROM usuarios WHERE email = 'renata.product@email.com'), 7, 'especialista'), -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'renata.product@email.com'), 10, 'avancado');    -- Inglês

-- Felipe DevOps (Python, Comunicação, AWS, Scrum Master)
INSERT INTO candidatos_habilidades (id_candidato, id_habilidade, nivel_proficiencia) VALUES
((SELECT id_usuario FROM usuarios WHERE email = 'felipe.devops@email.com'), 2, 'avancado'),     -- Python
((SELECT id_usuario FROM usuarios WHERE email = 'felipe.devops@email.com'), 7, 'especialista'), -- Comunicação
((SELECT id_usuario FROM usuarios WHERE email = 'felipe.devops@email.com'), 12, 'especialista'), -- AWS
((SELECT id_usuario FROM usuarios WHERE email = 'felipe.devops@email.com'), 13, 'especialista'); -- Scrum Master

-- ============================================================================
-- 8. VAGAS
-- ============================================================================

INSERT INTO vagas (id_empresa, id_categoria, id_recrutador, titulo, descricao, nivel_experiencia, salario_min, salario_max, modalidade_trabalho, tipo_contrato, data_publicacao, data_expiracao, status_vaga) VALUES
-- TechCorp
((SELECT id_empresa FROM empresas WHERE cnpj = '12.345.678/0001-90'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@techcorp.com'), 'Desenvolvedor Frontend React', 'Desenvolvedor especializado em React para projetos web', 'pleno', 6000.00, 9000.00, 'remoto', 'clt', CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE + INTERVAL '45 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '12.345.678/0001-90'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@techcorp.com'), 'Desenvolvedor Backend Node.js', 'Desenvolvedor backend com Node.js e bancos de dados', 'pleno', 7000.00, 10000.00, 'hibrido', 'clt', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '50 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '12.345.678/0001-90'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@techcorp.com'), 'Analista de QA', 'Analista de qualidade para testes automatizados', 'senior', 8000.00, 12000.00, 'presencial', 'clt', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '55 days', 'aberta'),

-- InovaçãoTech
((SELECT id_empresa FROM empresas WHERE cnpj = '23.456.789/0001-01'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'carlos.santos@inovacaotech.com'), 'Cientista de Dados', 'Profissional para análise de dados e machine learning', 'senior', 10000.00, 15000.00, 'remoto', 'clt', CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE + INTERVAL '40 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '23.456.789/0001-01'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'carlos.santos@inovacaotech.com'), 'Desenvolvedor Python', 'Desenvolvedor Python para projetos de IA', 'pleno', 8000.00, 12000.00, 'hibrido', 'clt', CURRENT_DATE - INTERVAL '8 days', CURRENT_DATE + INTERVAL '52 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '23.456.789/0001-01'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'carlos.santos@inovacaotech.com'), 'Product Manager', 'Gerente de produto para área de tecnologia', 'senior', 12000.00, 18000.00, 'hibrido', 'clt', CURRENT_DATE - INTERVAL '12 days', CURRENT_DATE + INTERVAL '48 days', 'aberta'),

-- StartupXYZ
((SELECT id_empresa FROM empresas WHERE cnpj = '34.567.890/0001-12'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'maria.oliveira@startupxyz.com'), 'Desenvolvedor Fullstack', 'Desenvolvedor fullstack para e-commerce', 'pleno', 7000.00, 10000.00, 'presencial', 'clt', CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE + INTERVAL '35 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '34.567.890/0001-12'), 3, (SELECT id_usuario FROM usuarios WHERE email = 'maria.oliveira@startupxyz.com'), 'Analista de Marketing Digital', 'Analista para campanhas digitais e SEO', 'junior', 4000.00, 6000.00, 'remoto', 'clt', CURRENT_DATE - INTERVAL '18 days', CURRENT_DATE + INTERVAL '42 days', 'aberta'),

-- MegaCorp
((SELECT id_empresa FROM empresas WHERE cnpj = '45.678.901/0001-23'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'joao.pereira@megacorp.com'), 'Arquiteto de Software', 'Arquiteto sênior para projetos enterprise', 'especialista', 15000.00, 22000.00, 'hibrido', 'clt', CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE + INTERVAL '30 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '45.678.901/0001-23'), 4, (SELECT id_usuario FROM usuarios WHERE email = 'joao.pereira@megacorp.com'), 'Gerente de RH', 'Gerente para área de recursos humanos', 'senior', 10000.00, 15000.00, 'presencial', 'clt', CURRENT_DATE - INTERVAL '22 days', CURRENT_DATE + INTERVAL '38 days', 'aberta'),

-- DigitalAgency
((SELECT id_empresa FROM empresas WHERE cnpj = '56.789.012/0001-34'), 2, (SELECT id_usuario FROM usuarios WHERE email = 'lucia.costa@digitalagency.com'), 'Designer UX/UI', 'Designer para experiência e interface de usuário', 'pleno', 6000.00, 9000.00, 'hibrido', 'clt', CURRENT_DATE - INTERVAL '14 days', CURRENT_DATE + INTERVAL '46 days', 'aberta'),
((SELECT id_empresa FROM empresas WHERE cnpj = '56.789.012/0001-34'), 2, (SELECT id_usuario FROM usuarios WHERE email = 'lucia.costa@digitalagency.com'), 'Analista de Marketing', 'Analista de marketing para campanhas digitais', 'pleno', 5000.00, 8000.00, 'remoto', 'clt', CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE + INTERVAL '53 days', 'aberta'),

-- ConsultingRH
((SELECT id_empresa FROM empresas WHERE cnpj = '67.890.123/0001-45'), 4, (SELECT id_usuario FROM usuarios WHERE email = 'pedro.rh@consultingrh.com'), 'Consultor de RH', 'Consultor especializado em gestão de pessoas', 'senior', 8000.00, 12000.00, 'hibrido', 'pj', CURRENT_DATE - INTERVAL '16 days', CURRENT_DATE + INTERVAL '44 days', 'aberta'),

-- FinancePlus
((SELECT id_empresa FROM empresas WHERE cnpj = '78.901.234/0001-56'), 5, (SELECT id_usuario FROM usuarios WHERE email = 'carla.finance@financeplus.com'), 'Analista Financeiro', 'Analista para controladoria e finanças', 'pleno', 6000.00, 9000.00, 'presencial', 'clt', CURRENT_DATE - INTERVAL '11 days', CURRENT_DATE + INTERVAL '49 days', 'aberta'),

-- Vagas fechadas para histórico
((SELECT id_empresa FROM empresas WHERE cnpj = '12.345.678/0001-90'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@techcorp.com'), 'Desenvolvedor JavaScript', 'Vaga fechada para histórico', 'junior', 4000.00, 6000.00, 'remoto', 'clt', CURRENT_DATE - INTERVAL '60 days', NULL, 'fechada'),
((SELECT id_empresa FROM empresas WHERE cnpj = '23.456.789/0001-01'), 1, (SELECT id_usuario FROM usuarios WHERE email = 'carlos.santos@inovacaotech.com'), 'Estagiário de TI', 'Vaga de estágio finalizada', 'junior', 1500.00, 2000.00, 'presencial', 'estagio', CURRENT_DATE - INTERVAL '90 days', NULL, 'fechada');

-- ============================================================================
-- 9. HABILIDADES DAS VAGAS
-- ============================================================================

INSERT INTO vagas_habilidades (id_vaga, id_habilidade, obrigatoria, nivel_requerido) VALUES
-- Desenvolvedor Frontend React 
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Frontend React' LIMIT 1), 1, true, 'avancado'),     -- JavaScript
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Frontend React' LIMIT 1), 5, true, 'avancado'),     -- React
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Frontend React' LIMIT 1), 7, false, 'avancado'),    -- Comunicação

-- Desenvolvedor Backend Node.js
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Backend Node.js' LIMIT 1), 1, true, 'avancado'),     -- JavaScript
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Backend Node.js' LIMIT 1), 6, true, 'avancado'),     -- Node.js
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Backend Node.js' LIMIT 1), 3, true, 'intermediario'), -- SQL
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Backend Node.js' LIMIT 1), 7, true, 'intermediario'), -- Comunicação

-- Analista de QA
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de QA' LIMIT 1), 1, false, 'intermediario'), -- JavaScript
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de QA' LIMIT 1), 2, false, 'intermediario'), -- Python
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de QA' LIMIT 1), 7, true, 'avancado'),     -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de QA' LIMIT 1), 9, true, 'avancado'),     -- Trabalho em Equipe

-- Cientista de Dados
((SELECT id_vaga FROM vagas WHERE titulo = 'Cientista de Dados' LIMIT 1), 2, true, 'especialista'), -- Python
((SELECT id_vaga FROM vagas WHERE titulo = 'Cientista de Dados' LIMIT 1), 3, true, 'avancado'),     -- SQL
(4, 12, false, 'intermediario'), -- AWS
(4, 7, true, 'avancado'),     -- Comunicação

-- Desenvolvedor Python (vaga 5)
((SELECT id_vaga FROM vagas WHERE titulo = 'Cientista de Dados' LIMIT 1), 12, false, 'intermediario'), -- AWS
((SELECT id_vaga FROM vagas WHERE titulo = 'Cientista de Dados' LIMIT 1), 7, true, 'avancado'),     -- Comunicação

-- Desenvolvedor Python
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Python' LIMIT 1), 2, true, 'avancado'),     -- Python
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Python' LIMIT 1), 3, true, 'intermediario'), -- SQL
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Python' LIMIT 1), 9, false, 'avancado'),    -- Trabalho em Equipe

-- Product Manager
((SELECT id_vaga FROM vagas WHERE titulo = 'Product Manager' LIMIT 1), 8, true, 'avancado'),     -- Liderança
((SELECT id_vaga FROM vagas WHERE titulo = 'Product Manager' LIMIT 1), 7, true, 'avancado'),     -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Product Manager' LIMIT 1), 10, false, 'intermediario'), -- Inglês

-- Desenvolvedor Fullstack
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Fullstack' LIMIT 1), 1, true, 'avancado'),     -- JavaScript
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Fullstack' LIMIT 1), 2, false, 'intermediario'), -- Python
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Fullstack' LIMIT 1), 5, true, 'intermediario'), -- React
((SELECT id_vaga FROM vagas WHERE titulo = 'Desenvolvedor Fullstack' LIMIT 1), 3, true, 'intermediario'), -- SQL

-- Analista de Marketing Digital
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de Marketing Digital' LIMIT 1), 7, true, 'avancado'),     -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de Marketing Digital' LIMIT 1), 9, false, 'intermediario'), -- Trabalho em Equipe

-- Arquiteto de Software
((SELECT id_vaga FROM vagas WHERE titulo = 'Arquiteto de Software' LIMIT 1), 4, true, 'especialista'), -- Java
((SELECT id_vaga FROM vagas WHERE titulo = 'Arquiteto de Software' LIMIT 1), 2, false, 'avancado'),    -- Python
((SELECT id_vaga FROM vagas WHERE titulo = 'Arquiteto de Software' LIMIT 1), 12, false, 'avancado'),   -- AWS
((SELECT id_vaga FROM vagas WHERE titulo = 'Arquiteto de Software' LIMIT 1), 8, true, 'avancado'),     -- Liderança

-- Gerente de RH
((SELECT id_vaga FROM vagas WHERE titulo = 'Gerente de RH' LIMIT 1), 8, true, 'especialista'), -- Liderança
((SELECT id_vaga FROM vagas WHERE titulo = 'Gerente de RH' LIMIT 1), 7, true, 'especialista'), -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Gerente de RH' LIMIT 1), 10, false, 'avancado'),  -- Inglês

-- Designer UX/UI
((SELECT id_vaga FROM vagas WHERE titulo = 'Designer UX/UI' LIMIT 1), 7, true, 'avancado'),    -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Designer UX/UI' LIMIT 1), 9, true, 'avancado'),    -- Trabalho em Equipe

-- Analista de Marketing
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de Marketing' LIMIT 1), 7, true, 'avancado'),    -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista de Marketing' LIMIT 1), 11, false, 'intermediario'), -- Espanhol

-- Consultor de RH
((SELECT id_vaga FROM vagas WHERE titulo = 'Consultor de RH' LIMIT 1), 8, true, 'avancado'),    -- Liderança
((SELECT id_vaga FROM vagas WHERE titulo = 'Consultor de RH' LIMIT 1), 7, true, 'especialista'), -- Comunicação
((SELECT id_vaga FROM vagas WHERE titulo = 'Consultor de RH' LIMIT 1), 9, true, 'avancado'),    -- Trabalho em Equipe

-- Analista Financeiro
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista Financeiro' LIMIT 1), 10, true, 'avancado'),   -- Inglês
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista Financeiro' LIMIT 1), 3, false, 'intermediario'), -- SQL
((SELECT id_vaga FROM vagas WHERE titulo = 'Analista Financeiro' LIMIT 1), 7, true, 'avancado');    -- Comunicação

-- ============================================================================
-- 10. CANDIDATURAS
-- ============================================================================

INSERT INTO candidaturas (id_candidato, id_vaga, data_candidatura, status_candidatura, carta_apresentacao) VALUES
-- Candidaturas dos últimos 6 meses (para consulta 2)
(13, 1, CURRENT_DATE - INTERVAL '14 days', 'aprovado', 'Tenho 3 anos de experiência com React e JavaScript.'),
(13, 2, CURRENT_DATE - INTERVAL '20 days', 'rejeitado', 'Gostaria de trabalhar com Node.js.'),
(13, 7, CURRENT_DATE - INTERVAL '25 days', 'pendente', 'Experiência fullstack em projetos pessoais.'),
(13, 15, CURRENT_DATE - INTERVAL '45 days', 'aprovado', 'Primeira oportunidade profissional.'),

(14, 11, CURRENT_DATE - INTERVAL '13 days', 'em_processo', 'Portfólio com projetos de UX/UI.'),
(14, 12, CURRENT_DATE - INTERVAL '18 days', 'aprovado', 'Experiência em agências de marketing.'),
(14, 8, CURRENT_DATE - INTERVAL '30 days', 'rejeitado', 'Interesse em marketing digital.'),

(15, 4, CURRENT_DATE - INTERVAL '19 days', 'em_processo', 'Mestrado em Ciência de Dados.'),
(15, 10, CURRENT_DATE - INTERVAL '21 days', 'pendente', 'Experiência em gestão de equipes.'),
(15, 14, CURRENT_DATE - INTERVAL '35 days', 'aprovado', 'Especialista em análise financeira.'),
(15, 13, CURRENT_DATE - INTERVAL '40 days', 'rejeitado', 'Transição de carreira para RH.'),

(16, 6, CURRENT_DATE - INTERVAL '11 days', 'pendente', 'Experiência como Product Owner.'),
(16, 9, CURRENT_DATE - INTERVAL '28 days', 'rejeitado', 'Interesse em arquitetura de software.'),

(17, 8, CURRENT_DATE - INTERVAL '17 days', 'em_processo', 'Experiência comercial e interesse em marketing.'),
(17, 12, CURRENT_DATE - INTERVAL '32 days', 'aprovado', 'Histórico em vendas e marketing.'),

(18, 11, CURRENT_DATE - INTERVAL '12 days', 'pendente', 'Portfolio de design e marketing.'),
(18, 8, CURRENT_DATE - INTERVAL '24 days', 'aprovado', 'Especialista em campanhas digitais.'),
(18, 12, CURRENT_DATE - INTERVAL '38 days', 'rejeitado', 'Experiência em agência.'),

(19, 1, CURRENT_DATE - INTERVAL '15 days', 'rejeitado', 'Desenvolvedor fullstack com foco em frontend.'),
(19, 2, CURRENT_DATE - INTERVAL '22 days', 'em_processo', 'Experiência com Node.js em projetos pessoais.'),
(19, 7, CURRENT_DATE - INTERVAL '26 days', 'aprovado', 'Perfil ideal para fullstack.'),

(20, 3, CURRENT_DATE - INTERVAL '16 days', 'aprovado', 'Experiência em QA manual e automatizado.'),
(20, 5, CURRENT_DATE - INTERVAL '29 days', 'rejeitado', 'Interesse em desenvolvimento Python.'),

(21, 4, CURRENT_DATE - INTERVAL '23 days', 'pendente', 'Recém-formado em Ciência da Computação.'),
(21, 5, CURRENT_DATE - INTERVAL '31 days', 'em_processo', 'Estudando Python e análise de dados.'),
(21, 16, CURRENT_DATE - INTERVAL '50 days', 'rejeitado', 'Primeira experiência profissional.'),

(22, 11, CURRENT_DATE - INTERVAL '9 days', 'em_processo', 'Especialista em design de experiência.'),
(22, 8, CURRENT_DATE - INTERVAL '27 days', 'rejeitado', 'Transição para marketing digital.'),

(23, 2, CURRENT_DATE - INTERVAL '19 days', 'pendente', 'Backend developer com Java e Python.'),
(23, 5, CURRENT_DATE - INTERVAL '33 days', 'aprovado', 'Experiência sólida em Python.'),
(23, 9, CURRENT_DATE - INTERVAL '41 days', 'rejeitado', 'Aspiração para arquitetura.'),

(24, 1, CURRENT_DATE - INTERVAL '21 days', 'rejeitado', 'Junior developer buscando primeira oportunidade.'),
(24, 7, CURRENT_DATE - INTERVAL '34 days', 'em_processo', 'Projetos pessoais em JavaScript.'),
(24, 8, CURRENT_DATE - INTERVAL '46 days', 'pendente', 'Interesse em marketing e tecnologia.'),

(25, 7, CURRENT_DATE - INTERVAL '24 days', 'aprovado', 'Desenvolvedor mobile com React Native.'),
(25, 9, CURRENT_DATE - INTERVAL '36 days', 'rejeitado', 'Experiência em aplicações móveis.'),

(26, 6, CURRENT_DATE - INTERVAL '10 days', 'pendente', 'Product Manager com 5 anos de experiência.'),
(26, 10, CURRENT_DATE - INTERVAL '37 days', 'aprovado', 'Gerente de produto com visão de RH.'),

(27, 9, CURRENT_DATE - INTERVAL '8 days', 'em_processo', 'Arquiteto de software e DevOps specialist.');

-- ============================================================================
-- 11. PROCESSOS SELETIVOS
-- ============================================================================

INSERT INTO processos_seletivos (id_candidatura, data_inicio, data_fim, etapa_atual, status_processo) VALUES
-- Processos finalizados (aprovados)
(1, CURRENT_DATE - INTERVAL '13 days', CURRENT_DATE - INTERVAL '3 days', 5, 'concluido'),
(12, CURRENT_DATE - INTERVAL '17 days', CURRENT_DATE - INTERVAL '5 days', 5, 'concluido'),
(10, CURRENT_DATE - INTERVAL '34 days', CURRENT_DATE - INTERVAL '20 days', 5, 'concluido'),
(16, CURRENT_DATE - INTERVAL '31 days', CURRENT_DATE - INTERVAL '15 days', 5, 'concluido'),
(18, CURRENT_DATE - INTERVAL '23 days', CURRENT_DATE - INTERVAL '10 days', 5, 'concluido'),
(19, CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE - INTERVAL '12 days', 5, 'concluido'),
(20, CURRENT_DATE - INTERVAL '15 days', CURRENT_DATE - INTERVAL '4 days', 5, 'concluido'),
(23, CURRENT_DATE - INTERVAL '32 days', CURRENT_DATE - INTERVAL '18 days', 5, 'concluido'),
(25, CURRENT_DATE - INTERVAL '23 days', CURRENT_DATE - INTERVAL '8 days', 5, 'concluido'),
(26, CURRENT_DATE - INTERVAL '36 days', CURRENT_DATE - INTERVAL '22 days', 5, 'concluido'),

-- Processos finalizados (rejeitados)
(2, CURRENT_DATE - INTERVAL '19 days', CURRENT_DATE - INTERVAL '7 days', 3, 'concluido'),
(7, CURRENT_DATE - INTERVAL '29 days', CURRENT_DATE - INTERVAL '14 days', 2, 'concluido'),
(11, CURRENT_DATE - INTERVAL '39 days', CURRENT_DATE - INTERVAL '25 days', 4, 'concluido'),
(14, CURRENT_DATE - INTERVAL '27 days', CURRENT_DATE - INTERVAL '16 days', 2, 'concluido'),
(17, CURRENT_DATE - INTERVAL '37 days', CURRENT_DATE - INTERVAL '21 days', 3, 'concluido'),
(21, CURRENT_DATE - INTERVAL '28 days', CURRENT_DATE - INTERVAL '19 days', 1, 'concluido'),
(22, CURRENT_DATE - INTERVAL '26 days', CURRENT_DATE - INTERVAL '11 days', 2, 'concluido'),
(27, CURRENT_DATE - INTERVAL '35 days', CURRENT_DATE - INTERVAL '24 days', 4, 'concluido'),
(28, CURRENT_DATE - INTERVAL '33 days', CURRENT_DATE - INTERVAL '17 days', 3, 'concluido'),
(29, CURRENT_DATE - INTERVAL '45 days', CURRENT_DATE - INTERVAL '30 days', 2, 'concluido'),

-- Processos em andamento
(4, CURRENT_DATE - INTERVAL '12 days', null, 3, 'em_andamento'),
(8, CURRENT_DATE - INTERVAL '18 days', null, 4, 'em_andamento'),
(15, CURRENT_DATE - INTERVAL '16 days', null, 2, 'em_andamento'),
(5, CURRENT_DATE - INTERVAL '9 days', null, 3, 'em_andamento'),
(24, CURRENT_DATE - INTERVAL '20 days', null, 4, 'em_andamento'),
(6, CURRENT_DATE - INTERVAL '11 days', null, 1, 'em_andamento'),
(13, CURRENT_DATE - INTERVAL '8 days', null, 2, 'em_andamento'),
(30, CURRENT_DATE - INTERVAL '7 days', null, 1, 'em_andamento');

-- ============================================================================
-- 12. AVALIAÇÕES DOS CANDIDATOS
-- ============================================================================

INSERT INTO avaliacoes_candidatos (id_processo, id_etapa, nota, comentarios, data_avaliacao) VALUES
-- Avaliações dos processos finalizados (aprovados)
(1, 1, 9.0, 'Currículo excelente, experiência alinhada', CURRENT_DATE - INTERVAL '12 days'),
(1, 2, 8.5, 'Boa comunicação e fit cultural', CURRENT_DATE - INTERVAL '10 days'),
(1, 3, 9.0, 'Teste técnico muito bom', CURRENT_DATE - INTERVAL '7 days'),
(1, 4, 8.0, 'Conhecimento técnico sólido', CURRENT_DATE - INTERVAL '5 days'),
(1, 5, 9.0, 'Aprovado pela diretoria', CURRENT_DATE - INTERVAL '3 days'),

(2, 1, 8.0, 'Perfil interessante', CURRENT_DATE - INTERVAL '16 days'),
(2, 2, 7.5, 'Comunicação adequada', CURRENT_DATE - INTERVAL '14 days'),
(2, 3, 8.5, 'Bom resultado no teste', CURRENT_DATE - INTERVAL '11 days'),
(2, 4, 8.0, 'Experiência relevante', CURRENT_DATE - INTERVAL '9 days'),
(2, 5, 8.5, 'Contratado', CURRENT_DATE - INTERVAL '5 days'),

-- Avaliações dos processos finalizados (rejeitados)
(3, 1, 6.0, 'Currículo não atende completamente', CURRENT_DATE - INTERVAL '18 days'),
(3, 2, 5.5, 'Dificuldades de comunicação', CURRENT_DATE - INTERVAL '15 days'),
(3, 3, 4.0, 'Teste técnico insatisfatório', CURRENT_DATE - INTERVAL '7 days'),

(4, 1, 7.0, 'Perfil com potencial', CURRENT_DATE - INTERVAL '28 days'),
(4, 2, 6.0, 'Falta de experiência específica', CURRENT_DATE - INTERVAL '14 days'),

-- Avaliações dos processos em andamento
(11, 1, 8.0, 'Currículo aprovado', CURRENT_DATE - INTERVAL '11 days'),
(11, 2, 7.5, 'Entrevista RH aprovada', CURRENT_DATE - INTERVAL '8 days'),
(11, 3, 8.0, 'Teste técnico em análise', CURRENT_DATE - INTERVAL '5 days'),

(12, 1, 9.0, 'Excelente currículo', CURRENT_DATE - INTERVAL '17 days'),
(12, 2, 8.5, 'Ótima entrevista', CURRENT_DATE - INTERVAL '14 days'),
(12, 3, 8.0, 'Teste aprovado', CURRENT_DATE - INTERVAL '11 days'),
(12, 4, 8.5, 'Entrevista técnica aprovada', CURRENT_DATE - INTERVAL '8 days');

-- ============================================================================
-- 13. CURRÍCULOS
-- ============================================================================

INSERT INTO curriculos (id_candidato, resumo_profissional, objetivo) VALUES
(13, 'Desenvolvedor Frontend com 3 anos de experiência em React e JavaScript', 'Busco oportunidades para crescer como desenvolvedor pleno'),
(14, 'Designer UX/UI com 5 anos de experiência em agências e startups', 'Objetivo de liderar projetos de design em empresa de tecnologia'),
(15, 'Analista de dados com mestrado e experiência em Business Intelligence', 'Transição para área de ciência de dados e machine learning'),
(16, 'Gerente de projetos com 8 anos de experiência em tecnologia', 'Busco posição de liderança em produto ou gestão'),
(17, 'Profissional de vendas com interesse em marketing digital', 'Transição de carreira para área de marketing'),
(18, 'Especialista em marketing digital com foco em campanhas online', 'Crescimento como líder de marketing em startup'),
(19, 'Desenvolvedor fullstack com experiência em várias tecnologias', 'Evolução técnica como desenvolvedor sênior'),
(20, 'Analista de QA com experiência em testes manuais e automatizados', 'Especialização em automação de testes'),
(21, 'Recém-formado em Ciência da Computação com projetos acadêmicos', 'Primeira oportunidade profissional em desenvolvimento'),
(22, 'Designer UX com portfolio diversificado e experiência em pesquisa', 'Liderança de projetos de UX em produto digital'),
(23, 'Desenvolvedor backend especializado em Java e Python', 'Evolução para arquitetura de software'),
(24, 'Desenvolvedora frontend junior com projetos pessoais', 'Crescimento profissional como desenvolvedora'),
(25, 'Desenvolvedor mobile com experiência em React Native', 'Especialização em desenvolvimento mobile'),
(26, 'Product Manager com visão estratégica e experiência em agilidade', 'Liderança de produto em empresa de tecnologia'),
(27, 'Especialista em DevOps e arquitetura de software', 'Evolução como arquiteto sênior de soluções');

-- ============================================================================
-- 14. EXPERIÊNCIAS PROFISSIONAIS
-- ============================================================================

INSERT INTO experiencias_profissionais (id_curriculo, empresa, cargo, data_inicio, data_fim, emprego_atual, descricao) VALUES
-- Pedro Desenvolvedor (id_curriculo 1)
(1, 'StartupTech', 'Desenvolvedor Frontend', '2022-01-01', '2024-12-31', true, 'Desenvolvimento de interfaces React'),
(1, 'FreelaTech', 'Desenvolvedor', '2021-06-01', '2021-12-31', false, 'Projetos freelance em JavaScript'),

-- Julia Designer (id_curriculo 2)
(2, 'AgênciaCreativa', 'Designer UX/UI', '2020-03-01', '2024-12-31', true, 'Design de produtos digitais'),
(2, 'StudioDesign', 'Designer Gráfico', '2018-01-01', '2020-02-28', false, 'Design gráfico e branding'),

-- Rafael Analista (id_curriculo 3)
(3, 'CorpAnalytics', 'Analista de BI', '2019-08-01', '2024-12-31', true, 'Business Intelligence e relatórios'),
(3, 'DataConsult', 'Analista de Dados', '2017-03-01', '2019-07-31', false, 'Análise de dados financeiros'),

-- Fernanda Gerente (id_curriculo 4)
(4, 'TechLeader', 'Gerente de Projetos', '2018-05-01', '2024-12-31', true, 'Gestão de projetos de software'),
(4, 'InnovaCorp', 'Coordenadora de TI', '2015-02-01', '2018-04-30', false, 'Coordenação de equipes técnicas'),

-- Lucas Vendas (id_curriculo 5)
(5, 'SalesForce Inc', 'Executivo de Vendas', '2021-01-01', '2024-12-31', true, 'Vendas B2B e relacionamento'),
(5, 'VendasTop', 'Consultor Comercial', '2019-06-01', '2020-12-31', false, 'Consultoria em vendas');

-- ============================================================================
-- 15. FORMAÇÕES ACADÊMICAS
-- ============================================================================

INSERT INTO formacoes_academicas (id_curriculo, grau, curso, instituicao, data_inicio, data_conclusao, concluido) VALUES
-- Pedro Desenvolvedor
(1, 'graduacao', 'Ciência da Computação', 'FIAP', '2018-02-01', '2021-12-15', true),

-- Julia Designer
(2, 'graduacao', 'Design Gráfico', 'Mackenzie', '2015-02-01', '2018-12-15', true),
(2, 'pos-graduacao', 'UX Design', 'ESPM', '2019-02-01', '2020-12-15', true),

-- Rafael Analista
(3, 'graduacao', 'Estatística', 'USP', '2013-02-01', '2016-12-15', true),
(3, 'mestrado', 'Ciência de Dados', 'USP', '2017-02-01', '2019-12-15', true),

-- Fernanda Gerente
(4, 'graduacao', 'Administração', 'FGV', '2010-02-01', '2013-12-15', true),
(4, 'pos-graduacao', 'Gestão de Projetos', 'FGV', '2014-02-01', '2015-12-15', true),

-- Lucas Vendas
(5, 'graduacao', 'Marketing', 'ESPM', '2017-02-01', '2020-12-15', true),

-- Camila Marketing
(6, 'graduacao', 'Publicidade', 'ESPM', '2015-02-01', '2018-12-15', true),

-- Diego Fullstack
(7, 'graduacao', 'Sistemas de Informação', 'PUC-SP', '2018-02-01', '2022-12-15', true),

-- Patricia QA
(8, 'graduacao', 'Engenharia de Software', 'FIAP', '2014-02-01', '2017-12-15', true),

-- Gustavo Dados
(9, 'graduacao', 'Ciência da Computação', 'UNICAMP', '2020-02-01', '2023-12-15', true),

-- Amanda UX
(10, 'graduacao', 'Design', 'Anhembi Morumbi', '2017-02-01', '2020-12-15', true),

-- Bruno Backend
(11, 'graduacao', 'Ciência da Computação', 'UNESP', '2017-02-01', '2021-12-15', true),

-- Caroline Frontend
(12, 'tecnico', 'Informática', 'ETEC', '2020-02-01', '2021-12-15', true),
(12, 'graduacao', 'Análise e Desenvolvimento', 'FATEC', '2022-02-01', null, false),

-- Thiago Mobile
(13, 'graduacao', 'Ciência da Computação', 'UNICAMP', '2015-02-01', '2018-12-15', true),

-- Renata Product
(14, 'graduacao', 'Administração', 'USP', '2012-02-01', '2015-12-15', true),
(14, 'pos-graduacao', 'Product Management', 'FIAP', '2018-02-01', '2019-12-15', true),

-- Felipe DevOps
(15, 'graduacao', 'Engenharia de Computação', 'ITA', '2009-02-01', '2012-12-15', true),
(15, 'mestrado', 'Engenharia de Software', 'USP', '2013-02-01', '2015-12-15', true);

-- ============================================================================
-- 16. CONEXÕES (NETWORKING)
-- ============================================================================

INSERT INTO conexoes (id_solicitante, id_receptor, data_conexao, status_conexao, mensagem) VALUES
-- Conexões entre candidatos
(13, 14, CURRENT_DATE - INTERVAL '30 days', 'aceita', 'Vamos nos conectar!'),
(13, 19, CURRENT_DATE - INTERVAL '25 days', 'aceita', 'Networking de desenvolvedores'),
(14, 22, CURRENT_DATE - INTERVAL '40 days', 'aceita', 'Designers unidos!'),
(15, 21, CURRENT_DATE - INTERVAL '35 days', 'aceita', 'Área de dados'),
(16, 26, CURRENT_DATE - INTERVAL '50 days', 'aceita', 'Gestores de produto'),
(19, 23, CURRENT_DATE - INTERVAL '20 days', 'aceita', 'Desenvolvedores backend'),
(20, 21, CURRENT_DATE - INTERVAL '45 days', 'aceita', 'QA e dados'),
(22, 18, CURRENT_DATE - INTERVAL '30 days', 'aceita', 'UX e Marketing'),
(23, 25, CURRENT_DATE - INTERVAL '35 days', 'aceita', 'Desenvolvedores Java'),
(24, 13, CURRENT_DATE - INTERVAL '15 days', 'aceita', 'Frontend developers'),

-- Conexões candidatos com recrutadores
(13, 8, CURRENT_DATE - INTERVAL '60 days', 'aceita', 'Interesse em vagas de desenvolvimento'),
(14, 12, CURRENT_DATE - INTERVAL '40 days', 'aceita', 'Portfolio de design'),
(15, 9, CURRENT_DATE - INTERVAL '50 days', 'aceita', 'Perfil de dados'),
(16, 11, CURRENT_DATE - INTERVAL '45 days', 'aceita', 'Experiência em gestão'),
(19, 8, CURRENT_DATE - INTERVAL '30 days', 'aceita', 'Desenvolvedor fullstack'),
(20, 8, CURRENT_DATE - INTERVAL '35 days', 'aceita', 'Analista de QA'),
(23, 9, CURRENT_DATE - INTERVAL '40 days', 'aceita', 'Backend developer'),
(25, 10, CURRENT_DATE - INTERVAL '25 days', 'aceita', 'Mobile developer'),
(26, 11, CURRENT_DATE - INTERVAL '55 days', 'aceita', 'Product Manager'),
(27, 11, CURRENT_DATE - INTERVAL '60 days', 'aceita', 'Arquiteto de software'),

-- Conexões pendentes
(17, 12, CURRENT_DATE - INTERVAL '5 days', 'pendente', 'Interessado em marketing'),
(18, 8, CURRENT_DATE - INTERVAL '10 days', 'pendente', 'Marketing digital'),
(21, 10, CURRENT_DATE - INTERVAL '7 days', 'pendente', 'Recém-formado em busca de oportunidades'),
(22, 9, CURRENT_DATE - INTERVAL '12 days', 'pendente', 'Designer UX'),
(24, 12, CURRENT_DATE - INTERVAL '8 days', 'pendente', 'Desenvolvedora junior');

-- ============================================================================
-- 17. HISTÓRICO DE STATUS (AUDITORIA)
-- ============================================================================

INSERT INTO historico_status (tabela_origem, id_registro, status_anterior, status_novo, id_usuario_responsavel, motivo, data_alteracao) VALUES
('candidaturas', 1, 'pendente', 'aprovado', 8, 'Candidato aprovado no processo seletivo', CURRENT_DATE - INTERVAL '3 days'),
('candidaturas', 2, 'pendente', 'rejeitado', 8, 'Não atendeu critérios técnicos', CURRENT_DATE - INTERVAL '7 days'),
('candidaturas', 12, 'pendente', 'aprovado', 12, 'Excelente fit para a posição', CURRENT_DATE - INTERVAL '5 days'),
('candidaturas', 10, 'pendente', 'aprovado', null, 'Processo seletivo concluído com sucesso', CURRENT_DATE - INTERVAL '20 days'),
('vagas', 15, 'aberta', 'fechada', 8, 'Vaga preenchida', CURRENT_DATE - INTERVAL '10 days'),
('vagas', 16, 'aberta', 'fechada', 9, 'Fim do período de contratação', CURRENT_DATE - INTERVAL '30 days'),
('candidatos', 13, null, 'cadastrado', 13, 'Cadastro inicial do candidato', CURRENT_DATE - INTERVAL '3 months'),
('empresas', 1, 'pendente', 'aprovado', null, 'Empresa aprovada para publicar vagas', CURRENT_DATE - INTERVAL '6 months');

-- ============================================================================
-- MENSAGEM DE SUCESSO
-- ============================================================================

SELECT 
    'Base de dados populada com sucesso!' as status,
    '✅ Dados de teste inseridos para todas as tabelas' as detalhes,
    '🔍 Pronto para executar as consultas do arquivo 07-consultas.sql' as proximos_passos;

-- ============================================================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ============================================================================

SELECT 'RESUMO DOS DADOS INSERIDOS' as categoria, '-' as detalhes
UNION ALL
SELECT 'Usuários:', COUNT(*)::text FROM usuarios
UNION ALL
SELECT 'Empresas:', COUNT(*)::text FROM empresas
UNION ALL
SELECT 'Candidatos:', COUNT(*)::text FROM candidatos
UNION ALL
SELECT 'Recrutadores:', COUNT(*)::text FROM recrutadores
UNION ALL
SELECT 'Vagas:', COUNT(*)::text FROM vagas
UNION ALL
SELECT 'Candidaturas:', COUNT(*)::text FROM candidaturas
UNION ALL
SELECT 'Processos Seletivos:', COUNT(*)::text FROM processos_seletivos
UNION ALL
SELECT 'Habilidades:', COUNT(*)::text FROM habilidades
UNION ALL
SELECT 'Conexões:', COUNT(*)::text FROM conexoes;
