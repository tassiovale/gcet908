import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

export const estudantesRepository = {
    buscarPorId: async (id) => {
        return prisma.estudante.findUnique({ where: { id } });
    },
};