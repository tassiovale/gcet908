import { livrosRepository } from '../data/livros.repository.js'

export const livrosController = {
    listar: (req, res) => {
        const livros = livrosRepository.listar()
        res.json(livros)
    },
    buscarPorId: (req, res) => {
        const id = parseInt(req.params.id)
        const livro = livrosRepository.buscarPorId(id)
        if (livro) {
            res.json(livro)
        } else {
            res.status(404).json({ message: "Livro não encontrado" })
        }
    },
    criar: (req, res) => {
        const livroSemId = req.body
        const livroComId = livrosRepository.criar(livroSemId)
        res.status(201).json(livroComId)
    },
    atualizar: (req, res) => {
        const id = parseInt(req.params.id)
        const dadosAtualizadosDoLivro = req.body
        const livroAtualizado = livrosRepository.atualizar(id, dadosAtualizadosDoLivro)
        if (livroAtualizado) {
            res.json(livroAtualizado)
        } else {
            res.status(404).json({ message: "Livro não encontrado" })
        }
    },
    remover: (req, res) => {
        const id = parseInt(req.params.id)
        const sucesso = livrosRepository.remover(id)
        if (sucesso) {
            res.json({ message: "Livro removido com sucesso" })
        } else {
            res.status(404).json({ message: "Livro não encontrado" })
        }
    }
};