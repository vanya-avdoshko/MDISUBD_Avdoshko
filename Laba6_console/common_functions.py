def view_top_players(cursor):
    """Отображает топ-10 игроков по очкам для выбранного турнира."""
    tournament_id = input("Введите ID турнира: ")
    try:
        cursor.execute("SELECT * FROM get_top_players_by_tournament(%s);", (tournament_id,))
        players = cursor.fetchall()
        
        if not players:
            print("Для данного турнира нет данных.")
        else:
            print("\nТоп-10 игроков турнира:")
            print(f"{'Игрок':<25} {'Команда':<15} {'Очки':<10}")
            print("-" * 50)
            for player_name, team_name, total_points in players:
                print(f"{player_name:<25} {team_name:<15} {total_points:<10}")
    except Exception as e:
        print(f"Ошибка при получении данных: {e}")
