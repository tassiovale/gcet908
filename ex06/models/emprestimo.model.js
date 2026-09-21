export class Emprestimo {
    constructor({ livro, estudante, dataPrevista, dataDevolucao = null }) {
        this.livro = livro;
        this.estudante = estudante;
        this.dataPrevista = dataPrevista;
        this.dataDevolucao = dataDevolucao;
    }
}