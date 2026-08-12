--
-- PostgreSQL database dump
--

\restrict qycKvUafw8rj8FIdd3qrwnQTL7jFLgLhW0PkgJUiLapOMSc0J159csD8714cNzf

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: especie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especie (
    n_pokedex integer NOT NULL,
    name character varying(50) NOT NULL,
    type1 integer NOT NULL,
    type2 integer,
    base_hp integer NOT NULL,
    base_attck integer NOT NULL,
    base_def integer NOT NULL,
    base_spa integer NOT NULL,
    base_spd integer NOT NULL,
    base_spe integer NOT NULL,
    CONSTRAINT especie_n_pokedex_check CHECK (((n_pokedex >= 1) AND (n_pokedex <= 1025)))
);


ALTER TABLE public.especie OWNER TO postgres;

--
-- Name: pokedex; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pokedex (
    id_pokemon integer NOT NULL,
    name character varying(50) NOT NULL,
    n_pokedex integer NOT NULL,
    evs_totais integer NOT NULL,
    ivs_totais integer NOT NULL,
    base_hp integer NOT NULL,
    base_attck integer NOT NULL,
    base_def integer NOT NULL,
    base_spa integer NOT NULL,
    base_spd integer NOT NULL,
    base_spe integer NOT NULL,
    shiny boolean NOT NULL,
    pokerus boolean NOT NULL,
    gender character varying(1) NOT NULL,
    CONSTRAINT chk_evs CHECK (((evs_totais >= 0) AND (evs_totais <= 512))),
    CONSTRAINT chk_gender CHECK (((gender)::text = ANY ((ARRAY['M'::character varying, 'F'::character varying, 'U'::character varying])::text[]))),
    CONSTRAINT chk_ivs CHECK (((ivs_totais >= 0) AND (ivs_totais <= 186))),
    CONSTRAINT chk_pokedex CHECK (((n_pokedex >= 1) AND (n_pokedex <= 1025)))
);


ALTER TABLE public.pokedex OWNER TO postgres;

--
-- Name: pokedex_id_pokemon_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pokedex_id_pokemon_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pokedex_id_pokemon_seq OWNER TO postgres;

--
-- Name: pokedex_id_pokemon_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pokedex_id_pokemon_seq OWNED BY public.pokedex.id_pokemon;


--
-- Name: tipos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos (
    id_tipo integer NOT NULL,
    tipo character varying(20) NOT NULL
);


ALTER TABLE public.tipos OWNER TO postgres;

--
-- Name: tipos_id_tipo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tipos_id_tipo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipos_id_tipo_seq OWNER TO postgres;

--
-- Name: tipos_id_tipo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tipos_id_tipo_seq OWNED BY public.tipos.id_tipo;


--
-- Name: pokedex id_pokemon; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex ALTER COLUMN id_pokemon SET DEFAULT nextval('public.pokedex_id_pokemon_seq'::regclass);


--
-- Name: tipos id_tipo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos ALTER COLUMN id_tipo SET DEFAULT nextval('public.tipos_id_tipo_seq'::regclass);


--
-- Data for Name: especie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.especie (n_pokedex, name, type1, type2, base_hp, base_attck, base_def, base_spa, base_spd, base_spe) FROM stdin;
\.


--
-- Data for Name: pokedex; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pokedex (id_pokemon, name, n_pokedex, evs_totais, ivs_totais, base_hp, base_attck, base_def, base_spa, base_spd, base_spe, shiny, pokerus, gender) FROM stdin;
\.


--
-- Data for Name: tipos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipos (id_tipo, tipo) FROM stdin;
1	Normal
2	Fogo
3	Água
4	Elétrico
5	Planta
6	Gelo
7	Lutador
8	Venenoso
9	Terra
10	Voador
11	Psíquico
12	Inseto
13	Pedra
14	Fantasma
15	Dragão
16	Sombrio
17	Aço
18	Fada
\.


--
-- Name: pokedex_id_pokemon_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pokedex_id_pokemon_seq', 1, false);


--
-- Name: tipos_id_tipo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tipos_id_tipo_seq', 36, true);


--
-- Name: especie especie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especie
    ADD CONSTRAINT especie_pkey PRIMARY KEY (n_pokedex);


--
-- Name: pokedex pokedex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pokedex
    ADD CONSTRAINT pokedex_pkey PRIMARY KEY (id_pokemon);


--
-- Name: tipos tipos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos
    ADD CONSTRAINT tipos_pkey PRIMARY KEY (id_tipo);


--
-- Name: tipos tipos_tipo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos
    ADD CONSTRAINT tipos_tipo_key UNIQUE (tipo);


--
-- Name: especie especie_type1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especie
    ADD CONSTRAINT especie_type1_fkey FOREIGN KEY (type1) REFERENCES public.tipos(id_tipo);


--
-- Name: especie especie_type2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especie
    ADD CONSTRAINT especie_type2_fkey FOREIGN KEY (type2) REFERENCES public.tipos(id_tipo);


--
-- PostgreSQL database dump complete
--

\unrestrict qycKvUafw8rj8FIdd3qrwnQTL7jFLgLhW0PkgJUiLapOMSc0J159csD8714cNzf

