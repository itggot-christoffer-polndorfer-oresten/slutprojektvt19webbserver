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
        # session[:name] = database_info[0]["Username"]
        # session[:id] = database_info[0]["UserId"]
        # session[:loggedin?] = true
        # verification = true 
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
    slim(:vault)
end 
