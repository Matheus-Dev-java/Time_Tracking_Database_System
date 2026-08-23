# Time Tracking Database System (Sistema de Ponto Eletrônico)


## Descrição do Projeto
Este projeto consiste no desenvolvimento de um banco de dados relacional para o gerenciamento de controle de jornada e ponto eletrônico corporativo (REP-P), armazenando informações sobre organizações empregadoras, colaboradores, escalas de trabalho flexíveis e fixas, registros imutáveis de marcações de ponto (com dados de geolocalização e biometria) e fechamentos mensais de espelhos de ponto com assinaturas digitais. O projeto é desenvolvido com foco nas diretrizes da legislação trabalhista brasileira (CLT e Portaria 671/2021 do MTP), evoluindo em complexidade e integridade a cada etapa.



## Objetivo da Solução
Modelar e implementar um banco de dados normalizado e resiliente que represente de forma consistente as relações entre empregadores, jornadas e apurações de horas trabalhadas, aplicando conceitos de chaves primárias descritivas, chaves estrangeiras com integridade referencial estrita, restrições de integridade de domínio (`constraints`), adoção das normas internacionais de nomenclatura de banco de dados (*Ovid Database Naming Standards*) e organização modular de scripts SQL por categoria (DDL, DML e DQL).
