import { Router } from "express";
import { livrosController } from '../controllers/livros.controller.js';
import { validar } from "../middlewares/validacao.middleware.js";
import { livroSchema } from "../schemas/livro.schema.js";

const router = Router();

router.get('/', livrosController.listar);
router.get('/:id', livrosController.buscarPorId);
router.post(
    '/', 
    validar(livroSchema),
    livrosController.criar
);
router.put(
    '/:id', 
    validar(livroSchema),
    livrosController.atualizar
);
router.delete('/:id', livrosController.remover);

export default router;
