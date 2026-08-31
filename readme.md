# Módulo de Ajustes de Ponto e Afastamentos - Documentação

Este documento descreve exclusivamente a estrutura das tabelas criadas para a gestão operacional de ajustes de ponto e afastamentos (atestados/licenças) do sistema.

## 📋 Tabelas do Módulo

### 1. Ajustes de Ponto (`ajustes_ponto`)
Responsável por armazenar as correções manuais solicitadas por colaboradores para marcações de ponto esquecidas ou incorretas.

* **`id`** (`BIGINT`, PK): Identificador único do registro de ajuste.
* **`data_hora_ajustada`** (`TIMESTAMP`): Data e horário exatos correspondentes à correção da batida de ponto.
* **`tipo_ajuste`** (`VARCHAR(50)`): Define a natureza da operação. Valores esperados:
  * `inclusão`: Adicionar uma batida que não foi registrada.
  * `desconsideração`: Anular uma batida incorreta.
* **`motivo`** (`TEXT`): Justificativa descritiva informada pelo colaborador ou gestor.
* **`status`** (`VARCHAR(50)`): Situação atual da solicitação. Valores esperados: `pendente`, `aprovado`, `reprovado`.

---

### 2. Afastamentos (`afastamentos`)
Registro de ausências justificadas, licenças médicas e afastamentos legais dos colaboradores.

* **`id`** (`BIGINT`, PK): Identificador único do registro de afastamento.
* **`data_inicio`** (`DATE`): Data de início do período de ausência.
* **`data_fim`** (`DATE`): Data de término do período de ausência.
* **`tipo_afastamento`** (`VARCHAR(100)`): Categoria do afastamento (ex: licença médica, licença maternidade, acidente de trabalho).
* **`codigo_cid`** (`VARCHAR(20)`): Código CID (Classificação Internacional de Doenças), opcional e aplicável a atestados médicos.
* **`url_documento`** (`VARCHAR(255)`): Caminho ou link digital para visualização do atestado/documento comprobatório.
* **`status`** (`VARCHAR(50)`): Situação de aprovação do atestado/afastamento. Valores
