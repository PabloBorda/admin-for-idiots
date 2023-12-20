require 'sinatra'
require 'mongo'
require 'json'
require 'byebug'

app = Sinatra.new
app.set :bind,"0.0.0.0"
app.set :port,9191
app.enable :sessions 



  app.set :show_exceptions => false

  app.error { |err|
    Rack::Response.new(
      [{'error' => err.message}.to_json],
      500,
      {'Content-type' => 'application/json'}
    ).finish
  }






addons = []
Dir.entries('addons').each do
  |dir|
  if (dir.include? ".rb")
    file_source_code = File.open("addons/" + dir, "rb")
    addon_source_code_as_string = file_source_code.read
    addon = eval(addon_source_code_as_string)   
    addons.push(addon)
  end
end



a = addons.first
byebug


app.before /[a-zA-Z][_]feed/ do

  puts "RUNNING BEFORE "
  
  if (session[:feed_sessions].nil?)
    session[:feed_sessions] = []
  
  end
  addons.each do |a|
    if a[:type].eql? "FEED"
      openned_sessions = []      
      login_session_result = {}
      openned_sessions = session[:feed_sessions].select {|s| s[:name].eql? a[:addon_name]}
      puts "OPENNED SESSIONS " + openned_sessions.to_json    
      while openned_sessions.size == 0
        begin
          puts "Trying to connect to " + a[:addon_name].to_s
          login_session_result = a[:login].call()
          session[:feed_sessions].push ({:name => a[:addon_name],:session => login_session_result})
        rescue Exception => e  
          puts "Failed login for feed " + a[:addon_name] + " REASON: " + e.message

        
        end
        openned_sessions = session[:feed_sessions].select {|s| s[:name].eql? a[:addon_name]}
      end
      if openned_sessions.size > 0
        puts "ALREADY LOGGED IN TO : " + a[:addon_name].to_s
      end
    end    
  end
end

if !a[:helper_methods_exposed_to_url].nil?
  a[:helper_methods_exposed_to_url].each do |m|
    m.each_pair do |name,proc|
      app.get "/" + name.to_s + "*", &proc
      app.post "/" + name.to_s + "*", &proc
    end
  end
end




app.run!