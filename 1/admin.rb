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


set :public_folder, 'public'


load 'admin_manager.rb'



set :bind, '0.0.0.0'  
set :port,9090





#regexs = { :transaction_id => /[[[\s][\n]]]([[0-9][A-Z]]{17})[[[\s][\n]]]/,
#           :ticket_number => /(([0-9]{6})-([0-9]{6}))/,
#          :account_number => /[[[\s][\n]]][0-9]{19}[[[\s][\n]]]/,
#           :account_email => /[[[\s][\n]]](\S*@\S*)[[[\s][\n]]]/,
#           :token => /(EC-[[0-9][A-Z]]{17})/,
#          :cal => /[[[\s][\n]]]((?=.{0,12}\d)[a-z\d]{13})[[[\s][\n]]]/ } 



#regexs = { :transaction_id => /\s(?=(\w){17})(?=([^A-Z][A-Z]){1,16})(?=([^\d]*[\d]{1,16})).*\s/,
#           :ticket_number => /(([0-9]{6})-([0-9]{6}))/,
#           :account_number => /\s(?=(\d{19})).*\s/,
#           :account_email => /(?=([\S]*[\s]{0}))\S*@\S*/,
#           :token => /\s(EC-[[0-9][A-Z]]{17})\s/,
#           :cal => /[[[a-z][A-Z][0-9]]\s\n]((?=.{0,12}\d)[a-z\d]{13})[[[a-z][A-Z][0-9]]\s\n]/ } 



regexs = {
           :transaction_id => Proc.new { /[[[\s][\n]]]([[0-9][A-Z]]{17})[[[\s][\n]]]/ }, 
           :ticket_number => Proc.new { /(([0-9]{6})-([0-9]{6}))/ }
           # :account_number => Proc.new {
           

           # },
           # :account_email => Proc.new {
           

           # },
           # :token => Proc.new {
           

           # },
           # :cal => Proc.new {
           

           # }


}



  get '/transaction_id/*' do
    "transaction_id"
    transaction_id = params['transaction_id']  
    am = AdminManager::AdminManager.new
    am.transaction_id transaction_id
    
    
  
  end

  get '/ticket_number/:ticketnum' do
    redirect "https://mts/wnvp/?method=GetRightNowTicketDetails&Custom=" + params[:ticketnum].to_s + "&ref_num=" + params[:ticketnum].to_s + "&dojo.preventCache=1420544362909"
  end
  
  get '/account_number' do
  
    "account_number"
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
  coll = db['mts-knowledge']

  
  chunks.each do |c|
    coll.insert( { :iknow => c.to_s.gsub("\n","") } )


  end
  


  end


  get '/mts-database-download' do
  

    d= Date.strptime(params[:fromdate], '%Y-%m-%d')
    d1 = Date.strptime(params[:todate], '%Y-%m-%d')
    puts "From date " + d.to_s
    puts "To date " + d1.to_s


    (d..d1).each do |d|
      si = (d.to_s.size)
      check_this_date = d.to_s[2..si].gsub("-","")
      numtic = 0
      thereisticket = true
      basic = "000000"
      while (numtic < 999999) and (thereisticket)
        numticket_right = (basic[0..(6-(numtic%10))] + numtic).to_s
        ticket_to_download = check_this_date + "-" + numticket_right
        puts "Downloading ticket: " + ticket_to_download.to_s

      end

    end





  end

  get '/suggest_me' do
    
    client = Mongo::MongoClient.new
    db = client['pborda']
    coll = db['mts-knowledge']

    @suggestions = []
    findstr = params[:q].to_s
    phrases_found = 0
    words_from_query = findstr.split " "
    string_from_words_from_query = ""
    words_from_query.each do |w|
      string_from_words_from_query = string_from_words_from_query + w.to_s + " "

    end



    coll.find({ "$text" => { "$search" => ("\"" + findstr +  "\" ") } }).limit(15).each do |p|
      phrases_found = phrases_found + 1      
      @suggestions.push ({ :q => findstr ,:iknow => p["iknow"], :for => p["iknow"] })
    end


    { 
     :query => params[:q].to_s,
     :suggestions => @suggestions }.to_json



  end


  post '/parse*' do

      @ticket = params[:ticket]
      regexs.each_pair do |k,v|
        puts "Processing regex key: " + k.to_s + " value: " + v.call.to_s
        v1 = v.call
        @ticket.gsub!(/#{v1}/) do |matched| 
                                matched.gsub!(" ","")
                                matched.gsub!("\n","")
                                m = (("<a href=" + (k.to_s + "/" + matched.to_s) + ">") + matched.to_s + "</a>")
                                puts "Generated link: " + m + " AND MATCHED " + matched.to_s
                                m
                              end
        @ticket.gsub!("\n","<br/>")
      end      
      @ticket

  end
  
  
  def request_instance(req)
    original_lines = (req.split('\n'))
    processed_lines = SortedSet.new
    
    original_lines.each do |l|
      line_parts = l.split(' ')
      processed_lines.add([line_parts.first.to_s.gsub(' ',''),(set_to_array(line_parts)[1]).to_s.gsub(' ','')])
      
    end
    
    processed_lines
      
  end
  
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
  
  
  
  get '/validate_request*' do
  
  
    puts "PARAMS ARE [" 
  
  
    original = request_instance(params[:original_request].to_s)
    compare_to = request_instance(params[:compare_to].to_s)
  
  
    
  
  
  
    puts "THIS IS THE DIFFERENCE SET "
    print_array(set_to_array((original - compare_to)))
    puts "THIS IS SET ORIGINAL "
    print_array(set_to_array((original)))
    puts "THIS IS SET COMPARE_TO "
    print_array(set_to_array((compare_to)))
    
    
      
    #original = URI::encode(set_to_array(request_instance(params[:original_request])).to_s)
    #compare_to = URI::encode(set_to_array(request_instance(params[:compare_to])).to_s)

      if (compare_to.length < original.length)
        puts "Please verify the following parameters that seem to be wrong: " + URI::encode(set_to_array(original - compare_to).to_json)
      
    
      else
        if ((compare_to.length-original.length)==0)
          puts "All parameters seem OK"
         
        else
          puts "Missing parameters" + URI::encode(set_to_array(original - compare_to).to_json)
        end
      end 
   
      puts "RETURN " + URI::encode(set_to_array(compare_to - original).to_json)
      return URI::encode((set_to_array(compare_to - original)).to_json)
    
    end
    

  
  
  
  