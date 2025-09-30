require "sinatra"

posts=[]

get "/" do 
    @posts=posts
    erb :index
end

get "/new" do
    erb :new
end

post "/create" do
    title=params[:title]
    content=params[:content]
    posts << {title:title, content:content}
    redirect "/"
end