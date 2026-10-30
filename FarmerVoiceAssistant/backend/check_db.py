
import sqlite3
from pathlib import Path

db_path = Path(__file__).resolve().parent / "farmer.db"

print("Database path:", db_path)
print("File exists:", db_path.exists())
print("File size:", db_path.stat().st_size, "bytes")

try:
    # Open the existing database in read-only mode.
    db_uri = db_path.as_uri() + "?mode=ro"

    with sqlite3.connect(db_uri, uri=True) as connection:
        print("\nIntegrity check:")
        print(connection.execute("PRAGMA integrity_check").fetchall())

        print("\nTables found:")
        tables = connection.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        ).fetchall()
        print(tables)

        print("\nFarming knowledge table:")
        schema = connection.execute(
            "PRAGMA table_info(farming_knowledge)"
        ).fetchall()
        print(schema)

        if schema:
            count = connection.execute(
                "SELECT COUNT(*) FROM farming_knowledge"
            ).fetchone()[0]
            print("\nNumber of farming records:", count)

except sqlite3.Error as error:
    print("\nSQLite error:", error)
