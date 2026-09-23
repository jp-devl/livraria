from fastapi import APIRouter, HTTPException
from app.schemas.livro import LivroSchema
from app.database.connection import SessionLocal
from app.database.models import LivroModel
from app.schemas.livro import LivroCreate


router = APIRouter(
    prefix="/livros",
    tags=["livros"],
)



#listar-livros
@router.get("/")
async def listar_livros():
    db = SessionLocal()
    livros = db.query(LivroModel).all()
    db.close()
    return {"livros": livros}



#adicionar-livro
@router.post("/")
async def adicionar_livro(livro: LivroCreate):
    db = SessionLocal()
    novo_livro = LivroModel(
        titulo=livro.titulo,
        autor=livro.autor,
        ano_publicacao=livro.ano_publicacao
    )
    db.add(novo_livro)
    db.commit()
    db.refresh(novo_livro)
    db.close()
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
