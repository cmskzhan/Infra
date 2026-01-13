from fastapi import APIRouter

router = APIRouter()

@router.get("/greet")
async def greet(name: str = "World"):
    return {"message": f"Hello, {name}!"}

@router.get("/ep1")
async def endpoint_one():
    return {"message": "This is endpoint one."}