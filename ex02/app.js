const express = require('express');
const app = express()
const port = 3000
app.use(express.json())

// API REST trabalha com JSON
// Recurso Livros
const livros = [
  { 
    id: 1, 
    titulo: "Vidas Secas", 
    autor: "Graciliano Ramon", 
    ano: 1938 
  },
  { 
    id: 2, 
    titulo: "Grande Sertão", 
    autor: "Guimarães Rosa", 
    ano: 1950 
  }
]

let proximoId = 3;

app.get('/livros', (req, res) => {
  res.json(livros)
})

app.get('/livros/:id', (req, res) => {
  const id = parseInt(req.params.id)
  const livro = livros.find(liv => liv.id === id)
  res.json(livro)
})

app.post('/livros', (req, res) => {
  const livro = req.body
  livro.id = proximoId++
  livros.push(livro)
  res.json(livro)
})

// Lista: indíces [0, 1, 2, ...]

app.delete('/livros/:id', (req, res) => {
  const id = parseInt(req.params.id)
  const index = livros.findIndex(liv => liv.id === id)
  if (index !== -1) { // Encontrei o livro para remover
    livros.splice(index, 1)
    res.json({ message: 'Livro removido com sucesso' })
  } else {
    res.status(404).json({ message: 'Livro não encontrado' })
  }
})

app.listen(port, () => {
  console.log(`API REST de livros rodando na porta ${port}`)
})