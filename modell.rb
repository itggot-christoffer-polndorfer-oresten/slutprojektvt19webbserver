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

def get_tag_by_id(id)
    db = connect_to_database()
    return db.execute("SELECT Tag FROM tags WHERE Id =?", id)
end 

def upload_meme(img, imgname, autherid, memetag1, memetag2, memetag3)
    db = connect_to_database()
    if imgname.include?(".png") or imgname.include?(".jpg") or imgname.include?(".jpeg")
        newname = SecureRandom.hex(10) + "." + /(.*)\.(jpg|bmp|png|jpeg)$/.match(imgname)[2]
        File.open("public/img/#{newname}", 'wb') do |f|
            f.write(img.read)
        end
    end 
    db.execute("INSERT INTO memes (MemeImgPath, MemeAutherId, MemeTag1, MemeTag2, MemeTag3) VALUES (?,?,?,?,?)", newname, autherid, memetag1, memetag2, memetag3)
end 

def delete_meme(memeid)
    db = connect_to_database()
    db.execute("DELETE FROM memes WHERE MemeId = ?", memeid)

end


def search(search_input)
    tags = get_tags()
    tags.each_with_index do |element, i|
        if search_input == tags[i]["Tag"]
            byebug
            return true
        else
            return nil
        end 
    end 



end 


def get_tagged_memes(tag)
    db = connect_to_database()
    tag_id = db.execute("SELECT Id FROM tags WHERE Tag = ?", tag)
    db.execute("SELECT * FROM memes WHERE ")


end 