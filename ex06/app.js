import express from 'express';
import livrosRouter from './routes/livros.routes.js'
import emprestimosRouter from './routes/emprestimos.routes.js'  
import { tratarErros } from './middlewares/error.middleware.js';

const app = express()
const port = 3000
app.use(express.json())

app.use('/livros', livrosRouter)
app.use('/emprestimos', emprestimosRouter)

app.use(tratarErros);

app.listen(port, () => {
  console.log(`API REST de livros rodando na porta ${port}`)
})