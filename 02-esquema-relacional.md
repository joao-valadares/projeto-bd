# Esquema Relacional - Sistema de Recrutamento

## Descrição

Este documento apresenta o mapeamento do modelo conceitual para o esquema relacional, adaptado para PostgreSQL. O esquema inclui 20 tabelas principais com seus atributos, tipos de dados, chaves primárias e estrangeiras.

## Tabelas do Sistema

### 1. usuarios
```sql
usuarios (
    id_usuario SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_login TIMESTAMP,
    status_conta VARCHAR(20) DEFAULT 'ativo',
    tipo_usuario VARCHAR(20) NOT NULL CHECK (tipo_usuario IN ('candidato', 'empresa', 'recrutador'))
)
```

### 2. candidatos
```sql
candidatos (
    id_candidato INTEGER PRIMARY KEY REFERENCES usuarios(id_usuario),
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nome_completo VARCHAR(255) NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(20),
    endereco TEXT,
    linkedin_url VARCHAR(255),
    github_url VARCHAR(255),
    nivel_experiencia VARCHAR(20) CHECK (nivel_experiencia IN ('junior', 'pleno', 'senior', 'especialista')),
    salario_pretendido DECIMAL(10,2),
    disponibilidade BOOLEAN DEFAULT true
)
```

### 3. empresas
```sql
empresas (
    id_empresa INTEGER PRIMARY KEY REFERENCES usuarios(id_usuario),
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    setor_atividade VARCHAR(100),
    tamanho_empresa VARCHAR(20) CHECK (tamanho_empresa IN ('startup', 'pequena', 'media', 'grande', 'multinacional')),
    site_url VARCHAR(255),
    descricao TEXT,
    data_fundacao DATE
)
```

### 4. recrutadores
```sql
recrutadores (
    id_recrutador INTEGER PRIMARY KEY REFERENCES usuarios(id_usuario),
    cpf VARCHAR(14) UNIQUE NOT NULL,
    nome_completo VARCHAR(255) NOT NULL,
    cargo VARCHAR(100),
    telefone VARCHAR(20),
    id_empresa INTEGER NOT NULL REFERENCES empresas(id_empresa)
)
```

### 5. categorias_vaga
```sql
categorias_vaga (
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT
)
```

### 6. localizacoes
```sql
localizacoes (
    id_localizacao SERIAL PRIMARY KEY,
    pais VARCHAR(100) DEFAULT 'Brasil',
    estado VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    cep VARCHAR(10),
    endereco_completo TEXT
)
```

### 7. vagas
```sql
vagas (
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
    id_empresa INTEGER NOT NULL REFERENCES empresas(id_empresa),
    id_recrutador INTEGER NOT NULL REFERENCES recrutadores(id_recrutador),
    id_categoria INTEGER REFERENCES categorias_vaga(id_categoria),
    id_localizacao INTEGER REFERENCES localizacoes(id_localizacao)
)
```

### 8. curriculos
```sql
curriculos (
    id_curriculo SERIAL PRIMARY KEY,
    resumo_profissional TEXT,
    objetivo TEXT,
    arquivo_url VARCHAR(500),
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_candidato INTEGER UNIQUE NOT NULL REFERENCES candidatos(id_candidato)
)
```

### 9. experiencias_profissionais
```sql
experiencias_profissionais (
    id_experiencia SERIAL PRIMARY KEY,
    empresa VARCHAR(255) NOT NULL,
    cargo VARCHAR(255) NOT NULL,
    descricao_atividades TEXT,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    emprego_atual BOOLEAN DEFAULT false,
    id_curriculo INTEGER NOT NULL REFERENCES curriculos(id_curriculo)
)
```

### 10. formacoes_academicas
```sql
formacoes_academicas (
    id_formacao SERIAL PRIMARY KEY,
    instituicao VARCHAR(255) NOT NULL,
    curso VARCHAR(255) NOT NULL,
    grau VARCHAR(50) CHECK (grau IN ('tecnico', 'graduacao', 'pos-graduacao', 'mestrado', 'doutorado')),
    data_inicio DATE NOT NULL,
    data_conclusao DATE,
    em_andamento BOOLEAN DEFAULT false,
    id_curriculo INTEGER NOT NULL REFERENCES curriculos(id_curriculo)
)
```

### 11. habilidades
```sql
habilidades (
    id_habilidade SERIAL PRIMARY KEY,
    nome_habilidade VARCHAR(100) UNIQUE NOT NULL,
    categoria VARCHAR(50) CHECK (categoria IN ('tecnica', 'comportamental', 'idioma', 'certificacao')),
    descricao TEXT
)
```

### 12. candidatos_habilidades
```sql
candidatos_habilidades (
    id_candidato INTEGER NOT NULL REFERENCES candidatos(id_candidato),
    id_habilidade INTEGER NOT NULL REFERENCES habilidades(id_habilidade),
    nivel_proficiencia VARCHAR(20) CHECK (nivel_proficiencia IN ('basico', 'intermediario', 'avancado', 'especialista')),
    anos_experiencia INTEGER,
    PRIMARY KEY (id_candidato, id_habilidade)
)
```

