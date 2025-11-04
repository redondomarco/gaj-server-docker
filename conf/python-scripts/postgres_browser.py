import psycopg2

def connect_db():
    try:
        conn = psycopg2.connect(
            host="db",
            database="gaj",
            user="root", 
            password="pass123",
            port=5432
        )
        print("Conectado a PostgreSQL")
        return conn
    except Exception as e:
        print("Error de conexion: " + str(e))
        return None

def main():
    conn = connect_db()
    if not conn:
        return
    
    try:
        cursor = conn.cursor()
        
        # Listar tablas
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            ORDER BY table_name;
        """)
        tables = cursor.fetchall()
        
        print("\nTablas disponibles:")
        for i, table in enumerate(tables, 1):
            print(str(i) + ". " + table[0])
        
        if tables:
            table_choice = input("\nElige una tabla (numero): ")
            try:
                table_index = int(table_choice) - 1
                if 0 <= table_index < len(tables):
                    table_name = tables[table_index][0]
                    
                    # Mostrar estructura
                    cursor.execute("""
                        SELECT column_name, data_type 
                        FROM information_schema.columns 
                        WHERE table_name = %s 
                        ORDER BY ordinal_position;
                    """, (table_name,))
                    columns = cursor.fetchall()
                    
                    print("\nColumnas de " + table_name + ":")
                    for col in columns:
                        print(" - " + col[0] + " (" + col[1] + ")")
                    
                    # Mostrar algunos datos
                    cursor.execute("SELECT * FROM " + table_name + " LIMIT 5")
                    data = cursor.fetchall()
                    col_names = [desc[0] for desc in cursor.description]
                    
                    print("\nPrimeros 5 registros:")
                    print("Columnas: " + ", ".join(col_names))
                    for row in data:
                        print(row)
                        
            except ValueError:
                print("Numero invalido")
                
    except Exception as e:
        print("Error: " + str(e))
    finally:
        conn.close()
        print("\nConexion cerrada")

if __name__ == "__main__":
    main()