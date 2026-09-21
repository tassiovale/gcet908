import { Emprestimo } from "./emprestimo.model.js";

const adicionarDias = (data, dias) => {
    const resultado = new Date(data);
    resultado.setDate(resultado.getDate() + dias);
    return resultado;
};

export class EmprestimoFactory {
    static criar({ livro, estudante, dias }) {
        const dataPrevista = adicionarDias(new Date(), dias);
        return new Emprestimo({ livro, estudante, dataPrevista });
    }
}