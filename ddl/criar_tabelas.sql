CREATE TABLE tipos (
    id_tipo SERIAL PRIMARY KEY,
    nome_tipo VARCHAR(20) NOT NULL UNIQUE
);
CREATE TABLE especie (
    n_pokedex INT PRIMARY KEY CHECK (n_pokedex BETWEEN 1 AND 1025),
    name VARCHAR(50) NOT NULL,
    type1 INT NOT NULL REFERENCES tipos(id_tipo),
    type2 INT REFERENCES tipos(id_tipo),
    base_hp INT NOT NULL,
    base_attck INT NOT NULL,
    base_def INT NOT NULL,
    base_spa INT NOT NULL,
    base_spd INT NOT NULL,
    base_spe INT NOT NULL
);
CREATE TABLE pokedex (
    id_pokemon SERIAL PRIMARY KEY,
    n_pokedex INT NOT NULL REFERENCES especie(n_pokedex),
    iv_hp INT NOT NULL CHECK (iv_hp BETWEEN 0 AND 31),
    iv_attck INT NOT NULL CHECK (iv_attck BETWEEN 0 AND 31),
    iv_def INT NOT NULL CHECK (iv_def BETWEEN 0 AND 31),
    iv_spa INT NOT NULL CHECK (iv_spa BETWEEN 0 AND 31),
    iv_spd INT NOT NULL CHECK (iv_spd BETWEEN 0 AND 31),
    iv_spe INT NOT NULL CHECK (iv_spe BETWEEN 0 AND 31),
    ivs_totais INT NOT NULL CHECK (ivs_totais BETWEEN 0 AND 186),
    ev_hp INT NOT NULL CHECK (ev_hp BETWEEN 0 AND 252),
    ev_attck INT NOT NULL CHECK (ev_attck BETWEEN 0 AND 252),
    ev_def INT NOT NULL CHECK (ev_def BETWEEN 0 AND 252),
    ev_spa INT NOT NULL CHECK (ev_spa BETWEEN 0 AND 252),
    ev_spd INT NOT NULL CHECK (ev_spd BETWEEN 0 AND 252),
    ev_spe INT NOT NULL CHECK (ev_spe BETWEEN 0 AND 252),
    evs_totais INT NOT NULL CHECK (evs_totais BETWEEN 0 AND 510),
    shiny BOOLEAN NOT NULL DEFAULT FALSE,
    pokerus BOOLEAN NOT NULL DEFAULT FALSE,
    gender VARCHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'U'))
);