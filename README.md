# Sistema de Recrutamento - Trabalho de Banco de Dados

## Descrição do Projeto

Este trabalho acadêmico apresenta o desenvolvimento completo de um banco de dados para um sistema de recrutamento online, similar ao LinkedIn ou Gupy. O sistema permite a interação entre candidatos, empresas e recrutadores para processos seletivos e vagas de emprego.

## Estrutura do Trabalho

1. **[Modelo Conceitual](./01-modelo-conceitual.md)** - Identificação de entidades e relacionamentos
2. **[Esquema Relacional](./02-esquema-relacional.md)** - Mapeamento para modelo relacional
3. **[Implementação SQL](./03-implementacao-sql.sql)** - Criação das tabelas e estruturas
4. **[Stored Procedures](./04-stored-procedures.sql)** - Funções e procedimentos
5. **[Triggers](./05-triggers.sql)** - Automatizações e regras de negócio
6. **[Views](./06-views.sql)** - Visões para consultas específicas
7. **[Consultas SQL](./07-consultas.sql)** - Queries contextualizadas e úteis
8. **[Índices](./08-indices.sql)** - Otimização de performance

## Funcionalidades Principais

- Cadastro e gerenciamento de candidatos
- Cadastro e gerenciamento de empresas
- Publicação e gestão de vagas
- Sistema de candidaturas
- Avaliação e feedback de candidatos
- Networking entre usuários
- Sistema de mensagens
- Histórico completo de atividades

## Tecnologia

- **SGBD:** PostgreSQL
- **Padrão:** SQL ANSI com extensões PostgreSQL
- **Versão mínima recomendada:** PostgreSQL 12+

## Como Executar

1. Certifique-se de ter o PostgreSQL instalado
2. Execute os scripts na ordem indicada:
   ```sql
   \i 03-implementacao-sql.sql
   \i 04-stored-procedures.sql
   \i 05-triggers.sql
   \i 06-views.sql
   \i 08-indices.sql
   ```
3. Teste com as consultas em `07-consultas.sql`

## Autor

João - Disciplina de Banco de Dados
Data: Julho 2025
