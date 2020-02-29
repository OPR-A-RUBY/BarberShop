require 'sqlite3'

db = SQLite3::Database.new 'BarberShop.db'
db.results_as_hash = true

db.execute 'SELECT * FROM db_t_visit' do |row|
    puts "#{row['user_name']} -\t #{row['data_time']}"
    puts "===================================="
end
