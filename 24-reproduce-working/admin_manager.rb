require 'rubygems'
require 'mechanize'


module AdminManager

  class AdminManager
  
    @logged_in_page = nil
    
    def initialize
    
      m = Mechanize.new{|a|  a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE, a.gzip_enabled = false}
      page = m.get("https://admin.paypal.com/cgi-bin/admin")      
      puts "================================================= " + page.title
      
      form_login = page.forms.first
      form_login['id_username'] = "pborda"
      form_login['id_password'] = "pan.hot.red-502"
      @logged_in_page = form_login.submit
      puts @logged_in_page.body
    end
    
    
    # https://admin.paypal.com/cgi-bin/admin?node=transactionlog_flow&account_number=2203545717721305823
    

    
    def transaction_id(id)
      form_find_user = @logged_in_page.forms['form_findUser']
      form_find_user['id_transactionId'] = id
      find_user_response = form_find_user.submit    
      find_user_response.body.to_s
    end
    
    
    
    
    
    
    
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
  
  
  
  
  
  
end
