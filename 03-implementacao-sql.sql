-- Configurações iniciais
SET client_encoding = 'UTF8';
SET timezone = 'America/Sao_Paulo';


CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL, -- Hash da senha
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_login TIMESTAMP,
    status_conta VARCHAR(20) DEFAULT 'ativo' CHECK (status_conta IN ('ativo', 'inativo', 'suspenso', 'banido')),
    tipo_usuario VARCHAR(20) NOT NULL CHECK (tipo_usuario IN ('candidato', 'empresa', 'recrutador'))
);

-- Tabela de candidatos (herda de usuarios)
CREATE TABLE candidatos (
    id_candidato INTEGER PRIMARY KEY REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nome_completo VARCHAR(255) NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(20),
    endereco TEXT,
    linkedin_url VARCHAR(255),
    github_url VARCHAR(255),
    nivel_experiencia VARCHAR(20) CHECK (nivel_experiencia IN ('junior', 'pleno', 'senior', 'especialista')),
    salario_pretendido DECIMAL(10,2),
    disponibilidade BOOLEAN DEFAULT true,
    
    -- Validações
    CONSTRAINT chk_data_nascimento CHECK (data_nascimento < CURRENT_DATE),
    CONSTRAINT chk_salario_positivo CHECK (salario_pretendido > 0)
);

-- Tabela de empresas (herda de usuarios)  
CREATE TABLE empresas (
    id_empresa INTEGER PRIMARY KEY REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    setor_atividade VARCHAR(100),
    tamanho_empresa VARCHAR(20) CHECK (tamanho_empresa IN ('startup', 'pequena', 'media', 'grande', 'multinacional')),
    site_url VARCHAR(255),
    descricao TEXT,
    data_fundacao DATE,
    
    -- Validações
    CONSTRAINT chk_data_fundacao CHECK (data_fundacao <= CURRENT_DATE)
);

-- Tabela de recrutadores (herda de usuarios)
CREATE TABLE recrutadores (
    id_recrutador INTEGER PRIMARY KEY REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nome_completo VARCHAR(255) NOT NULL,
    cargo VARCHAR(100),
    telefone VARCHAR(20),
    id_empresa INTEGER NOT NULL REFERENCES empresas(id_empresa) ON DELETE CASCADE
);

-- Categorias de vagas
CREATE TABLE categorias_vaga (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT
);

-- Localizações
CREATE TABLE localizacoes (
    id_localizacao SERIAL PRIMARY KEY,
    pais VARCHAR(100) DEFAULT 'Brasil',
    estado VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    cep VARCHAR(10),
    endereco_completo TEXT
);

-- Habilidades
CREATE TABLE habilidades (
    id_habilidade SERIAL PRIMARY KEY,
    nome_habilidade VARCHAR(100) UNIQUE NOT NULL,
    categoria VARCHAR(50) CHECK (categoria IN ('tecnica', 'comportamental', 'idioma', 'certificacao')),
    descricao TEXT
);

-- Etapas do processo seletivo
CREATE TABLE etapas_processo (
    id_etapa SERIAL PRIMARY KEY,
    nome_etapa VARCHAR(100) NOT NULL,
    descricao TEXT,
    ordem_execucao INTEGER NOT NULL,
    tipo_etapa VARCHAR(30) CHECK (tipo_etapa IN ('triagem', 'entrevista_rh', 'teste_tecnico', 'entrevista_tecnica', 'entrevista_final', 'verificacao_referencias', 'proposta'))
);

