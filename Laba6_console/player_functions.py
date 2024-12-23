def view_player_statistics(cursor, user_id):
    """Вывод статистики игрока."""
    # Проверка, является ли пользователь игроком
    cursor.execute("""
        SELECT id
        FROM Player
        WHERE user_id = %s;
    """, (user_id,))
    
    player = cursor.fetchone()
    
    if not player:
        print("Вы не являетесь игроком.")
        return
    
    player_id = player[0]

    # Запрос статистики игрока
    cursor.execute("""
        SELECT matches_played, points, assists, blocks, aces, attacks
        FROM PlayerStatistics
        WHERE player_id = %s;
    """, (player_id,))
    
    stats = cursor.fetchone()

    if not stats:
        print("Статистика для данного игрока отсутствует.")
        return
    
    # Распаковка данных статистики
    matches_played, points, assists, blocks, aces, attacks = stats
    
    # Вывод статистики игрока
    print("Статистика игрока:")
    print(f"Матчи сыграно: {matches_played}")
    print(f"Очки: {points}")
    print(f"Передачи: {assists}")
    print(f"Блоки: {blocks}")
    print(f"Айсы: {aces}")
    print(f"Атаки: {attacks}")


def view_match_statistics(cursor, user_id):
    """Просмотр статистики игрока за матч."""
    # Проверка, является ли пользователь игроком
    cursor.execute("""
        SELECT id, team_id
        FROM Player
        WHERE user_id = %s;
    """, (user_id,))
    
    player = cursor.fetchone()
    
    if not player:
        print("Вы не являетесь игроком.")
        return
    
    player_id, team_id = player

    # Получение списка матчей команды
    cursor.execute("""
        SELECT m.id, t.name AS tournament_name, m.date, ht.name AS home_team, at.name AS away_team
        FROM Match m
        JOIN Tournament t ON m.tournament_id = t.id
        JOIN Team ht ON m.home_team_id = ht.id
        JOIN Team at ON m.away_team_id = at.id
        WHERE m.home_team_id = %s OR m.away_team_id = %s
        ORDER BY m.date;
    """, (team_id, team_id))
    
    matches = cursor.fetchall()
    
    if not matches:
        print("Ваша команда не участвовала в матчах.")
        return

    # Вывод списка матчей
    print("Матчи вашей команды:")
    for i, (match_id, tournament_name, date, home_team, away_team) in enumerate(matches, start=1):
        print(f"{i}. {date} - {home_team} vs {away_team} ({tournament_name})")
    
    # Выбор матча
    try:
        choice = int(input("Введите номер матча, чтобы посмотреть статистику: ")) - 1
        if choice < 0 or choice >= len(matches):
            print("Неверный выбор.")
            return
    except ValueError:
        print("Некорректный ввод.")
        return
    
    match_id = matches[choice][0]

    # Получение статистики игрока за выбранный матч
    cursor.execute("""
        SELECT points, assists, blocks, aces, attacks
        FROM PlayerMatch
        WHERE player_id = %s AND match_id = %s;
    """, (player_id, match_id))
    
    stats = cursor.fetchone()

    if not stats:
        print("Статистика для выбранного матча отсутствует.")
        return
    
    # Распаковка данных статистики
    points, assists, blocks, aces, attacks = stats
    
    # Вывод статистики игрока за матч
    print("Статистика за матч:")
    print(f"Очки: {points}")
    print(f"Передачи: {assists}")
    print(f"Блоки: {blocks}")
    print(f"Айсы: {aces}")
    print(f"Атаки: {attacks}")



def view_teammates_statistics(cursor, user_id):
    """Просмотр статистики всех одноклубников игрока."""
    # Проверка, является ли пользователь игроком
    cursor.execute("""
        SELECT team_id
        FROM Player
        WHERE user_id = %s;
    """, (user_id,))
    
    player = cursor.fetchone()
    
    if not player:
        print("Вы не являетесь игроком.")
        return
    
    team_id = player[0]
    
    # Вызов функции для получения статистики
    cursor.execute("""
        SELECT * FROM get_team_players_with_stats(%s);
    """, (team_id,))
    
    teammates_stats = cursor.fetchall()
    
    # Вывод статистики
    print("Статистика всех игроков вашей команды:")
    for stat in teammates_stats:
        player_id, jersey_number, player_name, player_surname, matches_played, points, assists, blocks, aces, attacks = stat
        print(f"ID: {player_id}, Номер: {jersey_number}, {player_name} {player_surname} - "
              f"Матчи: {matches_played}, Очки: {points}, Пасы: {assists}, "
              f"Блоки: {blocks}, Эйсы: {aces}, Атаки: {attacks}")
