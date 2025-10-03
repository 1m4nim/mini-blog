require 'sqlite3'

# DB接続: blog.dbファイルを作成します
DB = SQLite3::Database.new 'blog.db'

# postsテーブルを作成するSQL
# CREATE TABLE IF NOT EXISTS により、テーブルが既に存在する場合は何もしません
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT
  );
SQL

puts "Database 'blog.db' and table 'posts' have been successfully created."