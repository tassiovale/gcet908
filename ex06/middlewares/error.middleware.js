import { DominioError } from '../errors/index.js';

  export const tratarErros = (erro, req, res, next) => {
      if (erro instanceof DominioError) {
          return res.status(erro.status).json({ mensagem: erro.message });
      }
      console.error(erro);
      res.status(500).json({ mensagem: "Erro interno do servidor" });
  };
