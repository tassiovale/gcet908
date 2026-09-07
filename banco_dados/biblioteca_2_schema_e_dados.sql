-- Extensão útil para buscas por trecho de texto (ILIKE '%...%') com índice.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ---------------------------------------------------------------------
-- generos
-- ---------------------------------------------------------------------
CREATE TABLE generos (
  id         SERIAL PRIMARY KEY,
  nome       VARCHAR(60) NOT NULL UNIQUE,
  descricao  TEXT
);

COMMENT ON TABLE generos IS 'Categorias/gêneros literários dos livros.';

-- ---------------------------------------------------------------------
-- autores
-- ---------------------------------------------------------------------
CREATE TABLE autores (
  id             SERIAL PRIMARY KEY,
  nome           VARCHAR(120) NOT NULL,
  ano_nascimento INTEGER CHECK (ano_nascimento IS NULL OR ano_nascimento BETWEEN 1000 AND EXTRACT(YEAR FROM CURRENT_DATE)),
  ano_falecimento INTEGER CHECK (ano_falecimento IS NULL OR ano_nascimento IS NULL OR ano_falecimento >= ano_nascimento),
  nacionalidade  VARCHAR(60),
  UNIQUE (nome, ano_nascimento)
);

COMMENT ON TABLE autores IS 'Autores dos livros (relação N:N com livros via livros_autores).';

