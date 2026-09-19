import { emprestimosRepository } from "../data/emprestimos.repository.js";
import { estudantesRepository } from "../data/estudantes.repository.js";
import { livrosRepository } from "../data/livros.repository.js";
import { emprestimoDTO } from "../dtos/emprestimo.dto.js";
import { criarEmprestimosService } from "../services/emprestimos.service.js";

const emprestimosService = criarEmprestimosService({
    emprestimosRepo: emprestimosRepository,
    livrosRepo: livrosRepository,
    estudantesRepo: estudantesRepository
});

export const emprestimosController = {
    registrar: async (req, res, next) => {
        try {
            const emprestimo = await emprestimosService.registrar({
                livroId: req.body.livroId,
                estudanteId: req.body.estudanteId,
                dias: req.body.dias
            });
            res.status(201).json(
                emprestimoDTO(emprestimo)
            );
        } catch (error) {
            next(error);
        }
    }
};