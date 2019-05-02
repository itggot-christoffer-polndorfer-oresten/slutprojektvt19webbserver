require'sqlite3'
require'byebug'
require'BCrypt'


def connect_to_database
    db = SQLite3::Database.new("Database/database.db")
    db.results_as_hash = true
    return db
end 

def memes()
    db = connect_to_database()
    return db.execute("SELECT * FROM memes ORDER BY MemeId DESC")
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
    else
        return false
    end
end 

def select_session_id(params_username)
    db = connect_to_database()
    return db.execute("SELECT UserId FROM users WHERE users.Username = ?", params_username)
end 

def get_tags()
    db = connect_to_database()
    return db.execute("SELECT * FROM tags")
end

def upload_meme(img, imgname, autherid, memetag1, memetag2, memetag3)
    db = connect_to_database()
    if imgname.include?(".png") or imgname.include?(".jpg") or imgname.include?(".jpeg")
        newname = SecureRandom.hex(10) + "." + /(.*)\.(jpg|bmp|png|jpeg)$/.match(imgname)[2]
        File.open("public/img/#{newname}", 'wb') do |f|
            f.write(img.read)
        end
    end 
    db.execute("INSERT INTO memes (MemeImgPath, MemeAutherId) VALUES (?,?)", newname, autherid)
    meme_id = db.last_insert_row_id
    db.execute("INSERT INTO memes_tags (MemeId, TagId) VALUES (?, ?)", [meme_id, memetag1])
    db.execute("INSERT INTO memes_tags (MemeId, TagId) VALUES (?, ?)", [meme_id, memetag2])
    db.execute("INSERT INTO memes_tags (MemeId, TagId) VALUES (?, ?)", [meme_id, memetag3])
end 

def add_tag(new_tag)
    db = connect_to_database()
    
    db.execute("INSERT INTO tags (Tag) VALUES (?)", new_tag.downcase)
end 

def check_tag(new_tag)
    
    db = connect_to_database()
    if db.execute("SELECT * FROM tags WHERE Tag = ?", new_tag.downcase) != []
        return true 
    else 
        return false 
    end 
end 

def delete_meme(memeid)
    db = connect_to_database()
    db.execute("DELETE FROM memes WHERE MemeId = ?", memeid)
end

def search(searched_tag)
    db = connect_to_database()
    db.results_as_hash = true
    
    tag_id = db.execute("SELECT Id FROM tags WHERE Tag =?", searched_tag.downcase) 
    return db.execute("SELECT * FROM memes INNER JOIN memes_tags ON memes_tags.MemeId = memes.MemeId WHERE TagId =? ORDER BY MemeId DESC", tag_id.first["Id"]) 
end 

def img_path_retriever(tagged_memes)
    db = connect_to_database()
    img_paths = db.execute("SELECT MemeImgPath FROM memes WHERE MemeId = ?", )
end 

