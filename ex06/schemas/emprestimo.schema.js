import { z } from 'zod';

export const emprestimoSchema = z.object({
    livroId: z.number().int().positive({ message: "O ID do livro é obrigatório" }),
    estudanteId: z.number().int().positive({ message: "O ID do estudante é obrigatório" }),
    dias: z.number().int().min(1).max(30).optional()
});