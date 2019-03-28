require'sqlite3'
require'byebug'
require'BCrypt'


def open_link_to_db
    db = SQLite3::Database.new("Database/database.db")
    db.results_as_hash = true
    return db
end 

def reg_password_verification(password)
    db = SQLite3::Database.new("Database/database.db")
    db.results_as_hash = true
    reg_pw = db.execute("SELECT RegisterPassword FROM secrets")
    byebug
    if password == reg_pw
        return true 
    end 
end 

# def login_verification(params)
#     db = open_link_to_db()
#     lol = db.execute("SELECT UserId FROM users WHERE UserPassword =? ", params)
#     return lol
# end 

# BCrypt::Password.create(params["password"])

