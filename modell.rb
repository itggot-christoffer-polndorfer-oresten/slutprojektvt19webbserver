require'sqlite3'
require'byebug'
require'BCrypt'

module Meme_vault

    #Connects to database
    #
    # @return [Hash]
    def connect_to_database
        db = SQLite3::Database.new("Database/database.db")
        db.results_as_hash = true
        return db
    end 

    # Selects ALL from the memes table
    #
    # @return [Hash] 
    #   * :Memeid [Integer] The ID of the meme
    #   * :MemeImgPath [String] The path to the image
    #   * :MemeAutherId [Integer] The authers ID
    #   * :TagId [Integer] The ID of the tag
    def memes()
        db = connect_to_database()
        return db.execute("SELECT * FROM memes ORDER BY MemeId DESC")
    end 

    # Attempts to insert several rows into memes and memes_tags
    #
    # @param [File] img, The mage file
    # @param [String] imgname, The Image name
    # @param [Integer] autherid, The auther id
    # @param [String] memetag1, The first memetag 
    # @param [String] memetag2, The second memetag
    # @param [String] memetag3, The third memetag
    def upload_meme(img, imgname, autherid, memetag1, memetag2, memetag3)
        db = connect_to_database()
        if imgname.include?(".png") or imgname.include?(".jpg") or imgname.include?(".jpeg")
            newname = SecureRandom.hex(10) + "." + /(.*)\.(jpg|bmp|png|jpeg)$/.match(imgname)[2]
            File.open("public/img/#{newname}", 'wb') do |f|
                f.write(img.read)
            end
            db.execute("INSERT INTO memes (MemeImgPath, MemeAutherId) VALUES (?,?)", newname, autherid)
            meme_id = db.last_insert_row_id
            db.execute("INSERT INTO memes_tags (MemeId, TagId) VALUES (?, ?)", [meme_id, memetag1])
            db.execute("INSERT INTO memes_tags (MemeId, TagId) VALUES (?, ?)", [meme_id, memetag2])
            db.execute("INSERT INTO memes_tags (MemeId, TagId) VALUES (?, ?)", [meme_id, memetag3])
            return true
        else 
            return false 
        end 
    end 

    # Attempts to delete a row in the memes table
    #
    # @param [Integer] memeid, The id of the meme
    def delete_meme(memeid) 
        db = connect_to_database()
        db.execute("DELETE FROM memes WHERE MemeId = ?", memeid) 
        
    end

    # Selects ALL from the tags table
    #
    # return [Hash]
    def get_tags()
        db = connect_to_database()
        return db.execute("SELECT * FROM tags")
    end

    # Attempts to insert a new row in the tags table
    #
    # @param [String] new_tag, The new tag
    def add_tag(new_tag)
        db = connect_to_database()
        db.execute("INSERT INTO tags (Tag) VALUES (?)", new_tag.downcase)
    end 

    # Searches for tag and checks if tag alreadye exists
    #
    # @param [String] new_tag, The new tag
    #
    # @return [true] if tag exists
    # @return [false] if tag doesn't exist
    def check_tag(new_tag)
        db = connect_to_database()
        if db.execute("SELECT * FROM tags WHERE Tag = ?", new_tag.downcase) != []
            return true 
        else 
            return false 
        end 
    end 
    
    # Encrypts and attempts to insert a row into the users table
    # 
    # @param [String] username, The username
    # @param [String] password, The password
    def encrypt_password(username, password)
        db = connect_to_database()
        hashed_password = BCrypt::Password.create(password)
        db.execute("INSERT INTO users(Username, Password) VALUES(?, ?)", username, hashed_password)
    end 

    # Searches the users table for matching credentials
    #
    # @param [String] params_username, The username
    # @param [String] params_password, The password
    # 
    # @return [true] if credentials match
    # @return [false] if credentials doesn't match
    def login_verification(params_username, params_password) 
        db = connect_to_database()
        database_info = db.execute("SELECT Username, Password, UserId FROM users WHERE users.Username = ?", params_username)
        if database_info.length > 0 && BCrypt::Password.new(database_info.first["Password"]) == params_password
            return true 
        else
            return false
        end
    end 

    # Selects session id 
    #
    # @param [String] params_username, The username
    #
    # @return [Integer] The session ID of the user
    def select_session_id(params_username)
        db = connect_to_database()
        return db.execute("SELECT UserId FROM users WHERE users.Username = ?", params_username)
    end 

    # Searches for images with a matching tag
    #
    # @param [String] searched_tag, The searched tag
    #
    # @return [Hash]
    #   * :Memeid [Integer] The ID of the meme
    #   * :MemeImgPath [String] The path to the image
    #   * :MemeAutherId [Integer] The authers ID
    #   * :TagId [Integer] The ID of the tag
    def search(searched_tag)
        db = connect_to_database()
        db.results_as_hash = true
        tag_id = db.execute("SELECT Id FROM tags WHERE Tag =?", searched_tag.downcase) 
        return db.execute("SELECT * FROM memes INNER JOIN memes_tags ON memes_tags.MemeId = memes.MemeId WHERE TagId =? ORDER BY MemeId DESC", tag_id.first["Id"]) 
    end 

    # Selects the auther id from the meme id 
    #
    # @param [Integer] memeid, The meme ID
    #
    # @return [Integer] The auther ID of the meme
    def match_id(memeid)
        db = connect_to_database()
        return db.execute("SELECT MemeAutherId FROM memes WHERE MemeId = ?", memeid).first["MemeAutherId"]
    end 

    # Checks if both passwords match
    #
    # @param [Hash]
    #   * :Username [String] The username of the vault
    #   * :Password [String] The password of the vault
    #   * :Confirmed_passwpord [String] The confirmed password
    #
    # @return [True] if passwords match
    # @retun [False] if passwords doesn't match
    def matching_passwords(params)
        if params["Passwprd"] == params["Confirmed_password"]
            return true 
        else 
            return false
        end 
    end 

    # Checks if the create vault forms are empty
    #
    # @param [Hash]
    #   * :Username [String] The username of the vault
    #   * :Password [String] The password of the vault
    #   * :Confirmed_passwpord [String] The confirmed password
    #
    # @return [True] if both inputs are correct
    # @retun [False] if one or more inputs are empty
    def creating_vault_validation_length(params)
        if params["Username"].length > 0 and params["Password"].length > 0
            return true
        else 
            return false
        end 
    end 

    # Checks if inputs only contain spaces
    #
    # @param [Hash]
    #   * :Username [String] The username of the vault
    #   * :Password [String] THe password of the vault
    #   * :Confirmed_passwpord [String] The confirmed password
    #
    # @return [True] if both inputs are correct
    # @retun [False] if one or more inputs only contains spaces
    def creating_vault_validation_spaces(params)
        if params["Username"].strip.empty? != true and params["Password"].strip.empty? != true
            return true 
        else 
            return false
        end 
    end 

end 