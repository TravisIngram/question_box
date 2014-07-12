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
  property :author, String
end

DataMapper.finalize
DataMapper.auto_upgrade!

get "/" do                          # effectivily a GET / HTTP/1.0
  @question_box = Question_box.all  # what will be returned as a response
  erb :home                         # based on the home.erb
end                                 # if home were commented out, we would send our db
                                    # which would cause a 'no string value' error
get "/questions/new" do
  @question_box = Question_box.new
  erb :new_question
end

post "/questions" do
  question_box_attributes = params["question_box"]
  # We'll get the starting attributes for this question from `params`
  # that came in from `views/new_question.erb`

  question_box_attributes["created_at"] = DateTime.now
  # And add in the `created_at` attribute with the current time.

  @question_box = Question_box.create(question_box_attributes)
  
  if @question_box.saved?
    redirect "/"
  else
    erb :new_question
  end
end

#  get "/questions/:author" do
# #  @question_box = Question_box.get(requested_author)
# #  requested_author = params[:created_by]
#   @question_box = Question_box.get(params[:author])
#   erb :show
#  end



