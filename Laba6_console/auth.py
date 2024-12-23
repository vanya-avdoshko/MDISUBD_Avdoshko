import hashlib

def hash_password(password):
    """Хеширование пароля для безопасности."""
    return hashlib.sha256(password.encode()).hexdigest()

def register_user(cursor, email, password, first_name, last_name):
    """Регистрация нового пользователя с проверкой на уникальность email."""
    cursor.execute("SELECT email FROM \"User\" WHERE email = %s;", (email,))
    existing_user = cursor.fetchone()
    
    if existing_user:
        print("Ошибка: Этот email уже зарегистрирован.")
        return False
    
    hashed_password = hash_password(password)
    role_id = 3
    
    try:
        cursor.execute("""
            INSERT INTO "User" (email, password, role_id)
            VALUES (%s, %s, %s) RETURNING id;
        """, (email, hashed_password, role_id))
        user_id = cursor.fetchone()[0]
        
        cursor.execute("""
            INSERT INTO UserProfile (user_id, name, surname)
            VALUES (%s, %s, %s);
        """, (user_id, first_name, last_name))
        
        cursor.connection.commit()  # Подтверждаем транзакцию
        print("Регистрация прошла успешно!")
        return True
    except Exception as e:
        cursor.connection.rollback()  # Откат транзакции в случае ошибки
        print(f"Ошибка при регистрации: {e}")
        return False


def login_user(cursor, email, password):
    """Логин пользователя с проверкой email и пароля."""
    hashed_password = hash_password(password)
    
    cursor.execute("""
        SELECT id, role_id FROM "User" WHERE email = %s AND password = %s;
    """, (email, hashed_password))
    user = cursor.fetchone()
    
    if user:
        user_id, role_id = user  # Получаем id и роль
        print("Авторизация успешна!")
        return True, user_id, role_id  # Возвращаем оба значения
    else:
        print("Ошибка: Неверный email или пароль.")
        return False, None, None  # Возвращаем None, если логин не удался

def get_user_role(cursor, email):
    """Получает роль пользователя по email."""
    cursor.execute("""SELECT role_id FROM "User" WHERE email = %s;""", (email,))
    role = cursor.fetchone()
    
    if role:
        return role[0]  # Возвращаем role_id
    else:
        return None  # Если пользователь не найден
