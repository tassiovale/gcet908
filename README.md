# GCET908 - Desenvolvimento de Software II

Repositório com os exercícios práticos da disciplina GCET908, utilizando Node.js e Express para construção de servidores web e APIs REST.

## Requisitos

- [Node.js](https://nodejs.org/) (com npm)
- [PostgreSQL](https://www.postgresql.org/) (a partir do ex04)

## Exercícios

### ex01 - Servidor Express básico

Servidor HTTP simples com duas rotas de exemplo.

**Rotas:**
- `GET /` - retorna "Hello World!"
- `GET /tassio` - retorna "Olá Tassio!"

**Como executar:**
```bash
cd ex01
npm install
node app.js
```

O servidor sobe em `http://localhost:3000`.

### ex02 - API REST de Livros

API REST para gerenciamento de um catálogo de livros (CRUD), utilizando dados em memória.

**Rotas:**
- `GET /livros` - lista todos os livros
- `GET /livros/:id` - retorna um livro específico pelo id
- `POST /livros` - cadastra um novo livro (corpo em JSON)
- `DELETE /livros/:id` - remove um livro pelo id

**Como executar:**
```bash
cd ex02
npm install
node app.js
```

Para desenvolvimento com reinício automático (via `nodemon`):
```bash
npx nodemon app.js
```

O servidor sobe em `http://localhost:3000`.

**Exemplo de requisição (POST):**
```bash
curl -X POST http://localhost:3000/livros \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Dom Casmurro", "autor": "Machado de Assis", "ano": 1899}'
```

### ex03 - API de Livros em camadas com validação

Refatoração da API do ex02 separando responsabilidades em camadas (rotas, controllers e repositório), com validação dos dados de entrada via [Zod](https://zod.dev/). Utiliza módulos ES (`import`/`export`).

**Estrutura:**
```
ex03/
├── app.js                              # configuração do Express e registro das rotas
├── routes/livros.routes.js             # definição das rotas do recurso livros
├── controllers/livros.controller.js    # tratamento de requisição e resposta
├── data/livros.repository.js           # acesso aos dados (em memória)
├── middlewares/validacao.middleware.js # middleware genérico de validação
└── schemas/livro.schema.js             # schema de validação do livro (Zod)
```

**Rotas:**
- `GET /livros` - lista todos os livros
- `GET /livros/:id` - retorna um livro específico pelo id
- `POST /livros` - cadastra um novo livro (corpo em JSON, validado)
- `PUT /livros/:id` - atualiza um livro existente (corpo em JSON, validado)
- `DELETE /livros/:id` - remove um livro pelo id

**Validação:**

Os campos `titulo` (1 a 200 caracteres), `autor` (1 a 100 caracteres) e `ano` (entre 1000 e 2026) são obrigatórios nas rotas `POST` e `PUT`. Quando inválidos, a API responde `400` com a lista de erros:
```json
{
  "erros": [
    { "campo": "titulo", "mensagem": "O título é obrigatório" }
  ]
}
```

**Como executar:**
```bash
cd ex03
npm install
node app.js
```

Para desenvolvimento com reinício automático (via `nodemon`):
```bash
npx nodemon app.js
```

O servidor sobe em `http://localhost:3000`.

**Exemplo de requisição (PUT):**
```bash
curl -X PUT http://localhost:3000/livros/1 \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Vidas Secas", "autor": "Graciliano Ramos", "ano": 1938}'
```

### ex05 - API de Livros com Prisma ORM

Mesma API em camadas do ex03, agora persistindo os dados em PostgreSQL através do [Prisma ORM](https://www.prisma.io/). O acesso ao banco é feito pelo Prisma Client, e o esquema e a carga inicial de dados são versionados em migrations e seed.

**Estrutura:**
```
ex05/
├── app.js                              # configuração do Express e registro das rotas
├── prisma.config.ts                    # configuração do Prisma CLI (schema, migrations e seed)
├── prisma/
│   ├── schema.prisma                   # modelos e datasource
│   ├── migrations/                     # histórico de migrations versionado
│   └── seed.js                         # carga inicial de dados
├── routes/livros.routes.js             # definição das rotas do recurso livros
├── controllers/livros.controller.js    # tratamento de requisição e resposta
├── data/livros.repository.js           # acesso aos dados (Prisma Client)
├── middlewares/validacao.middleware.js # middleware genérico de validação
└── schemas/livro.schema.js             # schema de validação do livro (Zod)
```

**Modelos:** `Genero`, `Autor`, `Livro`, `LivroAutor` (tabela associativa), `Estudante` e `Emprestimo`.

#### 1. Instalação

```bash
cd ex05
npm install
```

As dependências relevantes são `@prisma/client` (runtime, usado pela aplicação) e `prisma` (CLI, em `devDependencies`), além de `dotenv` para carregar o `.env` na configuração do Prisma.

Para instalá-las em um projeto novo, do zero:
```bash
npm install @prisma/client
npm install --save-dev prisma dotenv
npx prisma init --datasource-provider postgresql
```

#### 2. Configuração

A conexão é lida da variável `DATABASE_URL`, definida no arquivo `.env` (que não é versionado):

```bash
DATABASE_URL="postgres://usuario:senha@localhost:5432/biblioteca2"
```

O arquivo `prisma.config.ts` aponta o CLI para o schema, o diretório de migrations e o comando de seed:

```ts
export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
    seed: "node prisma/seed.js",
  },
  engine: "classic",
  datasource: { url: env("DATABASE_URL") },
});
```

Antes de rodar as migrations, crie o banco vazio no PostgreSQL:
```bash
createdb biblioteca2
```

Comandos úteis de configuração:
```bash
npx prisma validate   # valida o schema.prisma
npx prisma format     # formata o schema.prisma
npx prisma generate   # gera o Prisma Client a partir do schema
```

#### 3. Migrations

Aplicar as migrations existentes e gerar o Prisma Client (ambiente de desenvolvimento):
```bash
npx prisma migrate dev
```

Criar uma nova migration após alterar o `schema.prisma`:
```bash
npx prisma migrate dev --name adicionar_status_emprestimo
```

Outros comandos:
```bash
npx prisma migrate status   # mostra quais migrations já foram aplicadas
npx prisma migrate deploy   # aplica as migrations pendentes (produção, não gera arquivos)
npx prisma migrate reset    # apaga o banco, reaplica todas as migrations e roda o seed
```

As migrations deste exercício são:
- `20260911211545_esquema_inicial` - criação das tabelas de gêneros, autores, livros, estudantes e empréstimos
- `20260911211656_adicionar_status_emprestimo` - inclusão da coluna `status` em empréstimos

#### 4. Seed

A carga inicial (gêneros, autores, livros, estudantes e empréstimos) está em `prisma/seed.js` e é idempotente: apaga os registros existentes antes de inserir, podendo ser executada quantas vezes for necessário.

```bash
npx prisma db seed
```

O seed também é executado automaticamente por `npx prisma migrate reset`.

#### 5. Executar a aplicação

```bash
node app.js
```

Para desenvolvimento com reinício automático (via `nodemon`):
```bash
npx nodemon app.js
```

O servidor sobe em `http://localhost:3000`.

Para inspecionar os dados pelo navegador:
```bash
npx prisma studio
```

**Rotas:**
- `GET /livros` - lista os livros, com filtros e paginação
- `GET /livros/:id` - retorna um livro específico pelo id, com o gênero e os empréstimos em aberto
- `POST /livros` - cadastra um novo livro (corpo em JSON, validado)
- `PUT /livros/:id` - atualiza um livro existente (corpo em JSON, validado)
- `DELETE /livros/:id` - remove um livro pelo id

**Parâmetros de consulta do `GET /livros`:** `genero`, `titulo`, `pagina` (padrão `1`), `limite` (padrão `10`), `ordenar` (padrão `titulo`) e `direcao` (padrão `asc`).

```bash
curl "http://localhost:3000/livros?genero=Romance&pagina=1&limite=5"
```

## Autor

Tassio Valle
