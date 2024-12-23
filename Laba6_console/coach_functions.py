from db_config import get_connection
import psycopg2


def get_current_time(cursor):
    """Возвращает текущее время из базы данных."""
    cursor.execute("SELECT NOW();")
    return cursor.fetchone()[0]

def get_tables(cursor):
    """Возвращает список таблиц в базе данных."""
    cursor.execute("""
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public';
    """)
    return [table[0] for table in cursor.fetchall()]

def execute_custom_query(query, cursor):
    """Выполняет произвольный SQL-запрос."""
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        print("Результат запроса:")
        for row in result:
            print(row)
    except Exception as e:
        print(f"Ошибка при выполнении запроса: {e}")




def  create_team(cursor, coach_id):
    # 1. Ввод названия команды
    team_name = input("Введите название команды: ")

    # 2. Проверка уникальности названия команды с помощью процедуры add_team
    try:
        cursor.execute("CALL add_team(%s, %s);", (team_name, coach_id))
        cursor.connection.commit()
        print(f"Команда '{team_name}' успешно создана!")
    except psycopg2.errors.UniqueViolation:
        print(f"Ошибка: Команда с именем '{team_name}' уже существует.")
        return  # Завершаем создание, если команда уже есть

    # 3. Получаем ID только что созданной команды
    cursor.execute("SELECT id FROM Team WHERE name = %s;", (team_name,))
    team_id = cursor.fetchone()[0]
    
    # 4. Добавление игроков
    while True:
        print("\nДобавление игрока в команду.")
        
        # Ввод данных игрока
        player_email = input("Введите email игрока: ")
        cursor.execute("SELECT id FROM \"User\" WHERE email = %s;", (player_email,))
        player = cursor.fetchone()

        if player is None:
            print("Ошибка: Игрок с таким email не найден.")
            continue
        
        player_id = player[0]

        first_name = input("Введите имя игрока: ")
        last_name = input("Введите фамилию игрока: ")
        position = input("Введите позицию игрока: ")
        jersey_number = int(input("Введите номер футболки игрока: "))

        # 5. Добавляем игрока с помощью процедуры add_player
        try:
            cursor.execute("CALL add_player(%s, %s, %s, %s);", (player_id, team_id, position, jersey_number))
            cursor.connection.commit()
            print(f"Игрок {first_name} {last_name} добавлен в команду.")
        except psycopg2.errors.ForeignKeyViolation:
            print("Ошибка: Этот игрок не может быть добавлен в команду.")
        except psycopg2.errors.CheckViolation:
            print(f"Ошибка: Номер футболки {jersey_number} уже занят.")
        
        # 6. Запрос на добавление еще одного игрока или завершение
        another = input("Хотите добавить еще одного игрока? (да/нет): ").strip().lower()
        if another != 'да':
            break

    print("Завершение создания команды.")


def view_team(cursor, user_id):
    """Просмотр команд тренером и их состава."""
    # Запросим все команды тренера по coach_id
    cursor.execute("""
        SELECT t.id, t.name
        FROM Team t
        WHERE t.coach_id = %s;
    """, (user_id,))
    
    teams = cursor.fetchall()
    
    if not teams:
        print("У вас нет команд.")
        return
    
    print("Ваши команды:")
    for idx, team in enumerate(teams, start=1):
        print(f"{idx}. {team[1]}")  # Показываем только название команды
    
    # Тренер выбирает команду для просмотра
    try:
        team_choice = int(input("Выберите номер команды для просмотра: "))
        if team_choice < 1 or team_choice > len(teams):
            print("Некорректный выбор.")
            return
    except ValueError:
        print("Некорректный ввод.")
        return
    
    team_id, team_name = teams[team_choice - 1]
    print(f"\nКоманда: {team_name}")
    
    # Запросим игроков выбранной команды, включая их имена и фамилии из UserProfile
    cursor.execute("""
        SELECT u.name, u.surname, p.position, p.jersey_number
        FROM Player p
        JOIN UserProfile u ON p.user_id = u.user_id
        WHERE p.team_id = %s;
    """, (team_id,))
    
    players = cursor.fetchall()
    
    if not players:
        print("В команде нет игроков.")
        return
    
    print("Состав команды:")
    for player in players:
        first_name, last_name, position, jersey_number = player
        print(f"{first_name} {last_name} - Позиция: {position}, Номер: {jersey_number}")


