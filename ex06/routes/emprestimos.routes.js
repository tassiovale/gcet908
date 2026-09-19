import { Router } from "express";
import { validar } from "../middlewares/validacao.middleware.js";
import { emprestimoSchema } from "../schemas/emprestimo.schema.js";
import { emprestimosController } from "../controllers/emprestimos.controller.js";

const router = Router();

router.post(
    '/', 
    validar(emprestimoSchema),
    emprestimosController.registrar
);

export default router;