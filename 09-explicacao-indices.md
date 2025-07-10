# Explicação dos Índices - Sistema de Recrutamento

## Visão Geral

Este documento explica os índices criados para otimizar o sistema de recrutamento, detalhando suas justificativas e impacto nas consultas do sistema.

## Índices Implementados

### 1. Índices para Usuários (3 índices)

#### `idx_usuarios_email_ativo`
- **Tipo:** Índice parcial B-tree
- **Campos:** email
- **Condição:** WHERE status_conta = 'ativo'
- **Justificativa:** Otimiza o processo de login, que é uma das operações mais frequentes do sistema
- **Consultas beneficiadas:** Login de usuários, validação de emails ativos

#### `idx_usuarios_tipo_status`
- **Tipo:** Índice composto B-tree
- **Campos:** tipo_usuario, status_conta
- **Justificativa:** Facilita consultas que filtram usuários por tipo (candidato, empresa, recrutador) e status
- **Consultas beneficiadas:** Dashboards administrativos, estatísticas por tipo de usuário

#### `idx_usuarios_ultimo_login`
- **Tipo:** Índice parcial B-tree (DESC)
- **Campos:** ultimo_login
- **Condição:** WHERE ultimo_login IS NOT NULL
- **Justificativa:** Otimiza relatórios de atividade e identificação de usuários ativos
- **Consultas beneficiadas:** Relatórios de engajamento, análises de atividade

### 2. Índices para Vagas (5 índices)

#### `idx_vagas_abertas_ativas`
- **Tipo:** Índice parcial composto B-tree
- **Campos:** status_vaga, data_expiracao, data_publicacao DESC
- **Condição:** WHERE status_vaga = 'aberta'
- **Justificativa:** **CRÍTICO** - Esta é a consulta mais importante do sistema. Candidatos constantemente buscam vagas abertas e não expiradas
- **Consultas beneficiadas:** Busca principal de vagas, listagem de oportunidades

#### `idx_vagas_empresa_status`
- **Tipo:** Índice composto B-tree
- **Campos:** id_empresa, status_vaga, data_publicacao DESC
- **Justificativa:** Otimiza o dashboard das empresas para visualizar suas vagas
- **Consultas beneficiadas:** Dashboard empresarial, gestão de vagas por empresa

#### `idx_vagas_categoria_localizacao`
- **Tipo:** Índice composto B-tree
- **Campos:** id_categoria, id_localizacao, status_vaga
- **Condição:** WHERE status_vaga = 'aberta'
- **Justificativa:** Facilita buscas por área de atuação e localização geográfica
- **Consultas beneficiadas:** Filtros de busca avançada, análises por setor/região

#### `idx_vagas_salario_nivel`
- **Tipo:** Índice composto B-tree
- **Campos:** nivel_experiencia, salario_min, salario_max
- **Condição:** WHERE salarios não nulos
- **Justificativa:** Otimiza consultas salariais e matching por nível de experiência
- **Consultas beneficiadas:** Análises salariais, compatibilidade candidato-vaga

#### `idx_vagas_modalidade_publicacao`
- **Tipo:** Índice composto B-tree
- **Campos:** modalidade_trabalho, data_publicacao DESC
- **Condição:** WHERE status_vaga = 'aberta'
- **Justificativa:** Suporta análises de tendências de trabalho remoto/híbrido
- **Consultas beneficiadas:** Relatórios de modalidades, tendências do mercado

### 3. Índices para Candidaturas (4 índices)

#### `idx_candidaturas_candidato_status`
- **Tipo:** Índice composto B-tree
- **Campos:** id_candidato, status_candidatura, data_candidatura DESC
- **Justificativa:** **CRÍTICO** - Otimiza o dashboard do candidato e acompanhamento de candidaturas
- **Consultas beneficiadas:** Histórico do candidato, status de candidaturas

#### `idx_candidaturas_vaga_status`
- **Tipo:** Índice composto B-tree
- **Campos:** id_vaga, status_candidatura, data_candidatura DESC
- **Justificativa:** **CRÍTICO** - Otimiza o dashboard das empresas para ver candidatos por vaga
- **Consultas beneficiadas:** Gestão de candidatos por vaga, análise de candidaturas

#### `idx_candidaturas_data_status`
- **Tipo:** Índice composto B-tree
- **Campos:** data_candidatura DESC, status_candidatura
- **Justificativa:** Facilita relatórios temporais e análises de período
- **Consultas beneficiadas:** Relatórios mensais, análises de sazonalidade

#### `idx_candidaturas_unica`
- **Tipo:** Índice único
- **Campos:** id_candidato, id_vaga
- **Justificativa:** **INTEGRIDADE** - Garante que um candidato se candidate apenas uma vez por vaga
- **Consultas beneficiadas:** Validação de duplicatas, verificação rápida de candidatura existente

### 4. Índices para Habilidades (4 índices)

