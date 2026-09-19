import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// Datas relativas a hoje, como o CURRENT_DATE +/- INTERVAL do script SQL
const emDias = (dias) => {
    const data = new Date();
    data.setUTCHours(0, 0, 0, 0);
    data.setUTCDate(data.getUTCDate() + dias);
    return data;
};

const generos = [
    'Romance',
    'Ficção Científica',
    'Fantasia',
    'Conto',
    'Poesia',
    'Terror',
    'Suspense',
    'Literatura Brasileira',
    'Não-ficção',
    'Distopia',
    'Infantojuvenil',
    'Realismo Mágico',
    'História'
];

const autores = [
    { nome: 'Machado de Assis', anoNascimento: 1839 },
    { nome: 'Clarice Lispector', anoNascimento: 1920 },
    { nome: 'Jorge Amado', anoNascimento: 1912 },
    { nome: 'João Guimarães Rosa', anoNascimento: 1908 },
    { nome: 'Graciliano Ramos', anoNascimento: 1892 },
    { nome: 'José de Alencar', anoNascimento: 1829 },
    { nome: 'Aluísio Azevedo', anoNascimento: 1857 },
    { nome: 'Cecília Meireles', anoNascimento: 1901 },
    { nome: 'Carlos Drummond de Andrade', anoNascimento: 1902 },
    { nome: 'Rachel de Queiroz', anoNascimento: 1910 },
    { nome: 'Paulo Coelho', anoNascimento: 1947 },
    { nome: 'J.K. Rowling', anoNascimento: 1965 },
    { nome: 'George Orwell', anoNascimento: 1903 },
    { nome: 'J.R.R. Tolkien', anoNascimento: 1892 },
    { nome: 'Gabriel García Márquez', anoNascimento: 1927 },
    { nome: 'Agatha Christie', anoNascimento: 1890 },
    { nome: 'Isaac Asimov', anoNascimento: 1920 },
    { nome: 'Jane Austen', anoNascimento: 1775 },
    { nome: 'Stephen King', anoNascimento: 1947 },
    { nome: 'Suzanne Collins', anoNascimento: 1962 },
    { nome: 'Yuval Noah Harari', anoNascimento: 1976 },
    { nome: 'Franz Kafka', anoNascimento: 1883 },
    { nome: 'Ray Bradbury', anoNascimento: 1920 },
    { nome: 'William Gibson', anoNascimento: 1948 },
    { nome: 'Frank Herbert', anoNascimento: 1920 },
    { nome: 'Aldous Huxley', anoNascimento: 1894 },
    { nome: 'Terry Pratchett', anoNascimento: 1948 },
    { nome: 'Neil Gaiman', anoNascimento: 1960 }
];

