#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

get '/' do
    erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
    @error = "somephing wrong!"    # Пример вывода ошибки
    erb :about
end

get '/visit' do
    erb :visit
end

post '/visit' do

    @user_name = params[:user_name]
    @phone     = params[:phone]
    @date_time = params[:date_time]
    @barber    = params[:barber]
    @color     = params[:colorpicker]

    hh = {  :user_name => 'Введите имя ',
                :phone => 'Введите номер телефона ',
            :date_time => 'Введите дату и время ' }

    # Для каждой пары ключ-значение
    hh.each do |key, value|
        # если параметр пуст
        if params[key] == ''
            # переменной error присвоить союе value из хеша hh
            # т.е переменной error присвоить сообщение об ошибке
            @error = hh[key]
            return erb :visit
        end
    end

#    @error = hh.select {|key,_| params[key] == ""}.values.join(",")
#    return erb :visit if @error != ''
    
    @title = 'Спасибо!'
    @message = "Спасибо вам, #{@user_name}, будем ждать Вас."

    db = SQLite3::Database.new 'BarberShop.db'
    
        db.execute "INSERT INTO db_t_visit (user_name, phone, data_time, barber) VALUES ('#{@user_name}', '#{@phone}', '#{@date_time}', '#{@barber}')"
 
    db.close

    erb :message
end

get '/contacts' do
    erb :contacts
end


post '/contacts' do
    @user_name      = params[:user_name]
    @user_mail      = params[:user_mail]
    @message_user   = params[:message_user]

    hh = {  :user_name => 'Вы не указали имя ',
            :user_mail => 'Вы не указали адрес для ответа ',
            :message_user => 'Текст Вашего сообщения не найден ' }

    # Для каждой пары ключ-значение
    hh.each do |key, value|
        # если параметр пуст
        if params[key] == ''
            # переменной error присвоить союе value из хеша hh
            # т.е переменной error присвоить сообщение об ошибке
            @error = hh[key]
            return erb :contacts
        end
    end
    
    @title = 'Ваше обращение доставлено!'
    @message = "Спасибо за обращение. Если оно требует ответа, мы постараемся связаться с Вами в бижайшее время."

    db = SQLite3::Database.new 'BarberShop.db'
    
        db.execute "INSERT INTO db_t_contacts (user_name, user_mail, message_user) VALUES ('#{@user_name}', '#{@user_mail}', '#{@message_user}')"
 
    db.close

    erb :message
end