-- Vagas de emprego
CREATE TABLE vagas (
    id_vaga SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,
    requisitos TEXT,
    beneficios TEXT,
    salario_min DECIMAL(10,2),
    salario_max DECIMAL(10,2),
    tipo_contrato VARCHAR(20) CHECK (tipo_contrato IN ('clt', 'pj', 'estagio', 'freelancer', 'temporario')),
    modalidade_trabalho VARCHAR(20) CHECK (modalidade_trabalho IN ('presencial', 'remoto', 'hibrido')),
    nivel_experiencia VARCHAR(20) CHECK (nivel_experiencia IN ('junior', 'pleno', 'senior', 'especialista')),
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_expiracao DATE,
    status_vaga VARCHAR(20) DEFAULT 'aberta' CHECK (status_vaga IN ('aberta', 'pausada', 'fechada', 'cancelada')),
    quantidade_vagas INTEGER DEFAULT 1,
    id_empresa INTEGER NOT NULL REFERENCES empresas(id_empresa) ON DELETE CASCADE,
    id_recrutador INTEGER NOT NULL REFERENCES recrutadores(id_recrutador),
    id_categoria INTEGER REFERENCES categorias_vaga(id_categoria),
    id_localizacao INTEGER REFERENCES localizacoes(id_localizacao),
    
    -- Validações
    CONSTRAINT chk_salario_consistente CHECK (salario_max >= salario_min),
    CONSTRAINT chk_quantidade_positiva CHECK (quantidade_vagas > 0),
    CONSTRAINT chk_data_expiracao CHECK (data_expiracao >= CURRENT_DATE),
    CONSTRAINT chk_salarios_positivos CHECK (salario_min > 0 AND salario_max > 0)
);

-- Currículos dos candidatos
CREATE TABLE curriculos (
    id_curriculo SERIAL PRIMARY KEY,
    resumo_profissional TEXT,
    objetivo TEXT,
    arquivo_url VARCHAR(500),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_candidato INTEGER UNIQUE NOT NULL REFERENCES candidatos(id_candidato) ON DELETE CASCADE
);

-- Experiências profissionais
CREATE TABLE experiencias_profissionais (
    id_experiencia SERIAL PRIMARY KEY,
    empresa VARCHAR(255) NOT NULL,
    cargo VARCHAR(255) NOT NULL,
    descricao_atividades TEXT,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    emprego_atual BOOLEAN DEFAULT false,
    id_curriculo INTEGER NOT NULL REFERENCES curriculos(id_curriculo) ON DELETE CASCADE,
    
    -- Validações
    CONSTRAINT chk_periodo_experiencia CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT chk_emprego_atual_sem_data_fim CHECK (NOT (emprego_atual = true AND data_fim IS NOT NULL))
);

-- Formações acadêmicas
CREATE TABLE formacoes_academicas (
    id_formacao SERIAL PRIMARY KEY,
    instituicao VARCHAR(255) NOT NULL,
    curso VARCHAR(255) NOT NULL,
    grau VARCHAR(50) CHECK (grau IN ('tecnico', 'graduacao', 'pos-graduacao', 'mestrado', 'doutorado')),
    data_inicio DATE NOT NULL,
    data_conclusao DATE,
    em_andamento BOOLEAN DEFAULT false,
    id_curriculo INTEGER NOT NULL REFERENCES curriculos(id_curriculo) ON DELETE CASCADE,
    
    -- Validações
    CONSTRAINT chk_periodo_formacao CHECK (data_conclusao IS NULL OR data_conclusao >= data_inicio),
    CONSTRAINT chk_formacao_andamento CHECK (NOT (em_andamento = true AND data_conclusao IS NOT NULL))
);

-- Habilidades dos candidatos
CREATE TABLE candidatos_habilidades (
    id_candidato INTEGER NOT NULL REFERENCES candidatos(id_candidato) ON DELETE CASCADE,
    id_habilidade INTEGER NOT NULL REFERENCES habilidades(id_habilidade) ON DELETE CASCADE,
    nivel_proficiencia VARCHAR(20) CHECK (nivel_proficiencia IN ('basico', 'intermediario', 'avancado', 'especialista')),
    anos_experiencia INTEGER CHECK (anos_experiencia >= 0),
    PRIMARY KEY (id_candidato, id_habilidade)
);

