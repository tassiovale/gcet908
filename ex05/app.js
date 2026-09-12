import express from 'express';
import livrosRouter from './routes/livros.routes.js'

const app = express()
const port = 3000
app.use(express.json())

app.use('/livros', livrosRouter)

app.listen(port, () => {
  console.log(`API REST de livros rodando na porta ${port}`)
})