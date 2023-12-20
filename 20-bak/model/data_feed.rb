require "sinatra/base"

module data_access

class Datafeed


  def initialize_mongo_database()
    @client = Mongo::MongoClient.new
    @db = @client['pborda']  
  end




  get '/transaction_id/*' do
    "transaction_id"
    transaction_id = params['transaction_id']  
    am = AdminManager::AdminManager.new
    am.transaction_id transaction_id
  end

  get '/ticket_number/:ticketnum' do
    redirect "https://mts/wnvp/?method=GetRightNowTicketDetails&Custom=" + params[:ticketnum].to_s + "&ref_num=" + params[:ticketnum].to_s + "&dojo.preventCache=1420544362909"
  end
  
  get '/account_number/:account_number' do  
    redirect "https://admin.paypal.com/cgi-bin/admin?node=loaduserpage_home&account_number=" + params[:account_number].to_s + "&page_selector=ar_home"
  end
  
  get '/account_email' do  
    "account_email"
  end
  

  get '/token' do
    "token"  
  end
  

  get '/cal' do
    "cal"  
  end


  get '/' do
    erb :search
  end



  post '/learn*' do
    # move to mongo
  unless params[:learnfile] &&
         (tmpfile = params[:learnfile][:tempfile]) &&
         (name = params[:learnfile][:filename])
    @error = "No file selected"
    return haml(:upload)
  end
  
  
  pick_all_directly_from_file = tmpfile.read

   
  chunks = pick_all_directly_from_file.gsub("\t","").gsub("\r","").split("\n")
  client = Mongo::MongoClient.new
  db = client['pborda']
  coll = db['mts-knowledge-unique-pics']

  people = ["pborda","okeskin","mlaskowski","anegro","vconradt","mfagot","cplanchon","juobrien","pgaskin"]
      
  chunks.each do |c|
    
    random_people = []

    (0..rand(10)).each do |amount_of_people_who_agree|
      random_people.push people[rand(people.size)]

    end
    pic = "http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_" + people[rand(people.size)].to_s + "_MThumb_jpg.jpg"
    coll.insert( { :mr => pic, :knows => c.to_s.gsub("\n",""), :for => "question paragraph", :and_these_guys_agreee => random_people } )


  end
  
    
  get '/find_ticket' do
    initialize_mongo_database()
    find_ticket_by_number(params[:ticket_number]).to_json
  end

  def find_ticket_by_number(tik)  
    coll = @db['mts-tickets-indexed-by-paragraph']
    coll.find({"RightNowTicket.RefNum" => tik}).first
  end


  post '/record_selection' do
    findstr = params[:findstr].to_s
    use = params
    initialize_mongo_database()
    tk = find_ticket_by_number(params[:ticket_number])
    puts "FOUND TICKET " + tk.to_json
    note_number = params[:note_number].to_i
    puts "HAVE TO FIND " + note_number.to_s
    note = tk["RightNowTicket"][note_number]
    puts "MARKING NOTE " + note.to_s
    if (!note.has_key? "selection_counter")
      note["selection_counter"] = "0"
    else
      note["selection_counter"] = (note["selection_counter"].to_i + 1).to_s
    end
  
    coll = @db['mts-tickets-indexed-by-paragraph']
    #note_number_to_update = find_note_number_that_contains_the_selected_paragraph_string_in_a_ticket(findstr,tk)
    #if (!note_number_to_update.nil?)
    puts "FINDSTR IS: " + findstr
     # puts "I FOUND THE NOTE NUMBER TO BE UPDATED IS " + note_number_to_update
    coll.update({"RightNowTicket.RefNum" => params[:ticket_number].to_s },{"$set" => { "RightNowTicket." + note_number.to_s + ".selection_counter" => note["selection_counter"].to_s}})
    #end 

  end






  end




end


























end