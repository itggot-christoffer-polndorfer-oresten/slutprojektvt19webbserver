require'sqlite3'
require'slim'
require'sinatra'
require'byebug'
require'BCrypt'
require_relative "controller.rb"
enable :sessions

get('/') do 
slim(:login)
end 

post('/login') do 
    if reg_password_verification(params["password"]) == true
        redirect('/reg_acc')
    end 
        
redirect('/vault')
     
end 