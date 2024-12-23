from datetime import datetime


def add_coach(cursor):
    """Добавление тренера администратором."""
    email = input("Введите email пользователя, которого хотите назначить тренером: ")
    
    # Проверка существования пользователя и его роли
    cursor.execute("""
        SELECT id, role_id
        FROM "User"
        WHERE email = %s;
    """, (email,))
    user = cursor.fetchone()
    
    if not user:
        print("Пользователь с таким email не найден.")
        return
    
    user_id, role_id = user
    
    # Проверяем, что пользователь имеет роль 3 (обычный пользователь)
    if role_id != 3:
        print("Пользователь не может быть назначен тренером, так как его роль не подходит.")
        return
    
    # Проверяем, что пользователь не является игроком
    cursor.execute("""
        SELECT COUNT(*)
        FROM Player
        WHERE user_id = %s;
    """, (user_id,))
    is_player = cursor.fetchone()[0]
    
    if is_player > 0:
        print("Пользователь не может быть назначен тренером, так как он является игроком.")
        return
    
    # Обновляем роль пользователя на тренера (role_id = 2)
    cursor.execute("""
        UPDATE "User"
        SET role_id = 2
        WHERE id = %s;
    """, (user_id,))
    cursor.connection.commit()
    
    print("Пользователь успешно назначен тренером.")


def create_tournament(cursor):
    """Функция для создания нового турнира."""
    print("Создание нового турнира")

    # Запрос данных от пользователя
    name = input("Введите название турнира: ").strip()
    category = input("Введите категорию турнира: ").strip()
    start_date = input("Введите дату начала (в формате YYYY-MM-DD): ").strip()
    end_date = input("Введите дату окончания (в формате YYYY-MM-DD): ").strip()

    # Проверка корректности введённых данных
    if not name:
        print("Название турнира не может быть пустым.")
        return
    
    if not category:
        print("Категория турнира не может быть пустой.")
        return
    
    try:
        start_date_parsed = datetime.strptime(start_date, "%Y-%m-%d").date()
        end_date_parsed = datetime.strptime(end_date, "%Y-%m-%d").date()
        if start_date_parsed > end_date_parsed:
            print("Дата начала не может быть позже даты окончания.")
            return
    except ValueError:
        print("Некорректный формат даты. Попробуйте ещё раз.")
        return

    # Вставка данных в базу
    try:
        cursor.execute("""
            INSERT INTO Tournament (name, category, start_date, end_date)
            VALUES (%s, %s, %s, %s);
        """, (name, category, start_date, end_date))
        
        # Сохранение изменений
        cursor.connection.commit()
        print(f"Турнир '{name}' успешно создан.")
    except Exception as e:
        print(f"Ошибка при создании турнира: {e}")
        cursor.connection.rollback()