const livros = [
    { titulo: 'Dom Casmurro', isbn: '9788508058859', ano: 1899, exemplares: 4, genero: 'Literatura Brasileira', autores: ['Machado de Assis'] },
    { titulo: 'Memórias Póstumas de Brás Cubas', isbn: '9788508058866', ano: 1881, exemplares: 3, genero: 'Literatura Brasileira', autores: ['Machado de Assis'] },
    { titulo: 'Quincas Borba', isbn: '9788572327443', ano: 1891, exemplares: 2, genero: 'Literatura Brasileira', autores: ['Machado de Assis'] },
    { titulo: 'A Hora da Estrela', isbn: '9788532507739', ano: 1977, exemplares: 3, genero: 'Literatura Brasileira', autores: ['Clarice Lispector'] },
    { titulo: 'Capitães da Areia', isbn: '9788535914856', ano: 1937, exemplares: 4, genero: 'Literatura Brasileira', autores: ['Jorge Amado'] },
    { titulo: 'Grande Sertão: Veredas', isbn: '9788535910636', ano: 1956, exemplares: 2, genero: 'Literatura Brasileira', autores: ['João Guimarães Rosa'] },
    { titulo: 'Vidas Secas', isbn: '9788526012647', ano: 1938, exemplares: 3, genero: 'Literatura Brasileira', autores: ['Graciliano Ramos'] },
    { titulo: 'Iracema', isbn: '9788572327351', ano: 1865, exemplares: 2, genero: 'Literatura Brasileira', autores: ['José de Alencar'] },
    { titulo: 'O Cortiço', isbn: '9788572327047', ano: 1890, exemplares: 2, genero: 'Literatura Brasileira', autores: ['Aluísio Azevedo'] },
    { titulo: 'Antologia Poética', isbn: '9788503009073', ano: 1963, exemplares: 2, genero: 'Poesia', autores: ['Cecília Meireles'] },
    { titulo: 'A Rosa do Povo', isbn: '9788535911732', ano: 1945, exemplares: 2, genero: 'Poesia', autores: ['Carlos Drummond de Andrade'] },
    { titulo: 'O Quinze', isbn: '9788520925890', ano: 1930, exemplares: 2, genero: 'Literatura Brasileira', autores: ['Rachel de Queiroz'] },
    { titulo: 'O Alquimista', isbn: '9788576653836', ano: 1988, exemplares: 5, genero: 'Ficção Científica', autores: ['Paulo Coelho'] },
    { titulo: 'Harry Potter e a Pedra Filosofal', isbn: '9788532511010', ano: 1997, exemplares: 6, genero: 'Fantasia', autores: ['J.K. Rowling'] },
    { titulo: '1984', isbn: '9788535914849', ano: 1949, exemplares: 5, genero: 'Distopia', autores: ['George Orwell'] },
    { titulo: 'O Senhor dos Anéis: A Sociedade do Anel', isbn: '9788595084759', ano: 1954, exemplares: 3, genero: 'Fantasia', autores: ['J.R.R. Tolkien'] },
    { titulo: 'O Hobbit', isbn: '9788595084308', ano: 1937, exemplares: 4, genero: 'Fantasia', autores: ['J.R.R. Tolkien'] },
    { titulo: 'Cem Anos de Solidão', isbn: '9788501063279', ano: 1967, exemplares: 3, genero: 'Realismo Mágico', autores: ['Gabriel García Márquez'] },
    { titulo: 'Assassinato no Expresso Oriente', isbn: '9788525056560', ano: 1934, exemplares: 3, genero: 'Suspense', autores: ['Agatha Christie'] },
    { titulo: 'Eu, Robô', isbn: '9788576573462', ano: 1950, exemplares: 3, genero: 'Ficção Científica', autores: ['Isaac Asimov'] },
    { titulo: 'Orgulho e Preconceito', isbn: '9788544001820', ano: 1813, exemplares: 3, genero: 'Romance', autores: ['Jane Austen'] },
    { titulo: 'It: A Coisa', isbn: '9788581050609', ano: 1986, exemplares: 2, genero: 'Terror', autores: ['Stephen King'] },
    { titulo: 'Jogos Vorazes', isbn: '9788598078279', ano: 2008, exemplares: 4, genero: 'Distopia', autores: ['Suzanne Collins'] },
    { titulo: 'Sapiens: Uma Breve História da Humanidade', isbn: '9788525432815', ano: 2011, exemplares: 3, genero: 'Não-ficção', autores: ['Yuval Noah Harari'] },
    { titulo: 'A Metamorfose', isbn: '9788525410216', ano: 1915, exemplares: 4, genero: 'Ficção Científica', autores: ['Franz Kafka'] },
    { titulo: 'Fahrenheit 451', isbn: '9788576573240', ano: 1953, exemplares: 3, genero: 'Distopia', autores: ['Ray Bradbury'] },
    { titulo: 'Neuromancer', isbn: '9788576571161', ano: 1984, exemplares: 2, genero: 'Ficção Científica', autores: ['William Gibson'] },
    { titulo: 'Duna', isbn: '9788576572861', ano: 1965, exemplares: 3, genero: 'Ficção Científica', autores: ['Frank Herbert'] },
    { titulo: 'Admirável Mundo Novo', isbn: '9788525056584', ano: 1932, exemplares: 3, genero: 'Distopia', autores: ['Aldous Huxley'] },
    // Livro com dois autores (demonstra o N:N)
    { titulo: 'Belas Maldições', isbn: '9788565530276', ano: 1990, exemplares: 2, genero: 'Fantasia', autores: ['Terry Pratchett', 'Neil Gaiman'] }
];

const estudantes = [
    { nome: 'Ana Beatriz Souza', matricula: '2023001', email: 'ana.souza@estudante.edu.br', ativo: true },
    { nome: 'Bruno Carvalho Lima', matricula: '2023002', email: 'bruno.lima@estudante.edu.br', ativo: true },
    { nome: 'Carla Meneses', matricula: '2023003', email: 'carla.meneses@estudante.edu.br', ativo: true },
    { nome: 'Diego Ferreira Santos', matricula: '2023004', email: 'diego.santos@estudante.edu.br', ativo: true },
    { nome: 'Elisa Ramos Oliveira', matricula: '2023005', email: 'elisa.oliveira@estudante.edu.br', ativo: false },
    { nome: 'Felipe Andrade Costa', matricula: '2024001', email: 'felipe.costa@estudante.edu.br', ativo: true },
    { nome: 'Gabriela Nunes', matricula: '2024002', email: 'gabriela.nunes@estudante.edu.br', ativo: true },
    { nome: 'Henrique Pires', matricula: '2024003', email: 'henrique.pires@estudante.edu.br', ativo: true },
    { nome: 'Isabela Cardoso', matricula: '2024004', email: 'isabela.cardoso@estudante.edu.br', ativo: true },
    { nome: 'João Vitor Almeida', matricula: '2024005', email: 'joao.almeida@estudante.edu.br', ativo: true },
    { nome: 'Karina Batista', matricula: '2025001', email: 'karina.batista@estudante.edu.br', ativo: true },
    { nome: 'Lucas Teixeira', matricula: '2025002', email: 'lucas.teixeira@estudante.edu.br', ativo: true },
    { nome: 'Mariana Cunha', matricula: '2025003', email: 'mariana.cunha@estudante.edu.br', ativo: true },
    { nome: 'Nicolas Barros', matricula: '2025004', email: 'nicolas.barros@estudante.edu.br', ativo: true },
    { nome: 'Olivia Freitas', matricula: '2025005', email: 'olivia.freitas@estudante.edu.br', ativo: true },
    { nome: 'Pedro Henrique Rocha', matricula: '2026001', email: 'pedro.rocha@estudante.edu.br', ativo: true }
];

