import pg from 'pg';

export const pool = new pg.Pool({
  connectionString: 'postgres://postgres:123456@localhost:5432/biblioteca', // string de conexão com o banco de dados
  max: 10,                      // até 10 conexões simultâneas
  idleTimeoutMillis: 30000
});