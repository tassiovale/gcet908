import { pool } from './conexao.js'

export const livrosRepository = {
    async listar({ genero, nome, pagina = 1, limite = 10 }) {
        const offset = (pagina - 1) * limite;
        const condicoes = [];
        const valores = [];

        if (genero) {
            valores.push(genero);
            condicoes.push(`g.nome = $${valores.length}`);
        }

        if (nome) {
            valores.push(`%${nome}%`);
            condicoes.push(`l.titulo ILIKE $${valores.length}`);
        }

        const where = condicoes.length ? `WHERE ${condicoes.join(' AND ')}` : '';

        valores.push(limite, offset);

        const { rows } = await pool.query(
            `SELECT 
                l.id, 
                l.titulo, 
                l.ano, 
                g.nome AS genero
            FROM livros l
                LEFT JOIN generos g ON g.id = l.genero_id
            ${where}
            ORDER BY l.titulo
            LIMIT $${valores.length - 1} 
            OFFSET $${valores.length}`,
            valores
        );

        return rows;
    },
    buscarPorId: async (id) => {
        const { rows } = await pool.query(
            'SELECT * FROM livros WHERE id = $1',
            [id]
        );
        return rows[0];
    },
    async criar({ titulo, isbn, ano, generoId }) {
        const { rows } = await pool.query(`
            INSERT INTO livros (titulo, isbn, ano, genero_id)
            VALUES ($1, $2, $3, $4)
            RETURNING *
        `, [titulo, isbn, ano, generoId]);
        return rows[0];
    },
    atualizar: async (id, dadosAtualizadosDoLivro) => {
        const { rows } = await pool.query(`
            UPDATE livros
            SET titulo = $2, isbn = $3, ano = $4, genero_id = $5
            WHERE id = $1
            RETURNING *
        `, [id, dadosAtualizadosDoLivro.titulo, dadosAtualizadosDoLivro.isbn, dadosAtualizadosDoLivro.ano, dadosAtualizadosDoLivro.generoId]);
        return rows[0];
    },
    remover: async (id) => {
        const { rows } = await pool.query(`
            DELETE FROM livros
            WHERE id = $1
            RETURNING *
        `, [id]);
        return rows[0];
    }
};