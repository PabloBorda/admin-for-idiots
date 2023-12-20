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




app = Sinatra.new 
app.set :public_folder, 'public'
app.set :bind, '0.0.0.0'  
app.set :port,9090




feed_sessions = []


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

addons.each do |a|
  puts a.to_json
  if (a[:type]=="FEED")
    app.get "/" + a[:addon_name] do
      openned_sessions = feed_sessions.select {|s| s[:name].eql? a[:addon_name]}
      login_session_result = {}
      if (openned_sessions.size == 0)
        login_session_result = a[:login].call(a[:base_url],a[:username],a[:password])
        feed_sessions.push ({:name => a[:addon_name],:session => login_session_result})
      else
        a[:retriever].call(login_session_result,params).to_json
      end
    end
    a[:helper_methods_exposed_to_url].to_a.each do |name,method|   
      app.get ("/" + name) &method
      app.post ("/" + name) &method
    end
  end
end




  app.get '/' do
    erb :search
  end




  app.get '/suggest_me' do
    
    suggestions = []
    feed_addons = addons.select {|a| a[:type].to_s.eql? "FEED"}
    feed_addons.each do |a|
      se = (feed_sessions.select {|s| s[:name].eql? a[:name]}).first
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