from db_config import get_connection
from interface import show_menu, handle_user_choice

def main():
    connection = None
    cursor = None
    user_logged_in = False  # Статус авторизации пользователя
    role_id = None  # Роль пользователя, будет обновляться после входа
    user_id = None  # ID пользователя, будет обновляться после входа
    
    try:
        print("Попытка подключения к базе данных...")
        connection = get_connection()
        print("Соединение установлено.")
        
        cursor = connection.cursor()
        print("Создан курсор для выполнения запросов.")
        
        # Основной цикл интерфейса
        running = True
        while running:
            show_menu(user_logged_in, role_id)
            choice = input("Введите ваш выбор: ")
            running, user_logged_in, role_id, user_id = handle_user_choice(choice, cursor, user_logged_in, role_id, user_id)
        
    except Exception as e:
        print(f"Ошибка: {e}")
    finally:
        if cursor:
            cursor.close()
            print("Курсор закрыт.")
        if connection:
            connection.close()
            print("Соединение закрыто.")

if __name__ == "__main__":
    main()
