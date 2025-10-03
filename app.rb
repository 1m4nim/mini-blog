require 'sinatra'
require 'sqlite3'

# DB接続設定
# 'blog.db'というファイルに接続
DB = SQLite3::Database.new 'blog.db'
# データベースの結果をハッシュ形式（カラム名をキー）で受け取るように設定
DB.results_as_hash = true

# ----------------------------------------------------------------------
# R (Read) - 記事一覧表示
# ----------------------------------------------------------------------
# トップページ
get '/' do
  # 全記事を新しい順に取得
  @posts = DB.execute("SELECT * FROM posts ORDER BY id DESC")
  erb :index
end

# ----------------------------------------------------------------------
# R (Read) - 個別記事表示
# ----------------------------------------------------------------------
# 特定のIDを持つ記事の詳細を表示します。
get '/posts/:id' do
  # URLから取得したIDに一致する記事を1件取得
  @post = DB.execute("SELECT * FROM posts WHERE id = ?", [params[:id]]).first
  
  if @post.nil?
    halt 404, 'Article Not Found'
  end
  
  erb :show
end

# ----------------------------------------------------------------------
# C (Create) - 新規投稿
# ----------------------------------------------------------------------
# 新規投稿フォーム表示
get '/new' do
  erb :new
end

# 投稿保存処理
post '/create' do
  # フォームから送られた title と content を posts テーブルに挿入
  DB.execute("INSERT INTO posts (title, content) VALUES (?, ?)", 
             [params[:title], params[:content]])
  redirect '/'
end

# ----------------------------------------------------------------------
# U (Update) - 記事の編集・更新
# ----------------------------------------------------------------------
# 編集フォーム表示
get '/edit/:id' do
  # 編集対象の既存記事データを取得
  @post = DB.execute("SELECT * FROM posts WHERE id = ?", [params[:id]]).first
  
  if @post.nil?
    halt 404, 'Article Not Found for Editing'
  end
  
  erb :edit
end

# 投稿更新処理
post '/update/:id' do
  # フォームデータで既存記事を更新
  sql = "UPDATE posts SET title = ?, content = ? WHERE id = ? "
  DB.execute(sql, [params[:title], params[:content], params[:id]])
  
  # 更新後、その記事の詳細ページへリダイレクト
  redirect "/posts/#{params[:id]}"
end

# ----------------------------------------------------------------------
# D (Delete) - 記事削除
# ----------------------------------------------------------------------
# 記事削除処理
post '/delete/:id' do
  # IDに一致する記事を削除
  DB.execute("DELETE FROM posts WHERE id = ?", [params[:id]])
  redirect '/'
end