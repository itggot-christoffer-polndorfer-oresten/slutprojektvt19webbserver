require'sqlite3'
require'slim'
require'sinatra'
require 'sinatra/flash'
require'byebug'
require'BCrypt'
require 'rack-flash'
require_relative 'modell.rb'
enable :sessions


get('/') do 
    slim(:login)
end 

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

get('/create_vault') do 
    slim(:create_vault)
end 

post('/creating_vault') do 
    db = connect_to_database()
    # Kryptera lösen & lägg till i databas
    encrypt_password(params["Username"], params["Password"])
    session[:name] = params["Username"]
    redirect('/vault')
end 

get('/vault') do 
    if session[:logged_in?] == true 
        meme = memes()
        sessionid = session[:id]
        slim(:vault, locals:{meme: meme, sessionid: sessionid})
    else 
        redirect('/')
    end 
end 

post('/locking_vault') do 
    session.destroy
    redirect('/')
end 

get('/upload_meme') do 
    if session[:logged_in?] == true 
        tags = get_tags()
        slim(:upload_meme, locals:{tags: tags})
    else
        redirect('/')
    end 
end 

post('/add_tag') do 
    if params["new_tag"].length > 0
        if check_tag(params["new_tag"]) != true
            add_tag(params["new_tag"])
            redirect('/upload_meme')
        else 
            flash[:notice] = "Tag already exists!"
            redirect back
        end 
    else  
        flash[:warning] = "ENTER A TAG!"
        redirect back
    end 
end 

post('/uploading_meme') do 
    img = params[:img][:tempfile]
    imgname = params[:img][:filename]
    autherid = session[:id]
    memetag1 = params[:MemeTag1]
    memetag2 =  params[:MemeTag2]
    memetag3 =  params[:MemeTag3]
    
    upload_meme(img, imgname, autherid, memetag1, memetag2, memetag3)
    redirect('/vault')
end 

post('/delete_meme/:memeid') do
    delete_meme(params["memeid"])
    redirect('/vault')

end 

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
        flash[:warning] = "PLEASE ENTER A TAG!"
        redirect('/vault')
    end 
end 

get('/vault_search') do 
    if session[:logged_in?] == true
        sessionid = session[:id] 
        slim(:vault_search, locals:{tagged_memes: $tagged_memes, sessionid: sessionid})
    else
        redirect('/')
    end       
end 