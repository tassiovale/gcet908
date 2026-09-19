import { prisma } from "./prisma.js";

export const estudantesRepository = {
    buscarPorId: async (id) => {
        return prisma.estudante.findUnique({ where: { id } });
    },
};