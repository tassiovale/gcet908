import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

export const livrosRepository = {
    async listar({ genero, titulo, pagina = 1, limite = 10, ordenar = 'titulo', direcao = 'asc' }) {
        const where = {
            ...(genero && { genero: { nome: genero } }),
            ...(titulo && { titulo: { contains: titulo, mode: 'insensitive' } })
        };

        const itensPorPagina = parseInt(limite, 10);
        const paginaAtual = parseInt(pagina, 10);

        const [dados, total] = await prisma.$transaction([
            prisma.livro.findMany({
                where,
                include: {
                    genero: true,
                    autores: { include: { autor: true } }
                },
                orderBy: { [ordenar]: direcao },
                skip: (paginaAtual - 1) * itensPorPagina,
                take: itensPorPagina
            }),
            prisma.livro.count({ where })
        ]);

        return {
            dados,
            paginacao: { pagina, limite, total, totalPaginas: Math.ceil(total / limite) }
        };
    },
    buscarPorId: async (id) => {
        return prisma.livro.findUnique({
            where: { id },
            include: {
                genero: true,
                emprestimos: {
                    where: { dataDevolucao: null },
                    include: { estudante: { select: { nome: true, matricula: true } } }
                }
            }
        });
    },
    async criar({ titulo, isbn, ano, generoId }) {
        return prisma.livro.create({
            data: { titulo, isbn, ano, generoId },
            include: { genero: true }
        });
    },
    atualizar: async (id, dadosAtualizadosDoLivro) => {
        return prisma.livro.update({
            where: { id },
            data: dadosAtualizadosDoLivro
        });
    },
    remover: async (id) => {
        return prisma.livro.delete({ where: { id } });
    }
};