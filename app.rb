#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def get_db
    db = SQLite3::Database.new 'BarberShop.db'
    db.results_as_hash = true                   # SELECTы будут в виде ХЕША.
    return db
end


 
def is_barber_not_exists? db, name              # Этот барбер не существует?
    db.execute('SELECT * FROM db_t_barbers WHERE barber_name=?', [name]).length <= 0
end                                             # Количество элементов = 0



def seed_db db, name_arr                        # Наполнение db именами барберов
    name_arr.each do |item|                     # Перебрать все имена барберов
        if is_barber_not_exists? db, item       # Если такого барбера нет, то ....
              db.execute 'INSERT INTO db_t_barbers (barber_name) VALUES (?)', [item]
        end                                     # ... внести item барбера в базу db.
    end    
end


# метод before исполняется перед каждым запросом GET или POST ======================
before do
    db = get_db                                 # Получение хеша из таблицы барберов
    @barbers = db.execute 'SELECT * FROM db_t_barbers'
end


# метод выполняется при старте sinatra =============================================
configure do
    db = get_db
                                         # Создать таблицу для записи в Barber Shop
                                         # если такая не существует    
    db.execute 'CREATE TABLE IF NOT EXISTS       
        "db_t_visit" 
        (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "user_name" TEXT,
            "phone" TEXT,
            "data_time" TEXT,
            "barber" TEXT,
            "color" TEXT
        )'
                                         # Создать таблицу для записи отзывов
                                         # если такая не существует    
    db.execute 'CREATE TABLE IF NOT EXISTS 
        "db_t_contacts" 
        (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "user_name" TEXT NOT NULL,
            "user_mail" TEXT,
            "message_user" TEXT
        )'
                                         # Создать таблицу для барберов
                                         # если такая не существует    
    db.execute 'CREATE TABLE IF NOT EXISTS 
        "db_t_barbers" 
        (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "barber_name" TEXT NOT NULL
        )'
                                                # список всех барберов 
    barbers_arr = ['Jessie Pinkman', 'Wolter White', 'Gas Fring']  
    
    seed_db db, barbers_arr                     # наполнить db всеми барберами

    # db.close    
end    


get '/' do
    erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/about' do
    @error = "somephing wrong!"                 # Пример вывода ошибки
    erb :about
end


get '/visit' do
    erb :visit
end

post '/visit' do
                                        # Данные из формы представления visit.erb
                                        # теперь становятся переменными этого метода
    @user_name = params[:user_name]
    @phone     = params[:phone]
    @date_time = params[:date_time]
    @barber    = params[:barber]
    @color     = params[:color]
                                        # Хеш для сообщений о необходимости дозаполнить
                                        # форму в visit.erb для записи клиента к барберу.
    hh = {  :user_name => 'Введите имя ',
                :phone => 'Введите номер телефона ',
            :date_time => 'Введите дату и время ' }

    # Для каждой пары ключ-значение делать:
    hh.each do |key, value|
        # если параметр из формы не заполнен (пустой)
        if params[key] == ''
            # то переменной error присвоить союе value из хеша hh
            # т.е переменной error присвоить сообщение об ошибке по даному параметру
            @error = hh[key]
            return erb :visit   # вернуться в форму для ввода недостающего параметра 
        end
    end

    @title = 'Спасибо!'
    @message = "Спасибо вам, #{@user_name}, будем ждать Вас."
  
    db = get_db                         # Внести данные базу, таблица db_t_visit
    db.execute 'INSERT INTO db_t_visit 
        (
            user_name, 
            phone, 
            data_time, 
            barber,
            color
        ) 
        VALUES ( ?, ?, ?, ?, ?)', 
        [
            @user_name,                 # порядок здесь должен соответствовать
            @phone,                     # порядку в запросе INSERT (выше)
            @date_time, 
            @barber,
            @color
        ]    
    # db.close

    erb :message

end

get '/contacts' do
    erb :contacts
end


post '/contacts' do
                                        # Данные из формы представления contacts.erb
                                        # теперь становятся переменными этого метода
    @user_name      = params[:user_name]
    @user_mail      = params[:user_mail]
    @message_user   = params[:message_user]

                                        # Хеш для сообщений о необходимости дозаполнить
                                        # форму в contacts.erb для отправки сообщения.
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

    db = get_db
    db.execute 'INSERT INTO db_t_contacts 
        (
            user_name, 
            user_mail, 
            message_user
        ) 
        VALUES ( ?, ?, ?)', 
        [
            @user_name, 
            @user_mail, 
            @message_user
        ]
    db.close

    erb :message
end


get '/showusers' do     # вывод списка записавшихся 
      
    db = get_db         # это массив хешей всей таблицы db_t_visit 
                        # отсортированный обратным порядком по id
    @result = db.execute 'SELECT * FROM db_t_visit ORDER BY id DESC'

    erb :showusers
    # db.close
end

get '/allmessages' do   # вывод списка всех сообщений от пользователей
      
    db = get_db         # это массив хешей всей таблицы db_t_contacts 
                        # отсортированный обратным порядком по id
    @result = db.execute 'SELECT * FROM db_t_contacts ORDER BY id DESC'

    erb :allmessages
    # db.close
end