-- ---------------------------------------------------------------------
-- livros
-- ---------------------------------------------------------------------
CREATE TABLE livros (
  id             SERIAL PRIMARY KEY,
  titulo         VARCHAR(200) NOT NULL,
  isbn           VARCHAR(20) UNIQUE,
  ano            INTEGER CHECK (ano IS NULL OR ano BETWEEN 1000 AND EXTRACT(YEAR FROM CURRENT_DATE) + 1),
  editora        VARCHAR(120),
  idioma         VARCHAR(40) NOT NULL DEFAULT 'Português',
  num_paginas    INTEGER CHECK (num_paginas IS NULL OR num_paginas > 0),
  exemplares     INTEGER NOT NULL DEFAULT 1 CHECK (exemplares >= 0),
  genero_id      INTEGER REFERENCES generos(id) ON DELETE SET NULL,
  criado_em      TIMESTAMP NOT NULL DEFAULT NOW(),
  atualizado_em  TIMESTAMP NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE livros IS 'Acervo de livros da biblioteca.';
COMMENT ON COLUMN livros.exemplares IS 'Quantidade total de cópias físicas do título (disponíveis ou não).';

-- Mantém atualizado_em sempre em dia a cada UPDATE
CREATE OR REPLACE FUNCTION trg_set_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER livros_set_atualizado_em
  BEFORE UPDATE ON livros
  FOR EACH ROW
  EXECUTE FUNCTION trg_set_atualizado_em();

-- ---------------------------------------------------------------------
-- livros_autores (tabela de junção N:N)
-- ---------------------------------------------------------------------
CREATE TABLE livros_autores (
  livro_id INTEGER NOT NULL REFERENCES livros(id) ON DELETE CASCADE,
  autor_id INTEGER NOT NULL REFERENCES autores(id) ON DELETE CASCADE,
  PRIMARY KEY (livro_id, autor_id)
);

COMMENT ON TABLE livros_autores IS 'Relação N:N entre livros e autores (um livro pode ter vários autores e vice-versa).';

-- ---------------------------------------------------------------------
-- estudantes
-- ---------------------------------------------------------------------
CREATE TABLE estudantes (
  id             SERIAL PRIMARY KEY,
  nome           VARCHAR(120) NOT NULL,
  matricula      VARCHAR(20) NOT NULL UNIQUE,
  email          VARCHAR(160) UNIQUE CHECK (email IS NULL OR email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  curso          VARCHAR(120),
  data_matricula DATE NOT NULL DEFAULT CURRENT_DATE,
  ativo          BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE estudantes IS 'Estudantes cadastrados que podem retirar livros emprestados.';

-- ---------------------------------------------------------------------
-- emprestimos
-- ---------------------------------------------------------------------
CREATE TABLE emprestimos (
  id             SERIAL PRIMARY KEY,
  livro_id       INTEGER NOT NULL REFERENCES livros(id),
  estudante_id   INTEGER NOT NULL REFERENCES estudantes(id),
  data_retirada  DATE NOT NULL DEFAULT CURRENT_DATE,
  data_prevista  DATE NOT NULL,
  data_devolucao DATE,
  renovacoes     INTEGER NOT NULL DEFAULT 0 CHECK (renovacoes >= 0),
  status         VARCHAR(15) NOT NULL DEFAULT 'ativo'
                 CHECK (status IN ('ativo', 'devolvido', 'atrasado', 'perdido')),
  CHECK (data_prevista >= data_retirada),
  CHECK (data_devolucao IS NULL OR data_devolucao >= data_retirada)
);

COMMENT ON TABLE emprestimos IS 'Histórico e controle de empréstimos de livros para estudantes.';

-- ---------------------------------------------------------------------
-- Índices adicionais (chaves estrangeiras não ganham índice automático
-- no Postgres, e buscas por texto se beneficiam de índices trigram)
-- ---------------------------------------------------------------------
CREATE INDEX idx_livros_genero_id        ON livros (genero_id);
CREATE INDEX idx_livros_titulo_trgm      ON livros USING gin (titulo gin_trgm_ops);
CREATE INDEX idx_autores_nome_trgm       ON autores USING gin (nome gin_trgm_ops);
CREATE INDEX idx_livros_autores_autor_id ON livros_autores (autor_id);
CREATE INDEX idx_emprestimos_livro_id     ON emprestimos (livro_id);
CREATE INDEX idx_emprestimos_estudante_id ON emprestimos (estudante_id);
CREATE INDEX idx_emprestimos_status       ON emprestimos (status);
CREATE INDEX idx_emprestimos_pendentes    ON emprestimos (data_prevista) WHERE data_devolucao IS NULL;

-- ---------------------------------------------------------------------
-- View de conveniência: disponibilidade de exemplares por livro
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_disponibilidade_livros AS
SELECT
  l.id,
  l.titulo,
  l.exemplares,
  COUNT(e.id) FILTER (WHERE e.data_devolucao IS NULL)          AS emprestados_no_momento,
  l.exemplares - COUNT(e.id) FILTER (WHERE e.data_devolucao IS NULL) AS exemplares_disponiveis
FROM livros l
LEFT JOIN emprestimos e ON e.livro_id = l.id
GROUP BY l.id, l.titulo, l.exemplares;

COMMENT ON VIEW vw_disponibilidade_livros IS 'Quantos exemplares de cada livro estão disponíveis agora (total - emprestados sem devolução).';


-- =====================================================================
-- SEÇÃO 2 — DADOS: GÊNEROS
-- =====================================================================
INSERT INTO generos (nome, descricao) VALUES
  ('Romance',              'Narrativas de ficção centradas em relações e conflitos pessoais.'),
  ('Ficção Científica',    'Histórias baseadas em avanços científicos e tecnológicos especulativos.'),
  ('Fantasia',             'Narrativas com elementos mágicos ou sobrenaturais em mundos imaginários.'),
  ('Conto',                'Narrativas curtas de ficção.'),
  ('Poesia',               'Obras em verso.'),
  ('Terror',               'Narrativas voltadas a provocar medo ou apreensão.'),
  ('Suspense',             'Narrativas com tensão crescente e mistério.'),
  ('Literatura Brasileira','Obras clássicas e modernas de autores brasileiros.'),
  ('Não-ficção',           'Obras baseadas em fatos reais.'),
  ('Distopia',             'Ficção que retrata sociedades futuras opressivas ou disfuncionais.'),
  ('Infantojuvenil',       'Obras voltadas para crianças e adolescentes.'),
  ('Realismo Mágico',      'Ficção que mistura elementos realistas e fantásticos com naturalidade.'),
  ('História',             'Obras sobre eventos e períodos históricos.');

-- =====================================================================
-- SEÇÃO 3 — DADOS: AUTORES
-- =====================================================================
INSERT INTO autores (nome, ano_nascimento, ano_falecimento, nacionalidade) VALUES
  ('Machado de Assis',        1839, 1908, 'Brasileira'),
  ('Clarice Lispector',       1920, 1977, 'Brasileira'),
  ('Jorge Amado',             1912, 2001, 'Brasileira'),
  ('João Guimarães Rosa',     1908, 1967, 'Brasileira'),
  ('Graciliano Ramos',        1892, 1953, 'Brasileira'),
  ('José de Alencar',         1829, 1877, 'Brasileira'),
  ('Aluísio Azevedo',         1857, 1913, 'Brasileira'),
  ('Cecília Meireles',        1901, 1964, 'Brasileira'),
  ('Carlos Drummond de Andrade', 1902, 1987, 'Brasileira'),
  ('Rachel de Queiroz',       1910, 2003, 'Brasileira'),
  ('Paulo Coelho',            1947, NULL, 'Brasileira'),
  ('J.K. Rowling',            1965, NULL, 'Britânica'),
  ('George Orwell',           1903, 1950, 'Britânica'),
  ('J.R.R. Tolkien',          1892, 1973, 'Britânica'),
  ('Gabriel García Márquez',  1927, 2014, 'Colombiana'),
  ('Agatha Christie',         1890, 1976, 'Britânica'),
  ('Isaac Asimov',            1920, 1992, 'Estadunidense'),
  ('Jane Austen',             1775, 1817, 'Britânica'),
  ('Stephen King',            1947, NULL, 'Estadunidense'),
  ('Suzanne Collins',         1962, NULL, 'Estadunidense'),
  ('Yuval Noah Harari',       1976, NULL, 'Israelense'),
  ('Franz Kafka',             1883, 1924, 'Tcheca'),
  ('Ray Bradbury',            1920, 2012, 'Estadunidense'),
  ('William Gibson',          1948, NULL, 'Canadense'),
  ('Frank Herbert',           1920, 1986, 'Estadunidense'),
  ('Aldous Huxley',           1894, 1963, 'Britânica'),
  ('Terry Pratchett',         1948, 2015, 'Britânica'),
  ('Neil Gaiman',             1960, NULL, 'Britânica');

-- =====================================================================
-- SEÇÃO 4 — DADOS: LIVROS
-- (usamos subselects em generos para não depender dos IDs gerados)
-- =====================================================================
INSERT INTO livros (titulo, isbn, ano, editora, idioma, num_paginas, exemplares, genero_id) VALUES
  ('Dom Casmurro',                          '9788508058859', 1899, 'Ática',          'Português', 256, 4,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Memórias Póstumas de Brás Cubas',       '9788508058866', 1881, 'Ática',          'Português', 208, 3,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Quincas Borba',                         '9788572327443', 1891, 'Martin Claret',  'Português', 264, 2,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('A Hora da Estrela',                     '9788532507739', 1977, 'Rocco',          'Português', 96,  3,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Capitães da Areia',                     '9788535914856', 1937, 'Companhia das Letras', 'Português', 280, 4,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Grande Sertão: Veredas',                '9788535910636', 1956, 'Nova Fronteira', 'Português', 624, 2,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Vidas Secas',                           '9788526012647', 1938, 'Record',         'Português', 176, 3,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Iracema',                               '9788572327351', 1865, 'Martin Claret',  'Português', 120, 2,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('O Cortiço',                             '9788572327047', 1890, 'Martin Claret',  'Português', 288, 2,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('Antologia Poética',                     '9788503009073', 1963, 'Global',         'Português', 320, 2,
    (SELECT id FROM generos WHERE nome = 'Poesia')),
  ('A Rosa do Povo',                        '9788535911732', 1945, 'Companhia das Letras', 'Português', 200, 2,
    (SELECT id FROM generos WHERE nome = 'Poesia')),
  ('O Quinze',                              '9788520925890', 1930, 'José Olympio',   'Português', 176, 2,
    (SELECT id FROM generos WHERE nome = 'Literatura Brasileira')),
  ('O Alquimista',                          '9788576653836', 1988, 'Paralela',       'Português', 208, 5,
    (SELECT id FROM generos WHERE nome = 'Ficção Científica')),
  ('Harry Potter e a Pedra Filosofal',      '9788532511010', 1997, 'Rocco',          'Português', 264, 6,
    (SELECT id FROM generos WHERE nome = 'Fantasia')),
  ('1984',                                  '9788535914849', 1949, 'Companhia das Letras', 'Português', 416, 5,
    (SELECT id FROM generos WHERE nome = 'Distopia')),
  ('O Senhor dos Anéis: A Sociedade do Anel','9788595084759', 1954, 'HarperCollins', 'Português', 576, 3,
    (SELECT id FROM generos WHERE nome = 'Fantasia')),
  ('O Hobbit',                              '9788595084308', 1937, 'HarperCollins',  'Português', 336, 4,
    (SELECT id FROM generos WHERE nome = 'Fantasia')),
  ('Cem Anos de Solidão',                   '9788501063279', 1967, 'Record',         'Português', 448, 3,
    (SELECT id FROM generos WHERE nome = 'Realismo Mágico')),
  ('Assassinato no Expresso Oriente',       '9788525056560', 1934, 'HarperCollins',  'Português', 256, 3,
    (SELECT id FROM generos WHERE nome = 'Suspense')),
  ('Eu, Robô',                              '9788576573462', 1950, 'Aleph',          'Português', 272, 3,
    (SELECT id FROM generos WHERE nome = 'Ficção Científica')),
  ('Orgulho e Preconceito',                 '9788544001820', 1813, 'Martin Claret',  'Português', 392, 3,
    (SELECT id FROM generos WHERE nome = 'Romance')),
  ('It: A Coisa',                           '9788581050609', 1986, 'Suma',           'Português', 1104, 2,
    (SELECT id FROM generos WHERE nome = 'Terror')),
  ('Jogos Vorazes',                         '9788598078279', 2008, 'Rocco',          'Português', 336, 4,
    (SELECT id FROM generos WHERE nome = 'Distopia')),
  ('Sapiens: Uma Breve História da Humanidade', '9788525432815', 2011, 'L&PM',        'Português', 464, 3,
    (SELECT id FROM generos WHERE nome = 'Não-ficção')),
  ('A Metamorfose',                         '9788525410216', 1915, 'L&PM',          'Português', 96,  4,
    (SELECT id FROM generos WHERE nome = 'Ficção Científica')),
  ('Fahrenheit 451',                        '9788576573240', 1953, 'Globo',         'Português', 176, 3,
    (SELECT id FROM generos WHERE nome = 'Distopia')),
  ('Neuromancer',                           '9788576571161', 1984, 'Aleph',         'Português', 344, 2,
    (SELECT id FROM generos WHERE nome = 'Ficção Científica')),
  ('Duna',                                  '9788576572861', 1965, 'Aleph',         'Português', 656, 3,
    (SELECT id FROM generos WHERE nome = 'Ficção Científica')),
  ('Admirável Mundo Novo',                  '9788525056584', 1932, 'Globo',         'Português', 312, 3,
    (SELECT id FROM generos WHERE nome = 'Distopia')),
  ('Belas Maldições',                       '9788565530276', 1990, 'Intrínseca',    'Português', 416, 2,
    (SELECT id FROM generos WHERE nome = 'Fantasia'));

-- =====================================================================
-- SEÇÃO 5 — DADOS: LIVROS_AUTORES
-- =====================================================================
INSERT INTO livros_autores (livro_id, autor_id)
SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Dom Casmurro' AND a.nome = 'Machado de Assis'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Memórias Póstumas de Brás Cubas' AND a.nome = 'Machado de Assis'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Quincas Borba' AND a.nome = 'Machado de Assis'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'A Hora da Estrela' AND a.nome = 'Clarice Lispector'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Capitães da Areia' AND a.nome = 'Jorge Amado'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Grande Sertão: Veredas' AND a.nome = 'João Guimarães Rosa'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Vidas Secas' AND a.nome = 'Graciliano Ramos'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Iracema' AND a.nome = 'José de Alencar'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'O Cortiço' AND a.nome = 'Aluísio Azevedo'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Antologia Poética' AND a.nome = 'Cecília Meireles'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'A Rosa do Povo' AND a.nome = 'Carlos Drummond de Andrade'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'O Quinze' AND a.nome = 'Rachel de Queiroz'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'O Alquimista' AND a.nome = 'Paulo Coelho'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Harry Potter e a Pedra Filosofal' AND a.nome = 'J.K. Rowling'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = '1984' AND a.nome = 'George Orwell'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'O Senhor dos Anéis: A Sociedade do Anel' AND a.nome = 'J.R.R. Tolkien'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'O Hobbit' AND a.nome = 'J.R.R. Tolkien'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Cem Anos de Solidão' AND a.nome = 'Gabriel García Márquez'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Assassinato no Expresso Oriente' AND a.nome = 'Agatha Christie'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Eu, Robô' AND a.nome = 'Isaac Asimov'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Orgulho e Preconceito' AND a.nome = 'Jane Austen'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'It: A Coisa' AND a.nome = 'Stephen King'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Jogos Vorazes' AND a.nome = 'Suzanne Collins'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Sapiens: Uma Breve História da Humanidade' AND a.nome = 'Yuval Noah Harari'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'A Metamorfose' AND a.nome = 'Franz Kafka'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Fahrenheit 451' AND a.nome = 'Ray Bradbury'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Neuromancer' AND a.nome = 'William Gibson'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Duna' AND a.nome = 'Frank Herbert'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Admirável Mundo Novo' AND a.nome = 'Aldous Huxley'
-- Exemplo de livro com DOIS autores (demonstra o N:N)
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Belas Maldições' AND a.nome = 'Terry Pratchett'
UNION ALL SELECT l.id, a.id FROM livros l, autores a WHERE l.titulo = 'Belas Maldições' AND a.nome = 'Neil Gaiman';

-- =====================================================================
-- SEÇÃO 6 — DADOS: ESTUDANTES
-- =====================================================================
INSERT INTO estudantes (nome, matricula, email, curso, data_matricula, ativo) VALUES
  ('Ana Beatriz Souza',     '2023001', 'ana.souza@estudante.edu.br',      'Licenciatura em Computação', '2023-02-10', TRUE),
  ('Bruno Carvalho Lima',   '2023002', 'bruno.lima@estudante.edu.br',     'Engenharia de Software',     '2023-02-10', TRUE),
  ('Carla Meneses',         '2023003', 'carla.meneses@estudante.edu.br',  'Licenciatura em Computação', '2023-02-10', TRUE),
  ('Diego Ferreira Santos', '2023004', 'diego.santos@estudante.edu.br',   'Sistemas de Informação',     '2023-02-10', TRUE),
  ('Elisa Ramos Oliveira',  '2023005', 'elisa.oliveira@estudante.edu.br', 'Licenciatura em Computação', '2023-02-10', FALSE),
  ('Felipe Andrade Costa',  '2024001', 'felipe.costa@estudante.edu.br',   'Ciência da Computação',      '2024-02-05', TRUE),
  ('Gabriela Nunes',        '2024002', 'gabriela.nunes@estudante.edu.br', 'Engenharia de Software',     '2024-02-05', TRUE),
  ('Henrique Pires',        '2024003', 'henrique.pires@estudante.edu.br', 'Sistemas de Informação',     '2024-02-05', TRUE),
  ('Isabela Cardoso',       '2024004', 'isabela.cardoso@estudante.edu.br','Licenciatura em Computação', '2024-02-05', TRUE),
  ('João Vitor Almeida',    '2024005', 'joao.almeida@estudante.edu.br',   'Ciência da Computação',      '2024-02-05', TRUE),
  ('Karina Batista',        '2025001', 'karina.batista@estudante.edu.br', 'Engenharia de Software',     '2025-02-03', TRUE),
  ('Lucas Teixeira',        '2025002', 'lucas.teixeira@estudante.edu.br', 'Licenciatura em Computação', '2025-02-03', TRUE),
  ('Mariana Cunha',         '2025003', 'mariana.cunha@estudante.edu.br',  'Sistemas de Informação',     '2025-02-03', TRUE),
  ('Nicolas Barros',        '2025004', 'nicolas.barros@estudante.edu.br', 'Ciência da Computação',      '2025-02-03', TRUE),
  ('Olivia Freitas',        '2025005', 'olivia.freitas@estudante.edu.br', 'Licenciatura em Computação', '2025-02-03', TRUE),
  ('Pedro Henrique Rocha',  '2026001', 'pedro.rocha@estudante.edu.br',    'Engenharia de Software',     '2026-02-02', TRUE);

-- =====================================================================
-- SEÇÃO 7 — DADOS: EMPRÉSTIMOS
-- (mistura de devolvidos, ativos em dia e atrasados, usando datas
--  relativas a CURRENT_DATE para o script continuar realista com o tempo)
-- =====================================================================
INSERT INTO emprestimos (livro_id, estudante_id, data_retirada, data_prevista, data_devolucao, renovacoes, status)
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '40 days', CURRENT_DATE - INTERVAL '26 days', CURRENT_DATE - INTERVAL '28 days', 0, 'devolvido'
FROM livros l, estudantes e WHERE l.titulo = 'Dom Casmurro' AND e.matricula = '2023001'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '35 days', CURRENT_DATE - INTERVAL '21 days', CURRENT_DATE - INTERVAL '20 days', 1, 'devolvido'
FROM livros l, estudantes e WHERE l.titulo = 'Harry Potter e a Pedra Filosofal' AND e.matricula = '2023002'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE - INTERVAL '16 days', CURRENT_DATE - INTERVAL '18 days', 0, 'devolvido'
FROM livros l, estudantes e WHERE l.titulo = 'O Alquimista' AND e.matricula = '2023003'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '25 days', CURRENT_DATE - INTERVAL '11 days', CURRENT_DATE - INTERVAL '5 days', 0, 'devolvido'
FROM livros l, estudantes e WHERE l.titulo = '1984' AND e.matricula = '2024001'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '20 days', CURRENT_DATE - INTERVAL '6 days', NULL, 0, 'atrasado'
FROM livros l, estudantes e WHERE l.titulo = 'Cem Anos de Solidão' AND e.matricula = '2024002'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '18 days', CURRENT_DATE - INTERVAL '4 days', NULL, 1, 'atrasado'
FROM livros l, estudantes e WHERE l.titulo = 'It: A Coisa' AND e.matricula = '2024003'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '4 days', NULL, 0, 'ativo'
FROM livros l, estudantes e WHERE l.titulo = 'Jogos Vorazes' AND e.matricula = '2024004'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE + INTERVAL '7 days', NULL, 0, 'ativo'
FROM livros l, estudantes e WHERE l.titulo = 'Duna' AND e.matricula = '2024005'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '9 days', NULL, 0, 'ativo'
FROM livros l, estudantes e WHERE l.titulo = 'Sapiens: Uma Breve História da Humanidade' AND e.matricula = '2025001'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '3 days', CURRENT_DATE + INTERVAL '11 days', NULL, 0, 'ativo'
FROM livros l, estudantes e WHERE l.titulo = 'O Senhor dos Anéis: A Sociedade do Anel' AND e.matricula = '2025002'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '60 days', CURRENT_DATE - INTERVAL '46 days', CURRENT_DATE - INTERVAL '50 days', 0, 'devolvido'
FROM livros l, estudantes e WHERE l.titulo = 'Assassinato no Expresso Oriente' AND e.matricula = '2025003'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '12 days', NULL, 0, 'ativo'
FROM livros l, estudantes e WHERE l.titulo = 'Fahrenheit 451' AND e.matricula = '2025004'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '13 days', NULL, 0, 'ativo'
FROM livros l, estudantes e WHERE l.titulo = 'Eu, Robô' AND e.matricula = '2025005'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '55 days', CURRENT_DATE - INTERVAL '41 days', CURRENT_DATE - INTERVAL '39 days', 0, 'devolvido'
FROM livros l, estudantes e WHERE l.titulo = 'Grande Sertão: Veredas' AND e.matricula = '2026001'
UNION ALL
SELECT l.id, e.id, CURRENT_DATE - INTERVAL '12 days', CURRENT_DATE - INTERVAL '2 days', NULL, 0, 'atrasado'
FROM livros l, estudantes e WHERE l.titulo = 'Belas Maldições' AND e.matricula = '2023004';


-- =====================================================================
-- SEÇÃO 8 — VERIFICAÇÃO RÁPIDA (opcional; comente se não quiser rodar)
-- =====================================================================
-- SELECT * FROM vw_disponibilidade_livros ORDER BY titulo;
-- SELECT e.nome, l.titulo, em.data_prevista, em.status
--   FROM emprestimos em
--   JOIN estudantes e ON e.id = em.estudante_id
--   JOIN livros l ON l.id = em.livro_id
--   WHERE em.status IN ('ativo', 'atrasado')
--   ORDER BY em.data_prevista;
