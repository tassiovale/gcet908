const livros = [
  { 
    id: 1, 
    titulo: "Vidas Secas", 
    autor: "Graciliano Ramon", 
    ano: 1938 
  },
  { 
    id: 2, 
    titulo: "Grande Sertão", 
    autor: "Guimarães Rosa", 
    ano: 1950 
  }
]

let proximoId = 3;

export const livrosRepository = {
    listar: () => livros,
    buscarPorId: (id) => livros.find(liv => liv.id === id),
    criar: (livro) => {
        livro.id = proximoId++
        livros.push(livro)
        return livro
    },
    atualizar: (id, dadosAtualizadosDoLivro) => {
        const index = livros.findIndex(liv => liv.id === id)
        if (index !== -1) {
            /*
            ANTES
            dadosAtualizadosDoLivro
            {
                "titulo": "Aprendizado Profundo",
                "autor": "Camila Silva",
                "ano": 2027
            }
            */
            livros[index] = { id, ...dadosAtualizadosDoLivro }
            /*
            DEPOIS
            {
                "id": 2,
                "titulo": "Aprendizado Profundo",
                "autor": "Camila Silva",
                "ano": 2027
            }
            */
            return livros[index]
        }
        return null
    },
    remover: (id) => {
        const index = livros.findIndex(liv => liv.id === id)
        if (index !== -1) {
            livros.splice(index, 1)
            return true
        }
        return false
    }
};