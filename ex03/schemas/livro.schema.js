import { z } from 'zod';

export const livroSchema = z.object({
    titulo: z.
        string().
        min(1, { message: "O título é obrigatório" })
        .max(200, { message: "O título deve ter no máximo 200 caracteres" }),
    autor: z.
        string().
        min(1, { message: "O autor é obrigatório" })
        .max(100, { message: "O autor deve ter no máximo 100 caracteres" }),
    ano: z.
        number().
        min(1000, { message: "O ano é obrigatório" })
        .max(2026, { message: "O ano deve ser menor ou igual a 2026" }),
});