// Mistura de devolvidos, ativos em dia e atrasados
const emprestimos = [
    { livro: 'Dom Casmurro', matricula: '2023001', retirada: -40, prevista: -26, devolucao: -28, status: 'devolvido' },
    { livro: 'Harry Potter e a Pedra Filosofal', matricula: '2023002', retirada: -35, prevista: -21, devolucao: -20, status: 'devolvido' },
    { livro: 'O Alquimista', matricula: '2023003', retirada: -30, prevista: -16, devolucao: -18, status: 'devolvido' },
    { livro: '1984', matricula: '2024001', retirada: -25, prevista: -11, devolucao: -5, status: 'devolvido' },
    { livro: 'Cem Anos de Solidão', matricula: '2024002', retirada: -20, prevista: -6, devolucao: null, status: 'atrasado' },
    { livro: 'It: A Coisa', matricula: '2024003', retirada: -18, prevista: -4, devolucao: null, status: 'atrasado' },
    { livro: 'Jogos Vorazes', matricula: '2024004', retirada: -10, prevista: 4, devolucao: null, status: 'ativo' },
    { livro: 'Duna', matricula: '2024005', retirada: -7, prevista: 7, devolucao: null, status: 'ativo' },
    { livro: 'Sapiens: Uma Breve História da Humanidade', matricula: '2025001', retirada: -5, prevista: 9, devolucao: null, status: 'ativo' },
    { livro: 'O Senhor dos Anéis: A Sociedade do Anel', matricula: '2025002', retirada: -3, prevista: 11, devolucao: null, status: 'ativo' },
    { livro: 'Assassinato no Expresso Oriente', matricula: '2025003', retirada: -60, prevista: -46, devolucao: -50, status: 'devolvido' },
    { livro: 'Fahrenheit 451', matricula: '2025004', retirada: -2, prevista: 12, devolucao: null, status: 'ativo' },
    { livro: 'Eu, Robô', matricula: '2025005', retirada: -1, prevista: 13, devolucao: null, status: 'ativo' },
    { livro: 'Grande Sertão: Veredas', matricula: '2026001', retirada: -55, prevista: -41, devolucao: -39, status: 'devolvido' },
    { livro: 'Belas Maldições', matricula: '2023004', retirada: -12, prevista: -2, devolucao: null, status: 'atrasado' }
];

async function main() {
    // Limpa na ordem inversa das dependências para o seed poder rodar de novo
    await prisma.emprestimo.deleteMany();
    await prisma.livroAutor.deleteMany();
    await prisma.livro.deleteMany();
    await prisma.autor.deleteMany();
    await prisma.estudante.deleteMany();
    await prisma.genero.deleteMany();

    await prisma.genero.createMany({ data: generos.map((nome) => ({ nome })) });
    await prisma.autor.createMany({ data: autores });
    await prisma.estudante.createMany({ data: estudantes });

    // Mapas nome -> id, no lugar dos subselects usados no script SQL
    const generoId = new Map((await prisma.genero.findMany()).map((g) => [g.nome, g.id]));
    const autorId = new Map((await prisma.autor.findMany()).map((a) => [a.nome, a.id]));
    const estudanteId = new Map((await prisma.estudante.findMany()).map((e) => [e.matricula, e.id]));

    for (const { genero, autores: nomesAutores, ...livro } of livros) {
        await prisma.livro.create({
            data: {
                ...livro,
                generoId: generoId.get(genero),
                autores: {
                    create: nomesAutores.map((nome) => ({ autorId: autorId.get(nome) }))
                }
            }
        });
    }

    const livroId = new Map((await prisma.livro.findMany()).map((l) => [l.titulo, l.id]));

    await prisma.emprestimo.createMany({
        data: emprestimos.map((e) => ({
            livroId: livroId.get(e.livro),
            estudanteId: estudanteId.get(e.matricula),
            dataRetirada: emDias(e.retirada),
            dataPrevista: emDias(e.prevista),
            dataDevolucao: e.devolucao === null ? null : emDias(e.devolucao),
            status: e.status
        }))
    });

    console.log(
        `Seed concluído: ${generos.length} gêneros, ${autores.length} autores, ` +
        `${livros.length} livros, ${estudantes.length} estudantes, ${emprestimos.length} empréstimos.`
    );
}

main()
    .catch((erro) => {
        console.error(erro);
        process.exit(1);
    })
    .finally(() => prisma.$disconnect());
