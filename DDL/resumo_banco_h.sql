-- Verificação diária
CREATE TABLE resumo_diario (
    id INT PRIMARY KEY,
    date DATE NOT NULL,
    minutos_trabalhados INT NOT NULL,
    minutos_regulares INT NOT NULL,
    minutos_extra_50 INT NOT NULL,
    minutos_extra_100 INT NOT NULL,
    minutos_turno_noturno INT NOT NULL,
    minutos_atraso INT NOT NULL,
    minutos_saldo INT NOT NULL
);

-- Banco de Horas
CREATE TABLE banco_de_horas (
    id INT PRIMARY KEY,
    minutos_saldo INT NOT NULL,
    data_expiracao DATE
);