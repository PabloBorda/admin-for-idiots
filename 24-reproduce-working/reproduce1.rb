
require 'rubygems'
require 'mongo'
require 'levenshtein'
require 'json'



{
  :addon_name => "mongo_tickets_feed",
  :type => "FEED",
  :login => Proc.new {    
 
  },
  :helper_methods_exposed_to_url => [{:find_ticket_feed => Proc.new {

                                                             tik = params[:ticket_number]
                                                             puts "THE TICKET NUMBER IS: " + tik.to_s
                                                             puts "MY SESSIONS !" + session[:feed_sessions].to_json
                                                             client = Mongo::MongoClient.new
                                                             puts "LOGGED IN !!"                                                             
                                                             coll = client['pborda']['mts-tickets-indexed-by-paragraph']
                                                             puts "COLL : " + coll.to_json
                                                             ticke = coll.find({"RightNowTicket.RefNum" => tik}).first.to_json
                                                             puts "RETURNED TICKET: " + ticke
                                                             ticke
                                                         

                      }}]
  
        
}
