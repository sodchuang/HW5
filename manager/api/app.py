import os
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy import Column, Integer, String, DateTime, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
from typing import List
import psycopg2
from contextlib import contextmanager

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://worker:worker_password@192.168.0.34:5432/worker_names")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

# Database Models
class Name(Base):
    __tablename__ = "names"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

# Create tables (will be handled by init.sql in production)
try:
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print(f"Note: {e}")

# FastAPI app configuration
app = FastAPI(
    title="Names Management API", 
    description="A simple API for managing names in Docker Swarm",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class NameIn(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)

class NameOut(BaseModel):
    id: int
    name: str
    created_at: datetime

    class Config:
        from_attributes = True

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# API endpoints
@app.get("/", tags=["system"])
def root():
    return {
        "message": "Names Management API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/api/health", tags=["system"])
def health():
    """Health check endpoint for Docker Swarm"""
    try:
        # Test database connection
        db = SessionLocal()
        from sqlalchemy import text
        db.execute(text("SELECT 1"))
        db.close()
        
        return {
            "status": "ok",
            "timestamp": datetime.utcnow().isoformat(),
            "database": "connected",
            "version": "1.0.0"
        }
    except Exception as e:
        # Return degraded status instead of 503 to allow service to start
        return {
            "status": "degraded",
            "timestamp": datetime.utcnow().isoformat(),
            "database": "disconnected",
            "error": str(e),
            "version": "1.0.0"
        }

@app.get("/healthz", tags=["system"])
def healthz():
    """Simple health check for nginx"""
    return {"status": "ok"}

@app.post("/api/names", response_model=NameOut, tags=["names"])
def add_name(item: NameIn, db = Depends(get_db)):
    """Add a new name"""
    if not item.name.strip():
        raise HTTPException(status_code=400, detail="Name cannot be empty")
    
    new_name = Name(name=item.name.strip())
    db.add(new_name)
    db.commit()
    db.refresh(new_name)
    return new_name

@app.get("/api/names", response_model=List[NameOut], tags=["names"])
def list_names(db = Depends(get_db)):
    """Get all names"""
    names = db.query(Name).order_by(Name.created_at.desc()).all()
    return names

@app.get("/api/names/{name_id}", response_model=NameOut, tags=["names"])
def get_name(name_id: int, db = Depends(get_db)):
    """Get a specific name by ID"""
    name = db.query(Name).filter(Name.id == name_id).first()
    if not name:
        raise HTTPException(status_code=404, detail="Name not found")
    return name

@app.put("/api/names/{name_id}", response_model=NameOut, tags=["names"])
def update_name(name_id: int, item: NameIn, db = Depends(get_db)):
    """Update a name"""
    name = db.query(Name).filter(Name.id == name_id).first()
    if not name:
        raise HTTPException(status_code=404, detail="Name not found")
    
    if not item.name.strip():
        raise HTTPException(status_code=400, detail="Name cannot be empty")
    
    name.name = item.name.strip()
    db.commit()
    db.refresh(name)
    return name

@app.delete("/api/names/{name_id}", tags=["names"])
def delete_name(name_id: int, db = Depends(get_db)):
    """Delete a name"""
    name = db.query(Name).filter(Name.id == name_id).first()
    if not name:
        raise HTTPException(status_code=404, detail="Name not found")
    
    db.delete(name)
    db.commit()
    return {"message": "Name deleted successfully", "deleted_id": name_id}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)