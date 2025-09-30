require 'sqlite3'

db = SQLite3::Database.new 'blog.db'
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT
  );
SQL
