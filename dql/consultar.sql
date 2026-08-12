SELECT * FROM tipos;
SELECT
    e.n_pokedex,
    e.name,
    t1.nome_tipo AS tipo_1,
    t2.nome_tipo AS tipo_2,
    e.base_hp, e.base_attck, e.base_def, e.base_spa, e.base_spd, e.base_spe
FROM especie e
JOIN tipos t1 ON e.type1 = t1.id_tipo
LEFT JOIN tipos t2 ON e.type2 = t2.id_tipo;
SELECT
    p.id_pokemon,
    e.name,
    p.ivs_totais,
    p.evs_totais,
    p.shiny,
    p.pokerus,
    p.gender
FROM pokedex p
JOIN especie e ON p.n_pokedex = e.n_pokedex;
SELECT e.name, p.id_pokemon, p.gender
FROM pokedex p
JOIN especie e ON p.n_pokedex = e.n_pokedex
WHERE p.shiny = TRUE;