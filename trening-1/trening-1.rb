require 'sqlite3'

db = SQLite3::Database.new 'BarberShop.db'

db.execute 'SELECT * FROM db_t_visit' do |row|
    puts "#{row[1]}  #{row[3]}"
    puts "===================================="
end
