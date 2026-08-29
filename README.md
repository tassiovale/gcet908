# GCET908 - Desenvolvimento de Software II

Repositório com os exercícios práticos da disciplina GCET908, utilizando Node.js e Express para construção de servidores web e APIs REST.

## Requisitos

- [Node.js](https://nodejs.org/) (com npm)

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

## Autor

Tassio Valle