#### `idx_habilidades_categoria_nome`
- **Tipo:** Índice composto B-tree
- **Campos:** categoria, nome_habilidade
- **Justificativa:** Facilita busca de habilidades por tipo (técnica, comportamental, etc.)
- **Consultas beneficiadas:** Catalogação de habilidades, busca por categoria

#### `idx_candidatos_habilidades_nivel`
- **Tipo:** Índice composto B-tree
- **Campos:** id_candidato, nivel_proficiencia, anos_experiencia DESC
- **Justificativa:** **CRITICAL** - Otimiza algoritmos de matching candidato-vaga
- **Consultas beneficiadas:** Compatibilidade de habilidades, busca de candidatos qualificados

#### `idx_vagas_habilidades_obrigatoria`
- **Tipo:** Índice composto B-tree
- **Campos:** id_vaga, obrigatoria, nivel_requerido
- **Justificativa:** Otimiza verificação de requisitos obrigatórios vs desejáveis
- **Consultas beneficiadas:** Matching de requisitos, análise de compatibilidade

#### `idx_vagas_habilidades_demanda`
- **Tipo:** Índice composto B-tree
- **Campos:** id_habilidade, obrigatoria, nivel_requerido
- **Justificativa:** Facilita análises de demanda do mercado por habilidades específicas
- **Consultas beneficiadas:** Relatórios de tendências, análise de mercado

### 5. Índices para Processos Seletivos (4 índices)

#### `idx_processos_candidatura_status`
- **Tipo:** Índice composto B-tree
- **Campos:** id_candidatura, status_processo, data_inicio DESC
- **Justificativa:** Otimiza acompanhamento individual de processos
- **Consultas beneficiadas:** Status de processo específico, histórico de candidatura

#### `idx_processos_etapa_data`
- **Tipo:** Índice parcial composto B-tree
- **Campos:** etapa_atual, data_inicio DESC
- **Condição:** WHERE status_processo = 'em_andamento'
- **Justificativa:** Facilita gestão de processos ativos por etapa
- **Consultas beneficiadas:** Dashboard de RH, gestão de fluxo de processos

#### `idx_avaliacoes_processo_data`
- **Tipo:** Índice composto B-tree
- **Campos:** id_processo, data_avaliacao DESC
- **Justificativa:** Otimiza consulta de avaliações por processo específico
- **Consultas beneficiadas:** Histórico de avaliações, feedback de candidatos

#### `idx_avaliacoes_etapa_nota`
- **Tipo:** Índice composto B-tree
- **Campos:** id_etapa, nota DESC, data_avaliacao DESC
- **Justificativa:** Facilita análises de performance por etapa do processo
- **Consultas beneficiadas:** Análise de gargalos, estatísticas de aprovação

### 6. Índices para Currículos (4 índices)

#### `idx_curriculos_atualizacao`
- **Tipo:** Índice B-tree (DESC)
- **Campos:** data_atualizacao DESC
- **Justificativa:** Identifica currículos mais atualizados (candidatos ativos)
- **Consultas beneficiadas:** Busca de candidatos ativos, priorização por atualização

#### `idx_experiencias_atuais`
- **Tipo:** Índice parcial composto B-tree
- **Campos:** id_curriculo, emprego_atual, data_inicio DESC
- **Condição:** WHERE emprego_atual = true
- **Justificativa:** Otimiza busca de emprego atual dos candidatos
- **Consultas beneficiadas:** Perfil de candidato, análise de experiência atual

#### `idx_experiencias_periodo`
- **Tipo:** Índice composto B-tree
- **Campos:** data_inicio DESC, data_fim DESC NULLS FIRST
- **Justificativa:** Facilita análises temporais de experiência profissional
- **Consultas beneficiadas:** Cálculo de tempo de experiência, análise de carreira

#### `idx_formacoes_grau_conclusao`
- **Tipo:** Índice composto B-tree
- **Campos:** grau, data_conclusao DESC NULLS FIRST
- **Justificativa:** Otimiza busca por nível educacional e conclusão
- **Consultas beneficiadas:** Filtros por formação, análise educacional

### 7. Índices para Comunicação (5 índices)

#### `idx_mensagens_destinatario_lida`
- **Tipo:** Índice composto B-tree
- **Campos:** id_destinatario, lida, data_envio DESC
- **Justificativa:** Otimiza caixa de entrada e contagem de mensagens não lidas
- **Consultas beneficiadas:** Sistema de mensagens, notificações

#### `idx_mensagens_remetente_data`
- **Tipo:** Índice composto B-tree
- **Campos:** id_remetente, data_envio DESC
- **Justificativa:** Otimiza consulta de mensagens enviadas
- **Consultas beneficiadas:** Histórico de mensagens enviadas

