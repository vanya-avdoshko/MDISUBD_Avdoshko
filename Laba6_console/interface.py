from admin_functions import add_coach, create_match, create_tournament, update_player_match_statistics
from auth import get_user_role
from coach_functions import create_team, delete_team, update_team, view_team
from common_functions import view_top_players
from player_functions import view_match_statistics, view_player_statistics, view_teammates_statistics


def show_menu(user_logged_in, role_id):
    """Показывает меню в зависимости от роли пользователя."""
    if not user_logged_in:
        print("\nМеню:")
        print("1. Регистрация")
        print("2. Вход")
        print("3. Просмотр топ-10 игроков турнира") 
        print("0. Выход")
    else:
        print("\nМеню для авторизованного пользователя:")
        
        if role_id == 1:
            print("1. Добавить тренера")
            print("2. Добавить турнир")
            print("3. Создать матч")
            print("4. Изменить статистику матча")
        elif role_id == 2:
            print("1. Добавить команду")
            print("2. Просмотреть свою команду")
            print("3. Изменить команду")
            print("4. Удалить команду")
        elif role_id == 3:
            print("1. Просмотр своей статистики")
            print("2. Просмотр своей статистики за матч")
            print("3. Просмотр статистики своей команды")
        else:
            print("Неизвестная роль, доступных опций нет.")
            
        print("0. Выйти из аккаунта")


def handle_user_choice(choice, cursor, user_logged_in, role_id, user_id):
    """Обрабатывает выбор пользователя для различных ролей."""
    from auth import register_user, login_user

    if not user_logged_in:
        if choice == "1":
            email = input("Введите email: ")
            password = input("Введите пароль: ")
            first_name = input("Введите имя: ")
            last_name = input("Введите фамилию: ")
            if not register_user(cursor, email, password, first_name, last_name):
                print("Регистрация не удалась.")
        elif choice == "2":
            email = input("Введите email: ")
            password = input("Введите пароль: ")
            # Теперь login_user возвращает user_id и role_id
            success, user_id, role_id = login_user(cursor, email, password)
            if success:
                user_logged_in = True  # Пользователь авторизован        
            else:
                print("Ошибка при авторизации.")
        elif choice == "3":
            view_top_players(cursor)
        elif choice == "0":
            print("Выход из программы.")
            return False, user_logged_in, role_id, user_id  # Выход из программы
        else:
            print("Некорректный выбор.")
    else:
        # Обработка выхода из аккаунта
        if choice == "0":
            print("Вы вышли из аккаунта.")
            return True, False, None, None  # Сбрасываем авторизацию и возвращаем в главное меню
        
        # Меню для авторизованного пользователя в зависимости от его роли
        if role_id == 1:
            if choice == "1":
                add_coach(cursor)
            elif choice == "2":
                create_tournament(cursor) 
            elif choice == "3":
                create_match(cursor)
            elif choice == "4":
                update_player_match_statistics(cursor)
            else:
                print("Некорректный выбор.")
        elif role_id == 2:
            if choice == "1":
               create_team(cursor, user_id)  # Передаем user_id в функцию создания команды
            elif choice == "2":
                view_team(cursor, user_id)
            elif choice == "3":
                update_team(cursor, user_id)
            elif choice == "4":
                delete_team(cursor, user_id)
            else:
                print("Некорректный выбор.")
        elif role_id == 3:
            if choice == "1":
                view_player_statistics(cursor, user_id)
            elif choice == "2":
                view_match_statistics(cursor, user_id)
            elif choice == "3":
                view_teammates_statistics(cursor, user_id)
            else:
                print("Некорректный выбор.")
    
    return True, user_logged_in, role_id, user_id  # Возвращаем обновленные значения