### 13. vagas_habilidades
```sql
vagas_habilidades (
    id_vaga INTEGER NOT NULL REFERENCES vagas(id_vaga),
    id_habilidade INTEGER NOT NULL REFERENCES habilidades(id_habilidade),
    nivel_requerido VARCHAR(20) CHECK (nivel_requerido IN ('basico', 'intermediario', 'avancado', 'especialista')),
    obrigatoria BOOLEAN DEFAULT false,
    PRIMARY KEY (id_vaga, id_habilidade)
)
```

### 14. candidaturas
```sql
candidaturas (
    id_candidatura SERIAL PRIMARY KEY,
    data_candidatura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_candidatura VARCHAR(30) DEFAULT 'pendente' CHECK (status_candidatura IN ('pendente', 'em_analise', 'em_processo', 'aprovado', 'rejeitado', 'desistiu')),
    carta_apresentacao TEXT,
    id_candidato INTEGER NOT NULL REFERENCES candidatos(id_candidato),
    id_vaga INTEGER NOT NULL REFERENCES vagas(id_vaga),
    UNIQUE(id_candidato, id_vaga)
)
```

### 15. etapas_processo
```sql
etapas_processo (
    id_etapa SERIAL PRIMARY KEY,
    nome_etapa VARCHAR(100) NOT NULL,
    descricao TEXT,
    ordem_execucao INTEGER NOT NULL,
    tipo_etapa VARCHAR(30) CHECK (tipo_etapa IN ('triagem', 'entrevista_rh', 'teste_tecnico', 'entrevista_tecnica', 'entrevista_final', 'verificacao_referencias', 'proposta'))
)
```

### 16. processos_seletivos
```sql
processos_seletivos (
    id_processo SERIAL PRIMARY KEY,
    id_candidatura INTEGER UNIQUE NOT NULL REFERENCES candidaturas(id_candidatura),
    etapa_atual INTEGER REFERENCES etapas_processo(id_etapa),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fim TIMESTAMP,
    status_processo VARCHAR(30) DEFAULT 'iniciado' CHECK (status_processo IN ('iniciado', 'em_andamento', 'concluido', 'cancelado')),
    observacoes TEXT
)
```

### 17. avaliacoes_candidatos
```sql
avaliacoes_candidatos (
    id_avaliacao SERIAL PRIMARY KEY,
    nota DECIMAL(3,2) CHECK (nota >= 0 AND nota <= 10),
    comentarios TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_processo INTEGER NOT NULL REFERENCES processos_seletivos(id_processo),
    id_etapa INTEGER NOT NULL REFERENCES etapas_processo(id_etapa),
    id_avaliador INTEGER NOT NULL REFERENCES usuarios(id_usuario)
)
```

### 18. mensagens
```sql
mensagens (
    id_mensagem SERIAL PRIMARY KEY,
    assunto VARCHAR(255),
    conteudo TEXT NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT false,
    id_remetente INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    id_destinatario INTEGER NOT NULL REFERENCES usuarios(id_usuario)
)
```

### 19. conexoes
```sql
conexoes (
    id_conexao SERIAL PRIMARY KEY,
    data_conexao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_conexao VARCHAR(20) DEFAULT 'pendente' CHECK (status_conexao IN ('pendente', 'aceita', 'rejeitada', 'bloqueada')),
    id_solicitante INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    id_receptor INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    UNIQUE(id_solicitante, id_receptor),
    CHECK (id_solicitante != id_receptor)
)
```

### 20. historico_status
```sql
historico_status (
    id_historico SERIAL PRIMARY KEY,
    tabela_origem VARCHAR(50) NOT NULL,
    id_registro INTEGER NOT NULL,
    status_anterior VARCHAR(50),
    status_novo VARCHAR(50) NOT NULL,
    data_mudanca TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario_responsavel INTEGER REFERENCES usuarios(id_usuario),
    motivo TEXT
)
```

## Relacionamentos e Restrições

### Chaves Estrangeiras Principais:
- **candidatos.id_candidato** → usuarios.id_usuario
- **empresas.id_empresa** → usuarios.id_usuario  
- **recrutadores.id_recrutador** → usuarios.id_usuario
- **recrutadores.id_empresa** → empresas.id_empresa
- **vagas.id_empresa** → empresas.id_empresa
- **vagas.id_recrutador** → recrutadores.id_recrutador
- **candidaturas.id_candidato** → candidatos.id_candidato
- **candidaturas.id_vaga** → vagas.id_vaga

### Restrições de Integridade:
1. **CHECK Constraints:** Validam valores específicos para status, tipos e níveis
2. **UNIQUE Constraints:** Evitam duplicações (email, CPF, CNPJ)
3. **NOT NULL:** Garantem campos obrigatórios
4. **DEFAULT Values:** Valores padrão para timestamps e status

### Justificativas do Esquema:
- **Normalização:** Tabelas normalizadas até a 3ª Forma Normal
- **Flexibilidade:** Suporta diferentes cenários de recrutamento
- **Performance:** Chaves adequadas para consultas frequentes
- **Integridade:** Restrições garantem consistência dos dados
- **Auditoria:** Tabela de histórico para rastreabilidade
- **Escalabilidade:** Estrutura permite crescimento do sistema
