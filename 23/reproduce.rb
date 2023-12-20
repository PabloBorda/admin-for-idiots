require 'sinatra'
require 'mongo'
require 'json'

app = Sinatra.new
app.set :bind,"0.0.0.0"
app.set :port,9191
app.enable :sessions 


#use Rack::Session::Cookie, secret: "laconchadetumadre"




  file_source_code = File.open("reproduce1.rb", "rb")
  addon_source_code_as_string = file_source_code.read
  a = eval(addon_source_code_as_string)




app.before /[a-zA-Z][_]feed/ do
  session[:vars] = []  
  if session[:feed_sessions].nil?    
    session[:feed_sessions] = []
  end
  session[:feed_sessions].push(:name => "mongo_mts_tickets_feed",:session => a[:login].call())
end












a[:helper_methods_exposed_to_url].each do |m|
  m.each_pair do |name,proc|
    app.get "/" + name.to_s + "*", &proc
    app.post "/" + name.to_s + "*", &proc
  end
end




app.run!