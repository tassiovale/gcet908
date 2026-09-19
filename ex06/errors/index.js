export class DominioError extends Error {
    constructor(mensagem, status) {
        super(mensagem);
        this.name = this.constructor.name;
        this.status = status;
    }
}

export class NaoEncontradoError extends DominioError {
    constructor(recurso, id) {
        super(`${recurso} ${id} não encontrado`, 404);
    }
}

export class ConflitoError extends DominioError {
    constructor(mensagem) {
        super(mensagem, 409);
    }
}