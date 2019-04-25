require'sqlite3'
require'slim'
require'sinatra'
require'byebug'
require'BCrypt'
require_relative "modell.rb"
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
        slim(:upload_meme)
    else
        redirect('/')
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
