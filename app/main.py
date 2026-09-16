from fastapi import FastAPI, HTTPException
from app.schemas.livro import LivroSchema
from app.routers.livros import livros


app = FastAPI()

app.include_router(livros.router)


#rota-inicial
@app.get("/")
async def home():
    return {"message": "Bem vindo à API de Livros!"}


