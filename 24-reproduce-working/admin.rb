# admin.rb
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'to_regexp'
require 'set'
require 'json'
require 'mongo'
require 'date'
require 'levenshtein'
require 'thin'


#class AdminTools < Sinatra::Base; end

app = Sinatra.new

app.set :public_folder, 'public'
app.set :bind, '0.0.0.0'  
app.set :port,9090
#app.set :server, 'thin'
app.enable :sessions



#use Rack::Session::Cookie, secret: "laconchadetumadre"

# THIS IS AN ADDON ARCHITECTURE, NO DIRTY CLASSES AND COMPLICATED PATTERNS .. AS EASY AS THAT !
# ONLY OBJECTS
# THIS STUFF IS QUITE ABSTRACT AND IT WORKS

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
      if (openned_sessions.size == 0)
        begin
          login_session_result = a[:login].call()
          session[:feed_sessions].push ({:name => a[:addon_name],:session => login_session_result})
        rescue
          puts "Failed login for feed " + a[:addon_name]
        
        end
      end
        
        
        
   end
   end
end

 # a = (addons.select {|addn| addn[:addon_name].eql? "mongo_mts_tickets_feed" }).first

  #session[:vars] = []  
  #if session[:feed_sessions].nil?    
  #  session[:feed_sessions] = []
  #end
  #session[:feed_sessions].push(:name => "mongo_mts_tickets_feed",:session => a[:login].call())






addons.each do |a|
  puts a.to_json
  if (a[:type]=="FEED")
    puts "IS A FEED"
    app.get ("/" + a[:addon_name]),&a[:retriever]


    puts "helper_methods " + a[:helper_methods_exposed_to_url].to_json
    if (!a[:helper_methods_exposed_to_url].nil?)
      a[:helper_methods_exposed_to_url].each do |method_object|
        method_object.each_pair do |method_name,method_block|
          puts "METHOD_NAME " + method_name.to_s + " METHOD_BLOCK " + method_block.to_s
          app.get "/" + method_name.to_s + "*", &method_block
          app.post "/" + method_name.to_s + "*", &method_block
        end
      end
    end
  end
end




  app.get '/' do
    session[:feed_sessions] = []
    erb :search
  end




  app.get '/suggest_me' do
    
    suggestions = []
    feed_addons = addons.select {|a| a[:type].to_s.eql? "FEED"}
    feed_addons.each do |a|
      #a[:login].call()
      se = (session[:feed_sessions].select {|s| s[:name].eql? a[:name]}).first
      suggestions = suggestions + a[:retriever].call(se[:session],params)
    end
      { 
       :query => params[:q].to_s,
       :suggestions => global_suggestions_filter(suggestions,findstr)
      }.to_json
  end



  app.post '/parse*' do

      @ticket = params[:ticket]
      new_text_with_replacements = ""
      generated_text_to_replace_match = ""
      addons.each do |a|
        if (a[:type]=="WEB")
          k = a[:addon_name]
          v = a[:matching_lambda]
          r = a[:render_lambda]
          mo = a[:on_mouse_over_lambda]
          puts "Processing regex key: " + k.to_s + " value: " + v.call.to_s
          v1 = v.call
          if !@ticket.nil?
            @ticket.gsub!("\n","<br/>")
            @ticket.gsub!(/#{v1}/) do |matched| 
                                    matched.gsub!(" ","")
                                    matched.gsub!("<br/>","")
                                    generated_text_to_replace_match = r.call(k.to_s,matched) + mo.call(k.to_s)
                                    #generated_text_to_replace_match = (("<a href=\"" + (k.to_s + "/" + matched.to_s) + "\">") + matched.to_s + "</a>")
                                    if (!@ticket.include? generated_text_to_replace_match)                                
                                      puts "Generated link: " + generated_text_to_replace_match + " AND MATCHED " + matched.to_s
                                      generated_text_to_replace_match
                                    else
                                      matched
                                    end


            end
          end
        end    
      end
      puts @ticket.to_s      
      @ticket
  end
  
  
 

app.get '/leftmenu' do
  erb :leftmenu


end
  
  

app.get '/suggestion_item.ejs' do
  File.read(File.join('views', 'suggestion_item.ejs'))
end


app.get '/new_editor.ejs' do
  File.read(File.join('views', 'new_editor.ejs'))
end




app.get '/tools' do
  erb :tools

end








app.run!