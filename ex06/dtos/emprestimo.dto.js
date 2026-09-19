export const emprestimoDTO = (emprestimo) => ({
    id: emprestimo.id,
    status: emprestimo.status,
    dataPrevista: emprestimo.dataPrevista,
    dataDevolucao: emprestimo.dataDevolucao,
    livro: {
        id: emprestimo.livro.id,
        titulo: emprestimo.livro.titulo
    },
    estudante: {
        id: emprestimo.estudante.id,
        nome: emprestimo.estudante.nome
    }
});