
import sqlite3
from pathlib import Path

# Store the database inside the backend folder
BASE_DIR = Path(__file__).resolve().parent
DATABASE_PATH = BASE_DIR / "farmer.db"


def init_db():
    connection = sqlite3.connect(DATABASE_PATH)

    try:
        cursor = connection.cursor()

        # Table for offline farming knowledge
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS farming_knowledge (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                topic TEXT NOT NULL,
                crop TEXT,
                language TEXT NOT NULL,
                question TEXT NOT NULL,
                answer TEXT NOT NULL,
                source TEXT,
                offline_available INTEGER DEFAULT 1,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # Table for storing farmer questions
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS farmer_queries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                question TEXT NOT NULL,
                language TEXT,
                answer TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        """)

        connection.commit()
        print("Database initialized successfully!")
        print(f"Database location: {DATABASE_PATH}")

        # Display the tables created
        cursor.execute("""
            SELECT name FROM sqlite_master
            WHERE type = 'table'
            ORDER BY name
        """)

        print("Tables:", cursor.fetchall())

    finally:
        connection.close()


if __name__ == "__main__":
    init_db()
