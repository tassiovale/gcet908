import { ConflitoError, NaoEncontradoError } from "../errors/index.js";

  export const LIMITE_EMPRESTIMOS = 3;
  export const DIAS_PADRAO = 14;

  const adicionarDias = (data, dias) => {
      const resultado = new Date(data);
      resultado.setDate(resultado.getDate() + dias);
      return resultado;
  };

  export function criarEmprestimosService({ emprestimosRepo, livrosRepo, estudantesRepo }) {
      return {
          async registrar({ livroId, estudanteId, dias = DIAS_PADRAO }) {
              const estudante = await estudantesRepo.buscarPorId(estudanteId);
              if (!estudante)       throw new NaoEncontradoError('Estudante', estudanteId);
              if (!estudante.ativo) throw new ConflitoError('Estudante inativo não pode retirar livros');

              const pendencias = await emprestimosRepo.contarAtrasados(estudanteId);
              if (pendencias > 0) throw new ConflitoError('Estudante possui devoluções em atraso');

              const ativos = await emprestimosRepo.contarAtivos(estudanteId);
              if (ativos >= LIMITE_EMPRESTIMOS) {
                  throw new ConflitoError(`Limite de ${LIMITE_EMPRESTIMOS} empréstimos atingido`);
              }

              const livro = await livrosRepo.buscarPorId(livroId);
              if (!livro)               throw new NaoEncontradoError('Livro', livroId);
              if (livro.exemplares < 1) throw new ConflitoError('Sem exemplares disponíveis');

              const dataPrevista = adicionarDias(new Date(), dias);
              const emprestimo = await emprestimosRepo.registrarComBaixa({
                  livroId, estudanteId, dataPrevista
              });

              if (!emprestimo) throw new ConflitoError('Sem exemplares disponíveis');
              return emprestimo;
          }
      };
  }
