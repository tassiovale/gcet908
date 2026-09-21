import { prisma } from "./prisma.js";

export const emprestimosRepository = {
    contarAtivos: async (estudanteId) => {
        return prisma.emprestimo.count({ 
            where: { estudanteId, dataDevolucao: null } 
        });
    },
    contarAtrasados: async (estudanteId) => {
        return prisma.emprestimo.count({ 
            where: { 
                estudanteId, 
                dataDevolucao: null, 
                dataPrevista: { lt: new Date() } // less than current date 
            } 
        });
    },
    registrarComBaixa: async (emprestimo) => {
        const { livro, estudante, dataPrevista } = emprestimo;
        return prisma.$transaction(async (transacao) => {
            const baixa = await transacao.livro.updateMany({
                where: { id: livro.id, exemplares: { gt: 0 } }, // greater than 0
                data: { exemplares: { decrement: 1 } } // decrement by 1
            });

            if (baixa.count === 0) return null; // No book available for loan

            return transacao.emprestimo.create({
                data: { livroId: livro.id, estudanteId: estudante.id, dataPrevista },
                include: {
                    livro: { 
                        select: { 
                            id: true, 
                            titulo: true 
                        } 
                    },
                    estudante: { 
                        select: { 
                            id: true, 
                            nome: true, 
                            matricula: true 
                        } 
                    }
                }
            })
        });
    }
};