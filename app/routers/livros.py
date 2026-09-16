from fastapi import APIRouter, HTTPException
from app.schemas.livro import LivroSchema

router = APIRouter(
    prefix="/livros",
    tags=["livros"],
)



#Banco de Dados em memória
Livros = [
    LivroSchema(id=1, titulo="Hobbit", autor="J.R.R. Tolkien", 
                 ano_publicacao=1937),
    LivroSchema(id=2, titulo="Senhor dos Anéis", 
                autor="J.R.R. Tolkien", ano_publicacao=1954),
]

#listar-livros
@router.get("/")
async def listar_livros():
    return {"livros": Livros}


#adicionar-livro
@router.post("/")
async def adicionar_livro(livro: str):
    Livros.append(livro)
    return {"message": "Livro adicionado com sucesso!"}


#atualizar-livro
@router.put("/{index}")
async def atualizar_livro(index: int, new_livro: str):
    if index > len(Livros) or index < 0:
        raise HTTPException(status_code=404,
                             detail="Livro não encontrado!")
    Livros[index] = new_livro
    return {"message": "Livro atualizado com sucesso!"}


#deletar-livro
@router.delete("/{index}")
async def deletar_livro(index: int):
    if index > len(Livros) or index < 0:
        raise HTTPException(status_code=404,
                             detail="Livro não encontrado!")
    Livros.pop(index)
    return {"message": "Livro deletado com sucesso!"}
