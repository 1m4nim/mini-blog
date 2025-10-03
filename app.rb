require 'sinatra'
require 'sqlite3'
require 'bcrypt' # パスワードハッシュ比較のためにBCryptをインポート

# ----------------------------------------------------------------------
# 認証設定とセッションの有効化
# ----------------------------------------------------------------------

# セッションを有効化 (ログイン状態の保持に必要)
enable :sessions 
# 秘密鍵を64文字以上の長い文字列に修正しました
set :session_secret, '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' 

# 管理者情報の設定
# ✅ ユーザー名を 'admin' に変更しました
ADMIN_USERNAME = 'admin' 
# ✅ 新しいハッシュ文字列に置き換えました！
ADMIN_PASSWORD_HASH = '$2a$12$qYcc3pOjRq4VuNnB0IVFkeJYzaSIQw2wZk/r1i6I8ux0.0lELy3O.' 
ENABLE_AUTH = true # 認証機能を有効にするフラグ

# ----------------------------------------------------------------------
# 認証ヘルパーメソッド
# ----------------------------------------------------------------------

# ログイン済みかチェックする
def authorized?
  # 認証機能が無効な場合（開発用）は常にtrue
  return true if !ENABLE_AUTH 
  # セッションに管理者IDが保存されているか確認
  session[:user_id] == ADMIN_USERNAME
end

# ログインが必要なルートで呼び出し、未ログインなら /login にリダイレクト
def protect!
  redirect '/login' unless authorized?
end

# ----------------------------------------------------------------------
# DB接続設定
# ----------------------------------------------------------------------

# 'blog.db'というファイルに接続
DB = SQLite3::Database.new 'blog.db'
# データベースの結果をハッシュ形式（カラム名をキー）で受け取るように設定
DB.results_as_hash = true

# ----------------------------------------------------------------------
# 認証ルート (ログイン/ログアウト)
# ----------------------------------------------------------------------

# ログインフォーム表示
get '/login' do
  erb :login
end

# ログイン認証処理
post '/login' do
  # 入力されたパスワードとハッシュを比較
  hashed_password = BCrypt::Password.new(ADMIN_PASSWORD_HASH)

  if params[:username] == ADMIN_USERNAME && hashed_password == params[:password]
    # 認証成功: セッションにユーザーIDを保存
    session[:user_id] = params[:username]
    redirect '/'
  else
    # 認証失敗
    @error = "ユーザー名またはパスワードが違います。"
    erb :login
  end
end

# ログアウト処理
get '/logout' do
  session.clear # セッション情報をすべて削除
  redirect '/'
end

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
# C (Create) - 新規投稿 (管理者のみ)
# ----------------------------------------------------------------------
# 新規投稿フォーム表示
get '/new' do
  protect! # <-- アクセス制限を追加
  erb :new
end

# 投稿保存処理
post '/create' do
  protect! # <-- アクセス制限を追加
  # フォームから送られた title と content を posts テーブルに挿入
  DB.execute("INSERT INTO posts (title, content) VALUES (?, ?)", 
             [params[:title], params[:content]])
  redirect '/'
end

# ----------------------------------------------------------------------
# U (Update) - 記事の編集・更新 (管理者のみ)
# ----------------------------------------------------------------------
# 編集フォーム表示
get '/edit/:id' do
  protect! # <-- アクセス制限を追加
  # 編集対象の既存記事データを取得
  @post = DB.execute("SELECT * FROM posts WHERE id = ?", [params[:id]]).first
  
  if @post.nil?
    halt 404, 'Article Not Found for Editing'
  end
  
  erb :edit
end

# 投稿更新処理
post '/update/:id' do
  protect! # <-- アクセス制限を追加
  # フォームデータで既存記事を更新
  sql = "UPDATE posts SET title = ?, content = ? WHERE id = ? "
  DB.execute(sql, [params[:title], params[:content], params[:id]])
  
  # 更新後、その記事の詳細ページへリダイレクト
  redirect "/posts/#{params[:id]}"
end

# ----------------------------------------------------------------------
# D (Delete) - 記事削除 (管理者のみ)
# ----------------------------------------------------------------------
# 記事削除処理
post '/delete/:id' do
  protect! # <-- アクセス制限を追加
  # IDに一致する記事を削除
  DB.execute("DELETE FROM posts WHERE id = ?", [params[:id]])
  redirect '/'
end
