require 'sinatra'
require 'data_mapper'

if ENV['RACK_ENV'] != "production"
  require 'dotenv'
  Dotenv.load '.env'
  DataMapper.setup(:default, "sqlite:question_box.db")
end

if ENV['RACK_ENV'] == "production"
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

class Question_box
  include DataMapper::Resource
  property :id,          Serial
  property :created_by, String
  property :recipient, String
  property :question, Text
  property :likes, Integer
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

get "/" do            # effectivily a GET / http/1.0
  @question_box = Question_box.all
  erb :home
end

get "/questions/:created_by" do
  requested_author = params[:created_by]
  @question_box = Question_box.get(requested_author)
  erb :show
end

get "/questions/:created_by" do
  @question_box = Question_box.new
  erb :new_question
end

post "/questions" do
  question_box_attributes = params["question_box"]
  # We'll get the starting attributes for this wall from `params` that came in
  # from `views/new_wall.erb`

  question_box_attributes["created_at"] = DateTime.now
  # And add in the `created_at` attribute with the current time.

  @question_box = Question_box.create(wall_attributes)
  
  if @question_box.saved?
    redirect "/"
  else
    erb :home
  end
end