#### `idx_conexoes_solicitante_status`
- **Tipo:** Índice composto B-tree
- **Campos:** id_solicitante, status_conexao, data_conexao DESC
- **Justificativa:** Facilita gestão de conexões enviadas pelo usuário
- **Consultas beneficiadas:** Rede de contatos, solicitações enviadas

#### `idx_conexoes_receptor_status`
- **Tipo:** Índice composto B-tree
- **Campos:** id_receptor, status_conexao, data_conexao DESC
- **Justificativa:** Otimiza consulta de conexões recebidas
- **Consultas beneficiadas:** Solicitações de conexão pendentes

#### `idx_conexoes_ativas_data`
- **Tipo:** Índice parcial B-tree
- **Campos:** status_conexao, data_conexao DESC
- **Condição:** WHERE status_conexao = 'aceita'
- **Justificativa:** Facilita análises de networking e crescimento da rede
- **Consultas beneficiadas:** Estatísticas de networking, análise de conectividade

## Impacto Esperado nas Consultas

### Consultas Principais Otimizadas:

1. **Busca de Vagas Abertas (Query #1)**
   - **Antes:** Scan completo da tabela vagas
   - **Depois:** Acesso direto via `idx_vagas_abertas_ativas`
   - **Melhoria esperada:** 90%+ de redução no tempo

2. **Matching Candidato-Vaga (Stored Procedure)**
   - **Antes:** Joins caros entre tabelas de habilidades
   - **Depois:** Uso eficiente de `idx_candidatos_habilidades_nivel` e `idx_vagas_habilidades_obrigatoria`
   - **Melhoria esperada:** 70%+ de redução no tempo

3. **Dashboard do Candidato**
   - **Antes:** Scan por todas as candidaturas
   - **Depois:** Acesso direto via `idx_candidaturas_candidato_status`
   - **Melhoria esperada:** 85%+ de redução no tempo

4. **Dashboard da Empresa**
   - **Antes:** Múltiplos scans e joins
   - **Depois:** Uso de `idx_vagas_empresa_status` e `idx_candidaturas_vaga_status`
   - **Melhoria esperada:** 80%+ de redução no tempo

5. **Análises Salariais (Query #3)**
   - **Antes:** Scan completo com filtros caros
   - **Depois:** Uso de `idx_vagas_salario_nivel`
   - **Melhoria esperada:** 75%+ de redução no tempo

## Monitoramento e Manutenção

### Comandos para Monitoramento:

```sql
-- Verificar uso dos índices
SELECT * FROM analisar_uso_indices();

-- Verificar tamanho dos índices
SELECT * FROM vw_documentacao_indices;

-- Testar performance
SELECT * FROM testar_performance_consultas();
```

### Manutenção Recomendada:

1. **Diária:** Verificar estatísticas de uso
2. **Semanal:** Análise de performance das consultas principais
3. **Mensal:** Reindexação com `SELECT reindexar_sistema();`
4. **Trimestral:** Revisão de índices não utilizados

## Considerações de Performance

### Benefícios:
- **Consultas 70-90% mais rápidas** nas operações principais
- **Redução de uso de CPU** em consultas complexas
- **Melhoria na experiência do usuário** com respostas mais rápidas
- **Escalabilidade** - performance mantida com crescimento dos dados

### Custos:
- **Espaço adicional:** ~20-30% do tamanho das tabelas
- **Overhead de escrita:** 5-10% mais lento em INSERTs/UPDATEs
- **Manutenção:** Necessidade de monitoramento regular

### ROI (Retorno sobre Investimento):
- **Alto** - Os benefícios em performance superam significativamente os custos
- **Escalabilidade** - Essencial para o crescimento do sistema
- **Experiência do usuário** - Fundamental para adoção e retenção

## Índices Críticos vs Opcionais

### **CRÍTICOS (Nunca remover):**
- `idx_vagas_abertas_ativas` - Busca principal de vagas
- `idx_candidaturas_candidato_status` - Dashboard candidato
- `idx_candidaturas_vaga_status` - Dashboard empresa
- `idx_candidatos_habilidades_nivel` - Matching
- `idx_candidaturas_unica` - Integridade

### **IMPORTANTES:**
- `idx_usuarios_email_ativo` - Login
- `idx_vagas_empresa_status` - Dashboard empresa
- `idx_processos_candidatura_status` - Acompanhamento

### **OPCIONAIS (Monitorar uso):**
- `idx_conexoes_ativas_data` - Analytics
- `idx_historico_*` - Auditoria
- `idx_formacoes_grau_conclusao` - Relatórios

## Conclusão

O sistema de índices implementado foi cuidadosamente projetado para otimizar as consultas mais críticas do sistema de recrutamento. Com foco especial nas operações de busca de vagas, matching de candidatos e dashboards, esperamos uma melhoria significativa na performance geral do sistema.

A manutenção regular e monitoramento contínuo garantirão que os índices continuem proporcionando os benefícios esperados conforme o sistema cresce e evolui.