def create_match(cursor):
    """Создание нового матча."""
    print("Создание нового матча")

    # 1. Выбор турнира
    print("Выберите турнир:")
    cursor.execute("SELECT id, name FROM Tournament;")
    tournaments = cursor.fetchall()
    
    if not tournaments:
        print("Нет доступных турниров для выбора.")
        return
    
    for tournament in tournaments:
        print(f"{tournament[0]}. {tournament[1]}")

    try:
        tournament_id = int(input("Введите ID турнира: ").strip())
        if not any(t[0] == tournament_id for t in tournaments):
            print("Неверный ID турнира.")
            return
    except ValueError:
        print("ID турнира должен быть числом.")
        return

    # 2. Выбор домашней команды
    print("Выберите домашнюю команду:")
    cursor.execute("SELECT id, name FROM Team;")
    teams = cursor.fetchall()
    
    if not teams:
        print("Нет доступных команд для выбора.")
        return

    for team in teams:
        print(f"{team[0]}. {team[1]}")

    try:
        home_team_id = int(input("Введите ID домашней команды: ").strip())
        if not any(t[0] == home_team_id for t in teams):
            print("Неверный ID команды.")
            return
    except ValueError:
        print("ID команды должен быть числом.")
        return

    # 3. Выбор гостевой команды
    print("Выберите гостевую команду:")
    for team in teams:
        if team[0] != home_team_id:  # Исключаем уже выбранную команду
            print(f"{team[0]}. {team[1]}")

    try:
        away_team_id = int(input("Введите ID гостевой команды: ").strip())
        if not any(t[0] == away_team_id for t in teams) or away_team_id == home_team_id:
            print("Неверный ID команды или совпадает с домашней.")
            return
    except ValueError:
        print("ID команды должен быть числом.")
        return

    # 4. Ввод результата
    result = input("Введите результат матча (например, 3:2): ").strip()
    if not result:
        print("Результат не может быть пустым.")
        return

    # 5. Ввод даты
    date = input("Введите дату и время матча (в формате YYYY-MM-DD HH:MM:SS): ").strip()
    try:
        datetime.strptime(date, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        print("Некорректный формат даты.")
        return

    # 6. Вставка данных в таблицу Match
    try:
        cursor.execute("""
            INSERT INTO Match (home_team_id, away_team_id, tournament_id, date, result)
            VALUES (%s, %s, %s, %s, %s);
        """, (home_team_id, away_team_id, tournament_id, date, result))
        
        cursor.connection.commit()
        print("Матч успешно создан.")
    except Exception as e:
        print(f"Ошибка при создании матча: {e}")
        cursor.connection.rollback()


def update_player_match_statistics(cursor):
    """Редактирование статистики игрока в матче."""

    # Выбор турнира
    cursor.execute("SELECT id, name FROM Tournament;")
    tournaments = cursor.fetchall()
    if not tournaments:
        print("Нет доступных турниров.")
        return
    
    print("Доступные турниры:")
    for idx, (t_id, t_name) in enumerate(tournaments, 1):
        print(f"{idx}. {t_name}")
    
    tournament_idx = int(input("Выберите турнир: ")) - 1
    tournament_id = tournaments[tournament_idx][0]

    # Выбор матча
    cursor.execute("""
        SELECT id, home_team_id, away_team_id, date
        FROM Match
        WHERE tournament_id = %s;
    """, (tournament_id,))
    matches = cursor.fetchall()
    if not matches:
        print("Нет доступных матчей в выбранном турнире.")
        return
    
    print("Доступные матчи:")
    for idx, (m_id, home_team, away_team, date) in enumerate(matches, 1):
        print(f"{idx}. Матч ID {m_id}: {home_team} vs {away_team} - {date}")
    
    match_idx = int(input("Выберите матч: ")) - 1
    match_id = matches[match_idx][0]

    # Выбор игрока
    cursor.execute("""
        SELECT p.id, u.name, u.surname, p.jersey_number, t.name
        FROM Player p
        JOIN UserProfile u ON p.user_id = u.user_id
        JOIN Team t ON p.team_id = t.id
        WHERE p.team_id IN (
            SELECT home_team_id FROM Match WHERE id = %s
            UNION
            SELECT away_team_id FROM Match WHERE id = %s
        );
    """, (match_id, match_id))
    players = cursor.fetchall()
    if not players:
        print("Нет доступных игроков.")
        return

    print("Доступные игроки:")
    for idx, (p_id, first_name, last_name, jersey, team_name) in enumerate(players, 1):
        print(f"{idx}. {first_name} {last_name} (№{jersey}) - {team_name}")
    
    player_idx = int(input("Выберите игрока: ")) - 1
    player_id = players[player_idx][0]

    # Ввод новой статистики
    print("Введите новую статистику игрока:")
    new_attacks = int(input("Атаки: "))
    new_aces = int(input("Эйсы: "))
    new_blocks = int(input("Блоки: "))
    new_assists = int(input("Пасы: "))

    # Обновление данных в PlayerMatch
    cursor.execute("""
        INSERT INTO PlayerMatch (player_id, match_id, attacks, aces, blocks, assists)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (player_id, match_id)
        DO UPDATE SET attacks = EXCLUDED.attacks,
                      aces = EXCLUDED.aces,
                      blocks = EXCLUDED.blocks,
                      assists = EXCLUDED.assists;
    """, (player_id, match_id, new_attacks, new_aces, new_blocks, new_assists))
    cursor.connection.commit()
    print("Статистика игрока успешно обновлена.")
