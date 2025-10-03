require 'bcrypt'
require 'io/console' # パスワード入力（noecho）のために必要

puts "管理者パスワード生成ツール"
puts "========================"

# パスワードをユーザーに入力してもらう
puts "設定したいパスワードを入力してください (入力は画面に表示されません):"
# io/console を require することで STDIN.noecho が利用可能になる
password = STDIN.noecho(&:gets).chomp 

# パスワードハッシュを生成
password_hash = BCrypt::Password.create(password).to_s

puts "\n========================"
puts "✅ 生成されたパスワードハッシュ (これを app.rb にコピーしてください):"
puts password_hash
puts "========================"