def update_team(cursor, user_id):
    """Изменение команды тренером (переименовать и добавить игроков)."""
    # Найдем все команды, к которым имеет доступ тренер
    cursor.execute("""
        SELECT t.id, t.name
        FROM Team t
        WHERE t.coach_id = %s;
    """, (user_id,))
    
    teams = cursor.fetchall()
    
    if not teams:
        print("У вас нет команд.")
        return
    
    # Выводим список команд
    print("Ваши команды:")
    for idx, team in enumerate(teams, start=1):
        print(f"{idx}. {team[1]}")  # Показываем только название команды
    
    # Тренер выбирает команду
    team_choice = int(input("Выберите номер команды для изменения: "))
    if team_choice < 1 or team_choice > len(teams):
        print("Некорректный выбор.")
        return
    
    team_id, current_team_name = teams[team_choice - 1]
    print(f"Вы выбрали команду: {current_team_name}")
    
    # Запрашиваем новое название команды
    new_team_name = input("Введите новое название команды: ")
    
    # Обновляем название команды в таблице Team
    cursor.execute("""
        UPDATE Team
        SET name = %s, updated_at = NOW()
        WHERE id = %s;
    """, (new_team_name, team_id))
    cursor.connection.commit()

    print(f"Название команды обновлено с '{current_team_name}' на '{new_team_name}'.")

    # Добавление новых игроков в команду
    add_more_players = input("Хотите добавить игроков в команду? (да/нет): ").strip().lower()
    
    if add_more_players == 'да':
        while True:
            email = input("Введите email игрока: ")
            position = input("Введите позицию игрока: ")
            jersey_number = int(input("Введите номер игрока: "))

            # Проверим, существует ли игрок с таким email
            cursor.execute("""
                SELECT id FROM "User" WHERE email = %s;
            """, (email,))
            
            user = cursor.fetchone()
            if user:
                user_id = user[0]

                # Проверим, не состоит ли уже этот игрок в команде
                cursor.execute("""
                    SELECT COUNT(*) FROM Player WHERE user_id = %s;
                """, (user_id,))
                count = cursor.fetchone()[0]
                
                if count > 0:
                    print(f"Игрок с email {email} уже состоит в другой команде.")
                    continue
                
                # Добавляем игрока в команду
                cursor.execute("""
                    INSERT INTO Player (user_id, team_id, position, jersey_number)
                    VALUES (%s, %s, %s, %s);
                """, (user_id, team_id, position, jersey_number))
                cursor.connection.commit()
                print(f"Игрок {email} добавлен в команду.")
                
            else:
                print("Игрок с таким email не найден.")
            
            add_more = input("Хотите добавить еще одного игрока? (да/нет): ").strip().lower()
            if add_more != 'да':
                break


def delete_team(cursor, user_id):
    """Удаляет команду тренера по ID."""
    try:
        # Получаем список всех команд тренера
        cursor.execute("""
            SELECT id, name
            FROM Team
            WHERE coach_id = %s
        """, (user_id,))
        teams = cursor.fetchall()

        if not teams:
            print("У вас нет команд для удаления.")
            return

        # Вывод списка команд
        print("Ваши команды:")
        for team in teams:
            print(f"ID: {team[0]}, Название: {team[1]}")

        # Ввод ID команды для удаления
        team_id = int(input("Введите ID команды для удаления: "))

        # Проверка, принадлежит ли команда тренеру
        if team_id not in [team[0] for team in teams]:
            print("Вы выбрали неверный ID команды.")
            return

        # Удаление команды
        cursor.execute("SELECT delete_team_by_coach(%s, %s)", (user_id, team_id))
        cursor.connection.commit()
        print(f"Команда с ID {team_id} успешно удалена.")
    except Exception as e:
        print(f"Ошибка при удалении команды: {e}")
