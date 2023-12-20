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

load 'helpers/admin_manager.rb'
load 'helpers/suggestor_helper.rb'


set :public_folder, 'public'


set :bind, '0.0.0.0'  
set :port,9090






#addons = { :transaction_id => /[[[\s][\n]]]([[0-9][A-Z]]{17})[[[\s][\n]]]/,
#           :ticket_number => /(([0-9]{6})-([0-9]{6}))/,
#          :account_number => /[[[\s][\n]]][0-9]{19}[[[\s][\n]]]/,
#           :account_email => /[[[\s][\n]]](\S*@\S*)[[[\s][\n]]]/,
#           :token => /(EC-[[0-9][A-Z]]{17})/,
#          :cal => /[[[\s][\n]]]((?=.{0,12}\d)[a-z\d]{13})[[[\s][\n]]]/ } 



#addons = { :transaction_id => /\s(?=(\w){17})(?=([^A-Z][A-Z]){1,16})(?=([^\d]*[\d]{1,16})).*\s/,
#           :ticket_number => /(([0-9]{6})-([0-9]{6}))/,
#           :account_number => /\s(?=(\d{19})).*\s/,
#           :account_email => /(?=([\S]*[\s]{0}))\S*@\S*/,
#           :token => /\s(EC-[[0-9][A-Z]]{17})\s/,
#           :cal => /[[[a-z][A-Z][0-9]]\s\n]((?=.{0,12}\d)[a-z\d]{13})[[[a-z][A-Z][0-9]]\s\n]/ } 



#addons = {
         #  :transaction_id => Proc.new { /[[[\s][\n]]]([[0-9][A-Z]]{17})[[[\s][\n]]]/ }, 
 #          :ticket_number => Proc.new { /(([0-9]{6})-([0-9]{6}))/ },
 #          :account_number => Proc.new { /([0-9]{19})/ }
         #  :account_email => Proc.new { /[[[\s][\n]]](\S*@\S*)[[[\s][\n]]]/ },
         #  :token => Proc.new { /(EC-[[0-9][A-Z]]{17})/ },
         #  :cal => Proc.new { /[[[\s][\n]]]((?=.{0,12}\d)[a-z\d]{13})[[[\s][\n]]]/ }
         

#}




#   THIS IS MY PLUGIN SYSTEM.. AS EASY AS THAT !



# http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_mmather_LThumb_jpg.jpg
# http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_mmather_MThumb_jpg.jpg
# http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_mmather_SThumb_jpg.jpg



# db["mts-tickets-indexed-by-paragraph"].ensureIndex( { RightNowTicket: "text" });





  def set_to_array(s)
    a = Array.new
    s.each do |e|
      a.push e.to_s    
    end
    a
  end 
  
  
  
  
  
  def SortedSet.==(arr,arr1)
    arr[0] == arr1[0]
  
  end
  
  
  def print_array(arr)
    arr.each do 
      |k,v| 
      puts (k.to_s + "," + v.to_s)
    end  
  
  
  end
  
  
  


get '/leftmenu' do
  erb :leftmenu


end
  

get '/suggestion_item.ejs' do
  File.read(File.join('views', 'suggestion_item.ejs'))
end


get '/new_editor.ejs' do
  File.read(File.join('views', 'new_editor.ejs'))
end




get '/tools' do
  erb :tools

end



get '/suggest_me',&suggest_me