-- Habilidades requeridas pelas vagas
CREATE TABLE vagas_habilidades (
    id_vaga INTEGER NOT NULL REFERENCES vagas(id_vaga) ON DELETE CASCADE,
    id_habilidade INTEGER NOT NULL REFERENCES habilidades(id_habilidade) ON DELETE CASCADE,
    nivel_requerido VARCHAR(20) CHECK (nivel_requerido IN ('basico', 'intermediario', 'avancado', 'especialista')),
    obrigatoria BOOLEAN DEFAULT false,
    PRIMARY KEY (id_vaga, id_habilidade)
);

-- Candidaturas às vagas
CREATE TABLE candidaturas (
    id_candidatura SERIAL PRIMARY KEY,
    data_candidatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_candidatura VARCHAR(30) DEFAULT 'pendente' CHECK (status_candidatura IN ('pendente', 'em_analise', 'em_processo', 'aprovado', 'rejeitado', 'desistiu')),
    carta_apresentacao TEXT,
    id_candidato INTEGER NOT NULL REFERENCES candidatos(id_candidato) ON DELETE CASCADE,
    id_vaga INTEGER NOT NULL REFERENCES vagas(id_vaga) ON DELETE CASCADE,
    
    -- Um candidato só pode se candidatar uma vez por vaga
    UNIQUE(id_candidato, id_vaga)
);

-- Processos seletivos
CREATE TABLE processos_seletivos (
    id_processo SERIAL PRIMARY KEY,
    id_candidatura INTEGER UNIQUE NOT NULL REFERENCES candidaturas(id_candidatura) ON DELETE CASCADE,
    etapa_atual INTEGER REFERENCES etapas_processo(id_etapa),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fim TIMESTAMP,
    status_processo VARCHAR(30) DEFAULT 'iniciado' CHECK (status_processo IN ('iniciado', 'em_andamento', 'concluido', 'cancelado')),
    observacoes TEXT,
    
    -- Validações
    CONSTRAINT chk_periodo_processo CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- Avaliações dos candidatos
CREATE TABLE avaliacoes_candidatos (
    id_avaliacao SERIAL PRIMARY KEY,
    nota DECIMAL(3,2) CHECK (nota >= 0 AND nota <= 10),
    comentarios TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_processo INTEGER NOT NULL REFERENCES processos_seletivos(id_processo) ON DELETE CASCADE,
    id_etapa INTEGER NOT NULL REFERENCES etapas_processo(id_etapa),
    id_avaliador INTEGER NOT NULL REFERENCES usuarios(id_usuario)
);

-- Sistema de mensagens
CREATE TABLE mensagens (
    id_mensagem SERIAL PRIMARY KEY,
    assunto VARCHAR(255),
    conteudo TEXT NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT false,
    id_remetente INTEGER NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    id_destinatario INTEGER NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    
    -- Validação para não enviar mensagem para si mesmo
    CONSTRAINT chk_remetente_diferente_destinatario CHECK (id_remetente != id_destinatario)
);

-- Conexões entre usuários (networking)
CREATE TABLE conexoes (
    id_conexao SERIAL PRIMARY KEY,
    data_conexao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_conexao VARCHAR(20) DEFAULT 'pendente' CHECK (status_conexao IN ('pendente', 'aceita', 'rejeitada', 'bloqueada')),
    id_solicitante INTEGER NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    id_receptor INTEGER NOT NULL REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    
    -- Evita conexões duplicadas e auto-conexões
    UNIQUE(id_solicitante, id_receptor),
    CONSTRAINT chk_conexao_diferentes CHECK (id_solicitante != id_receptor)
);

-- Histórico de mudanças de status
CREATE TABLE historico_status (
    id_historico SERIAL PRIMARY KEY,
    tabela_origem VARCHAR(50) NOT NULL,
    id_registro INTEGER NOT NULL,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50) NOT NULL,
    data_mudanca TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario_responsavel INTEGER REFERENCES usuarios(id_usuario),
    motivo TEXT
);

