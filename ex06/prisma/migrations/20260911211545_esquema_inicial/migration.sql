-- CreateTable
CREATE TABLE "generos" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(60) NOT NULL,

    CONSTRAINT "generos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "autores" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(120) NOT NULL,
    "ano_nascimento" INTEGER,

    CONSTRAINT "autores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "livros" (
    "id" SERIAL NOT NULL,
    "titulo" VARCHAR(200) NOT NULL,
    "isbn" VARCHAR(20),
    "ano" INTEGER,
    "exemplares" INTEGER NOT NULL DEFAULT 1,
    "genero_id" INTEGER,
    "criado_em" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizado_em" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "livros_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "livros_autores" (
    "livro_id" INTEGER NOT NULL,
    "autor_id" INTEGER NOT NULL,

    CONSTRAINT "livros_autores_pkey" PRIMARY KEY ("livro_id","autor_id")
);

-- CreateTable
CREATE TABLE "estudantes" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(120) NOT NULL,
    "matricula" VARCHAR(20) NOT NULL,
    "email" VARCHAR(160),
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "estudantes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "emprestimos" (
    "id" SERIAL NOT NULL,
    "livro_id" INTEGER NOT NULL,
    "estudante_id" INTEGER NOT NULL,
    "data_retirada" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "data_prevista" TIMESTAMP(3) NOT NULL,
    "data_devolucao" TIMESTAMP(3),

    CONSTRAINT "emprestimos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "generos_nome_key" ON "generos"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "livros_isbn_key" ON "livros"("isbn");

-- CreateIndex
CREATE INDEX "livros_titulo_idx" ON "livros"("titulo");

-- CreateIndex
CREATE UNIQUE INDEX "estudantes_matricula_key" ON "estudantes"("matricula");

-- CreateIndex
CREATE UNIQUE INDEX "estudantes_email_key" ON "estudantes"("email");

-- CreateIndex
CREATE INDEX "emprestimos_estudante_id_data_devolucao_idx" ON "emprestimos"("estudante_id", "data_devolucao");

-- AddForeignKey
ALTER TABLE "livros" ADD CONSTRAINT "livros_genero_id_fkey" FOREIGN KEY ("genero_id") REFERENCES "generos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "livros_autores" ADD CONSTRAINT "livros_autores_livro_id_fkey" FOREIGN KEY ("livro_id") REFERENCES "livros"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "livros_autores" ADD CONSTRAINT "livros_autores_autor_id_fkey" FOREIGN KEY ("autor_id") REFERENCES "autores"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emprestimos" ADD CONSTRAINT "emprestimos_livro_id_fkey" FOREIGN KEY ("livro_id") REFERENCES "livros"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "emprestimos" ADD CONSTRAINT "emprestimos_estudante_id_fkey" FOREIGN KEY ("estudante_id") REFERENCES "estudantes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
