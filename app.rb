require 'sinatra'
require 'sqlite3'

# DB接続
DB = SQLite3::Database.new 'blog.db'
DB.results_as_hash = true

# 記事一覧
get '/' do
  @posts = DB.execute("SELECT * FROM posts ORDER BY id DESC")
  erb :index
end

# 新規投稿フォーム
get '/new' do
  erb :new
end

# 投稿保存
post '/create' do
  DB.execute("INSERT INTO posts (title, content) VALUES (?, ?)", [params[:title], params[:content]])
  redirect '/'
end

# 記事削除
post '/delete/:id' do
  DB.execute("DELETE FROM posts WHERE id = ?", [params[:id]])
  redirect '/'
end
