# Modelo Conceitual - Sistema de Recrutamento

## Descrição Geral

O modelo conceitual apresenta as entidades principais e seus relacionamentos para um sistema de recrutamento online. O sistema facilita a conexão entre candidatos, empresas e recrutadores, proporcionando um ambiente completo para processos seletivos.

## Entidades Identificadas

### 1. **USUARIO**
- Entidade base que representa todos os usuários do sistema
- **Atributos:** id_usuario, email, senha, data_cadastro, ultimo_login, status_conta, tipo_usuario

### 2. **CANDIDATO**
- Especialização de USUARIO para pessoas físicas que buscam emprego
- **Atributos:** cpf, nome_completo, data_nascimento, telefone, endereco, linkedin_url, github_url, nivel_experiencia, salario_pretendido, disponibilidade

### 3. **EMPRESA**
- Especialização de USUARIO para organizações que oferecem vagas
- **Atributos:** cnpj, razao_social, nome_fantasia, setor_atividade, tamanho_empresa, site_url, descricao, data_fundacao

### 4. **RECRUTADOR**
- Especialização de USUARIO para profissionais de RH
- **Atributos:** cpf, nome_completo, cargo, telefone, id_empresa (FK)

### 5. **VAGA**
- Representa as oportunidades de emprego disponíveis
- **Atributos:** id_vaga, titulo, descricao, requisitos, beneficios, salario_min, salario_max, tipo_contrato, modalidade_trabalho, nivel_experiencia, data_publicacao, data_expiracao, status_vaga, quantidade_vagas, id_empresa (FK), id_recrutador (FK)

### 6. **CANDIDATURA**
- Representa a aplicação de um candidato para uma vaga
- **Atributos:** id_candidatura, data_candidatura, status_candidatura, carta_apresentacao, id_candidato (FK), id_vaga (FK)

### 7. **CURRICULO**
- Armazena informações do currículo dos candidatos
- **Atributos:** id_curriculo, resumo_profissional, objetivo, arquivo_url, data_atualizacao, id_candidato (FK)

### 8. **EXPERIENCIA_PROFISSIONAL**
- Histórico profissional dos candidatos
- **Atributos:** id_experiencia, empresa, cargo, descricao_atividades, data_inicio, data_fim, emprego_atual, id_curriculo (FK)

### 9. **FORMACAO_ACADEMICA**
- Educação formal dos candidatos
- **Atributos:** id_formacao, instituicao, curso, grau, data_inicio, data_conclusao, em_andamento, id_curriculo (FK)

### 10. **HABILIDADE**
- Competências técnicas e comportamentais
- **Atributos:** id_habilidade, nome_habilidade, categoria, descricao

### 11. **CANDIDATO_HABILIDADE**
- Relacionamento entre candidatos e suas habilidades
- **Atributos:** id_candidato (FK), id_habilidade (FK), nivel_proficiencia, anos_experiencia

### 12. **VAGA_HABILIDADE**
- Habilidades requeridas para uma vaga
- **Atributos:** id_vaga (FK), id_habilidade (FK), nivel_requerido, obrigatoria

### 13. **PROCESSO_SELETIVO**
- Etapas do processo de seleção
- **Atributos:** id_processo, id_candidatura (FK), etapa_atual, data_inicio, data_fim, status_processo, observacoes

### 14. **ETAPA_PROCESSO**
- Diferentes fases do processo seletivo
- **Atributos:** id_etapa, nome_etapa, descricao, ordem_execucao, tipo_etapa

### 15. **AVALIACAO_CANDIDATO**
- Feedback sobre candidatos em processos seletivos
- **Atributos:** id_avaliacao, nota, comentarios, data_avaliacao, id_processo (FK), id_etapa (FK), id_avaliador (FK)

### 16. **MENSAGEM**
- Sistema de comunicação entre usuários
- **Atributos:** id_mensagem, assunto, conteudo, data_envio, lida, id_remetente (FK), id_destinatario (FK)

### 17. **CONEXAO**
- Networking entre usuários (similar ao LinkedIn)
- **Atributos:** id_conexao, data_conexao, status_conexao, id_solicitante (FK), id_receptor (FK)

### 18. **CATEGORIA_VAGA**
- Classificação das vagas por área/setor
- **Atributos:** id_categoria, nome_categoria, descricao

### 19. **LOCALIZACAO**
- Informações geográficas para vagas e usuários
- **Atributos:** id_localizacao, pais, estado, cidade, cep, endereco_completo

### 20. **HISTORICO_STATUS**
- Auditoria de mudanças de status
- **Atributos:** id_historico, tabela_origem, id_registro, status_anterior, status_novo, data_mudanca, id_usuario_responsavel (FK), motivo

## Relacionamentos Principais

1. **USUARIO** → **CANDIDATO** (ISA - Especialização)
2. **USUARIO** → **EMPRESA** (ISA - Especialização)  
3. **USUARIO** → **RECRUTADOR** (ISA - Especialização)
4. **EMPRESA** → **VAGA** (1:N - Uma empresa pode ter várias vagas)
5. **RECRUTADOR** → **VAGA** (1:N - Um recrutador pode gerenciar várias vagas)
6. **CANDIDATO** → **CANDIDATURA** (1:N - Um candidato pode se candidatar a várias vagas)
7. **VAGA** → **CANDIDATURA** (1:N - Uma vaga pode ter várias candidaturas)
8. **CANDIDATO** → **CURRICULO** (1:1 - Cada candidato tem um currículo)
9. **CURRICULO** → **EXPERIENCIA_PROFISSIONAL** (1:N)
10. **CURRICULO** → **FORMACAO_ACADEMICA** (1:N)
11. **CANDIDATO** ↔ **HABILIDADE** (N:M - através de CANDIDATO_HABILIDADE)
12. **VAGA** ↔ **HABILIDADE** (N:M - através de VAGA_HABILIDADE)
13. **CANDIDATURA** → **PROCESSO_SELETIVO** (1:1)
14. **PROCESSO_SELETIVO** → **AVALIACAO_CANDIDATO** (1:N)
15. **USUARIO** → **MENSAGEM** (1:N como remetente e 1:N como destinatário)
16. **USUARIO** ↔ **USUARIO** (N:M através de CONEXAO para networking)
17. **VAGA** → **CATEGORIA_VAGA** (N:1)
18. **VAGA** → **LOCALIZACAO** (N:1)

## Justificativas do Modelo

- **Flexibilidade:** O modelo suporta diferentes tipos de usuários através de especialização
- **Escalabilidade:** Permite crescimento do sistema com novas funcionalidades
- **Integridade:** Relacionamentos bem definidos garantem consistência dos dados
- **Auditoria:** Histórico de mudanças para rastreabilidade
- **Funcionalidade completa:** Cobre desde cadastros até processos seletivos complexos
- **Networking:** Implementa funcionalidades sociais similares ao LinkedIn
