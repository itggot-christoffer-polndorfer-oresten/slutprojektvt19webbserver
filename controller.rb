require'sqlite3'
require'slim'
require'sinatra'
require 'sinatra/flash'
require'byebug'
require'BCrypt'
require 'rack-flash'
require_relative 'modell.rb'
# require'sinatra/param'
enable :sessions
include Meme_vault 


# Displays Landing Page and a login form
#
get('/') do 
    slim(:login)
end 

# Attepmts login and updates the session
# 
# @param [String] username, The username
# @param [String] password, The password
#
# @see Meme_vault#login_verification
# @see Meme_vault#select_session_id
post('/login') do 
    if login_verification(params["Username"], params["Password"]) == true
        session[:id] = select_session_id(params["Username"])[0]["UserId"]
        session[:logged_in?] = true
        redirect('/vault')
    else 
        flash[:error] = "Wrong usernamer or password!"
            redirect back
        redirect('/')
    end 
end 

# Displays a create vault form
#
get('/create_vault') do 
    slim(:create_vault)
end 

# Attempts to create a new vault and redirects to '/vault'
#
# @param [Hash]
#   * :Username [String] The username of the vault
#   * :Password [String] The password of the vault
#   * :Confirmed_passwpord [String] The confirmed password
# 
# @see Meme_vault#connect_to_db
# @see Meme_vault#encrypt_password
post('/creating_vault') do 
    if creating_vault_validation_length(params) == true
        if creating_vault_validation_spaces(params) == true
            if matching_passwords(params) == true
                db = connect_to_database()
                encrypt_password(params["Username"], params["Password"])
                session[:name] = params["Username"]
                redirect('/vault')
            else
                flash[:incorrect_passwords] = "Passwords does not match!"
                redirect back
            end 
        else 
            flash[:account_error] = "Please enter a username or password which does not only contain spaces!"
            redirect back
        end 
    else 
        flash[:account_warning] = "Please enter ALL information!"
        redirect back
    end 
end 

# Displays all memes
#
# @see Meme_vault#memes
get('/vault') do 
    if session[:logged_in?] == true 
        meme = memes()
        sessionid = session[:id]
        slim(:vault, locals:{meme: meme, sessionid: sessionid})
    else 
        redirect('/')
    end 
end 

# Logouts and destroys the session
#
post('/locking_vault') do 
    session.destroy
    redirect('/')
end 

# Displays a form for uploading memes
#
# @see Meme_vault#get_tags
get('/upload_meme') do 
    if session[:logged_in?] == true 
        tags = get_tags()
        slim(:upload_meme, locals:{tags: tags})
    else
        redirect('/')
    end 
end 

# Attempts to add a tag and redirects to '/upload_meme'
#
# @param [String] tag, The new tag
# 
# @see Meme_vault#check_tag
# @see Meme_vault#add_tag
post('/add_tag') do 
    if params["new_tag"].length > 0 and 
        # check_space = params["new_tag"] =~ /\A\s*\Z/
        if params["new_tag"].strip.empty? == false
            if check_tag(params["new_tag"]) != true
                add_tag(params["new_tag"])
                redirect('/upload_meme')
            else 
                flash[:notice] = "Tag already exists!"
                redirect back
            end 
        else 
            flash[:no_text] = "Please enter a tag with letters!"
            redirect back
        end 
    else  
        flash[:warning] = "Please enter a tag!"
        redirect back
    end 
end 

# Uploads a new meme and redirects to '/vault'
#
# @param [File] img, The image file
# @param [String] imgname, The image name
# @param (String) memetag1, The first tag
# @param (String) memetag2, The second tag
# @param (String) memetag3, The thrid tag
#
# @see Meme_vault#upload_meme
post('/uploading_meme') do 
    img = params[:img][:tempfile]
    imgname = params[:img][:filename]
    autherid = session[:id]
    memetag1 = params[:MemeTag1]
    memetag2 =  params[:MemeTag2]
    memetag3 =  params[:MemeTag3]

    if upload_meme(img, imgname, autherid, memetag1, memetag2, memetag3) == false
        flash[:error] = "Wrong arguments!"
        redirect('/vault')
    end 
    redirect('/vault')
end 

# Deletes an existing meme and redirects to '/vault'
#
# @param [Integer] memeid, Meme Id
#
# @see Meme_vault#delete_meme
post('/delete_meme/:memeid') do
    if match_id(params["memeid"]) == session[:id]
        delete_meme(params["memeid"])
        redirect('/vault')
    else 
        redirect('/vault')
    end
end 

# Displays search result based on paramaters
#
get('/vault_search') do 
    if session[:logged_in?] == true
        sessionid = session[:id] 
        slim(:vault_search, locals:{tagged_memes: $tagged_memes, sessionid: sessionid})
    else
        redirect('/')
    end       
end 

# Displays a form for updating vault credentials
#
get('/edit_vault') do 
    if session[:logged_in?] == true
        slim(:edit_vault)
    end 
end 


post('/edeting_vault') do 
    update_vault_credentials(params, session[:id])
    

end 
# Retrieves tagged memes and redirects to '/vault_search'
#
# @see Meme_vault#check_tag
# @see Meme_vault#search
post('/searching') do   
    searched_tag = params["Search"]
    if searched_tag.length != 0
        if check_tag(searched_tag) == true
            $tagged_memes = search(searched_tag)
            redirect('/vault_search')
        else 
            flash[:notice] = "No such tag!"
            redirect('/vault')
        end 
    else 
        flash[:warning] = "Please enter search tag!"
        redirect('/vault')
    end 
end 
