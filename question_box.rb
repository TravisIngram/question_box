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

# Question box, recent qeustions
get "/" do                            # effectively a GET / HTTP/1.0
  @question_boxes = Question_box.all  # what will be returned as a response
  erb :home                           # based on the home.erb
end                                   # if home were commented out, we would send our db
                                      # which would cause a 'no string value' error
# Display details of question
get "/questions/:id" do
  @question_boxes = Question_box.get(params[:id])
  erb :edit
end

# Search for...something?  Author, created date?
get "/search"  do                     # eventually destination for a search option.
  @question_boxes = Question_box.all
  erb :new_question
end

# Update Question
get "/questions/:id/edit" do
  @question_boxes = Question_box.all
#  @question_boxes = Question_box.get(params[:id])
  erb :edit
end

# Create new question
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
    erb :home
  end
end

# Update Questions
put "/questions/:id" do
  @question_boxes = Question_box.all
  @question_boxes = (params[:id])
  @question_boxes.author = (params[:author])
#  question_box.created_at = (params[:created_at])
#  question_box.question = (params[:question])
  

  if question_box.save
    redirect '/questions/'+@question_boxes.id.to_s
  else
    redirect erb :new_question
  end
end

# Delete Questions
# delete "/questions/:id" do                  # basic delete destination
#   Question_box.get(params[:id]).destroy     
#   redirect "/"                              # I need to add a conditional on failure
# end                                         # to delete, not exactly clear how.


# These are all scratch, things I tried or saw and used as models.

# get "/questions/:question" do
#   @question_boxes = Question_box.get(params[:question])
#   erb :show
# end

# def self.search(query)
#   where(:author, query) -> This would return an exact match of the query
#   # where("title like ?", "%#{query}%") 
# end

# post "/search"  do
# #  @question_boxes = Question_box.where(:author => "%#{params[:query]}%")
# #  @question_boxes = Question_box.all(:author.like => "%#{params[:query]}%")
#   @question_boxes = Question_box.all(:author.like => "%#{params[:query]}%") | Event.all(:created_by.like => "%#{params[:query]}%")
#   erb :show
# end

#  get "/questions/:author" do
# #  @question_box = Question_box.get(requested_author)
# #  requested_author = params[:created_by]
#   @question_box = Question_box.get(params[:author])
#   erb :show
#  end

# get "/questions/:question" do
#  @question_box = Question_box.all
#  @question_box = Question_box.get(question)
#  question = params[:question]
#  @question_box = Question_box.get(params[:question])
#  erb :show
# end

