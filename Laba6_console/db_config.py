import psycopg2

def get_connection():
    try:
        print("Устанавливается соединение с базой данных...")
        connection = psycopg2.connect(
            dbname="Volleyball",
            user="postgres",
            password="28032005",
            host="localhost",
        )
        print("Соединение с базой данных успешно установлено.")
        return connection
    except Exception as e:
        print(f"Ошибка при подключении к базе данных: {e}")
        raise
