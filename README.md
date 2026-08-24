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

## Autor

Tassio Valle