-- Inserindo categorias padrão de vagas
INSERT INTO categorias_vaga (nome_categoria, descricao) VALUES
('Tecnologia da Informação', 'Vagas relacionadas a desenvolvimento, infraestrutura e TI'),
('Engenharia', 'Vagas para engenheiros de diversas especialidades'),
('Marketing', 'Vagas na área de marketing digital e tradicional'),
('Vendas', 'Oportunidades em vendas e relacionamento com clientes'),
('Recursos Humanos', 'Vagas na área de gestão de pessoas'),
('Financeiro', 'Oportunidades em finanças e contabilidade'),
('Administrativo', 'Vagas administrativas e de apoio'),
('Saúde', 'Oportunidades na área da saúde'),
('Educação', 'Vagas em educação e treinamento'),
('Jurídico', 'Oportunidades na área jurídica');

-- Inserindo etapas padrão do processo seletivo
INSERT INTO etapas_processo (nome_etapa, descricao, ordem_execucao, tipo_etapa) VALUES
('Triagem Curricular', 'Análise inicial do currículo do candidato', 1, 'triagem'),
('Entrevista RH', 'Entrevista com o setor de recursos humanos', 2, 'entrevista_rh'),
('Teste Técnico', 'Avaliação das competências técnicas', 3, 'teste_tecnico'),
('Entrevista Técnica', 'Entrevista com a equipe técnica', 4, 'entrevista_tecnica'),
('Entrevista Final', 'Entrevista final com gestores', 5, 'entrevista_final'),
('Verificação de Referências', 'Checagem de referências profissionais', 6, 'verificacao_referencias'),
('Proposta', 'Apresentação da proposta de contratação', 7, 'proposta');

-- Inserindo algumas habilidades essenciais
INSERT INTO habilidades (nome_habilidade, categoria, descricao) VALUES
('JavaScript', 'tecnica', 'Linguagem de programação para desenvolvimento web'),
('Python', 'tecnica', 'Linguagem de programação versátil'),
('SQL', 'tecnica', 'Linguagem para banco de dados'),
('Java', 'tecnica', 'Linguagem de programação orientada a objetos'),
('React', 'tecnica', 'Biblioteca JavaScript para interfaces'),
('Node.js', 'tecnica', 'Runtime JavaScript para backend'),
('Comunicação', 'comportamental', 'Habilidade de comunicação eficaz'),
('Liderança', 'comportamental', 'Capacidade de liderar equipes'),
('Trabalho em Equipe', 'comportamental', 'Colaboração efetiva em grupo'),
('Inglês', 'idioma', 'Proficiência na língua inglesa'),
('Espanhol', 'idioma', 'Proficiência na língua espanhola'),
('AWS', 'certificacao', 'Amazon Web Services'),
('Scrum Master', 'certificacao', 'Certificação em metodologia ágil');

-- Inserindo algumas localizações principais
INSERT INTO localizacoes (pais, estado, cidade, cep) VALUES
('Brasil', 'São Paulo', 'São Paulo', '01000-000'),
('Brasil', 'Rio de Janeiro', 'Rio de Janeiro', '20000-000'),
('Brasil', 'Minas Gerais', 'Belo Horizonte', '30000-000'),
('Brasil', 'Paraná', 'Curitiba', '80000-000'),
('Brasil', 'Rio Grande do Sul', 'Porto Alegre', '90000-000'),
('Brasil', 'Bahia', 'Salvador', '40000-000'),
('Brasil', 'Pernambuco', 'Recife', '50000-000'),
('Brasil', 'Ceará', 'Fortaleza', '60000-000'),
('Brasil', 'Distrito Federal', 'Brasília', '70000-000'),
('Brasil', 'Santa Catarina', 'Florianópolis', '88000-000');

-- Mostra o resumo das tabelas criadas
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;
