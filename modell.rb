require'sqlite3'
require'byebug'
require'BCrypt'


def connect_to_database
    db = SQLite3::Database.new("Database/database.db")
    db.results_as_hash = true
    return db
end 


def encrypt_password(username, password)
    db = connect_to_database()
    hashed_password = BCrypt::Password.create(password)
    db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", username, hashed_password)
end 

def login_verification(params_username, params_password) 
    db = connect_to_database()
    database_info = db.execute("SELECT Username, Password, UserId FROM users WHERE users.Username = ?", params_username)
    if database_info.length > 0 && BCrypt::Password.new(database_info.first["Password"]) == params_password
        return true 
        byebug
    else
        return false
    end

end 


