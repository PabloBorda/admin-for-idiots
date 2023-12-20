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

load 'admin_manager.rb'



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

addons = []
Dir.entries('addons').each do
  |dir|
  if (dir.include? ".rb")
    file_source_code = File.open("addons/" + dir, "rb")
    addon_source_code_as_string = file_source_code.read
    addons.push(eval(addon_source_code_as_string))
  end
end

addons.each do |a|
  puts a.to_s

end


# --------------------------------------------------------------




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






# http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_mmather_LThumb_jpg.jpg
# http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_mmather_MThumb_jpg.jpg
# http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_mmather_SThumb_jpg.jpg



# db["mts-tickets-indexed-by-paragraph"].ensureIndex( { RightNowTicket: "text" });


  def initialize_mongo_database()
    @client = Mongo::MongoClient.new
    @db = @client['pborda']  
  end


  def get_best_text_paragraph_for(note,query)    
    paragraphs_and_distance_to_query = []
   
    note.each do |rnt|
      paragraphs = rnt["Note"].split("<br>")
      paragraphs.each do |p|
        paragraphs_and_distance_to_query.push({:paragraph => p.to_s, :distance_to_query => Levenshtein.distance(query,p) })
      end
      paragraphs_and_distance_to_query_but_sorted = (paragraphs_and_distance_to_query.sort! do |p| p[:distance_to_query] end).reverse        
    end    
    puts "PARAGRAPHS RETURNED " + paragraphs_and_distance_to_query.to_json
    paragraphs_and_distance_to_query.first[:paragraph].to_s
  end



  def get_matching_paragraph(note,query)
    matching_paragraphs = []
    note.each do |rnt|
      paragraphs = rnt["Note"].split("<br>")
      paragraphs.each do |p|
        if (p.include?(query))
          matching_paragraphs.push({:paragraph => p.to_s})
        end
      end
    end
    best_paragraph = matching_paragraphs.first
    if (best_paragraph.nil?)
      ""
    else
      return best_paragraph[:paragraph].to_s
    end    
  end  


  def get_matching_paragraph_individual_words(note,query)
    matching_paragraphs = []
    similar_counter = 0
    note.each do |rnt|
      paragraphs = rnt["Note"].split("<br>")
      paragraphs.each do |p|
        words_from_paragraph_p = p.split(" ").uniq.map{|w| w.downcase}
        query.split(" ").uniq.each do |w|
          if words_from_paragraph_p.include? w.downcase
            similar_counter = similar_counter + 1
          end
        end
        if (similar_counter > 1)
          puts "PUSHING PARAGRAPH " + {:paragraph => p.to_s}.to_json
          matching_paragraphs.push({:paragraph => p.to_s})
        end
        similar_counter = 0
      end  
    end
    best_paragraph = matching_paragraphs.first
    if (best_paragraph.nil?)
      ""
    else
      return best_paragraph
    end    
  end




  



  def get_best_text_answer_for(note)


  end


  def get_matching_paragraph(note,query)
    matching_paragraphs = []
    paragraph_count = 0
    highest_selection_counter = -9999
    note.each do |rnt|
      paragraphs = rnt["Note"].split("<br>")
      selection_counter = rnt["selection_counter"].to_i
      if (selection_counter > highest_selection_counter)
        highest_selection_counter = selection_counter
      end

      paragraphs.each do |p|
        if (p.include?(query))
          matching_paragraphs.push({:paragraph => p.to_s,:paragraph_number => paragraph_count})
        end
        paragraph_count = paragraph_count + 1
      end
    end
    best_paragraph = matching_paragraphs.first
    if (best_paragraph.nil?)
      ""
    else
      best_paragraph[:selection_counter] = highest_selection_counter
      return best_paragraph
    end    
  end  



  def suggestion_filter(note,query)
    get_matching_paragraph(note,query)


  end


  def suggestion_filter_individual_words(note,query)
    get_matching_paragraph_individual_words(note,query)

  end


  def global_suggestions_filter(suggestions,query)

    unique_suggestions_filtered = suggestions.uniq {
                                    |s| [s[:knows]].join(":") 
                                  }

    #puts "unique_suggestions_filtered " + unique_suggestions_filtered.to_s

    sorted_by_levenshtein_distance = unique_suggestions_filtered.sort_by{
                                       |s| Levenshtein.distance(s[:knows],query) 
                                     }


    sorted_by_selection_counter_ascending = sorted_by_levenshtein_distance.sort! {
                                              |s| s[:selection_counter].to_i
                                            }

    sorted_by_selection_counter_descending = sorted_by_selection_counter_ascending.reverse

    # puts "sorted_by_selection_counter_descending " + sorted_by_selection_counter_descending.to_json
    
    sorted_by_selection_counter_descending

  end



  def find_note_number_that_contains_the_selected_paragraph_string_in_a_ticket(paragraph,ticket)
    (ticket[:RightNowTicket].to_a.index {|n| n.to_s.include? paragraph})
  end


  get '/suggest_me' do
    
    initialize_mongo_database()
    coll = @db['mts-tickets-indexed-by-paragraph']

    @suggestions = []

    # this is not good and I know, but i had to change this to filter html tags, since the jquery ui code is very odd to do that
    findstr = params[:q].to_s.split("<br>").last.to_s


    phrases_found = 0
    #words_from_query = (findstr.split " ")
    #string_from_words_from_query = ""
    #words_from_query.each do |w|
    #  string_from_words_from_query =  string_from_words_from_query + " " + w.to_s

    #end
    #string_from_words_from_query = findstr
    
    #string_from_words_from_query = "\\\"" + string_from_words_from_query + "\\\""
    
    puts "QUERY BEING EXECUTED " + ("\"\"" + findstr + "\"\"")

    
    coll.find( { "$text" => {"$search" => ("\"\"" + findstr + "\"\"")  }}, :fields => [{ "score" => { "$meta" => "textScore" } }] ).sort({"RightNowTicket.selection_counter" => -1}).limit(10).each do |t|
      phrases_found = phrases_found + 1      
      

      name_and_last_name_from_ticket = (t["RightNowTicket"][0]["Assigned"])
      ticket_number = (t["RightNowTicket"][0]["RefNum"])

      if (!name_and_last_name_from_ticket.nil?)
          name_and_last_name = (name_and_last_name_from_ticket).split(" ")
          first_name_letter = name_and_last_name[0].to_s[0].downcase
          last_name_lower_case = name_and_last_name[1].to_s.downcase
          possible_user_name = first_name_letter + last_name_lower_case

        
          pic = "http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_" + possible_user_name.to_s + "_LThumb_jpg.jpg"


          filtered_suggestion = suggestion_filter(t["RightNowTicket"],findstr)
         
          if ((!filtered_suggestion.nil?) and
              (!filtered_suggestion.eql? "") and
              (Levenshtein.distance(findstr,filtered_suggestion[:paragraph].to_s) > 4))

            autocomplete_object_item = { :q => findstr, 
                                         :mr => (possible_user_name).to_s,
                                         :knows => filtered_suggestion[:paragraph].to_s,
                                         :for => findstr,
                                         :ticket_number => ticket_number,                
                                         :note_number => filtered_suggestion[:note_number].to_s,
                                         :selection_counter => filtered_suggestion[:selection_counter].to_i
                                       
             }        
            @suggestions.push (autocomplete_object_item)
          end
        end      
      end


    if (@suggestions.size<=10)
      puts "QUERY BEING EXECUTED FOR INDIVIDUAL WORDS " + (findstr)
      results = coll.find( { "$text" => {"$search" => (findstr)  }}).sort( { "score" => { "$meta" => "textScore" }}).sort({"RightNowTicket.selection_counter" => -1}).limit(10)
      puts "RESULTS SIZE IS " + results.count.to_s
      results.each do |t|
        phrases_found = phrases_found + 1      
      

        name_and_last_name_from_ticket = (t["RightNowTicket"][0]["Assigned"])
        ticket_number = (t["RightNowTicket"][0]["RefNum"])
        puts "ITERATOR ON TICKET " + ticket_number
        if (!name_and_last_name_from_ticket.nil?)
            name_and_last_name = (name_and_last_name_from_ticket).split(" ")
            first_name_letter = name_and_last_name[0].to_s[0].downcase
            last_name_lower_case = name_and_last_name[1].to_s.downcase
            possible_user_name = first_name_letter + last_name_lower_case

        
            pic = "http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_" + possible_user_name.to_s + "_LThumb_jpg.jpg"
            puts "PIC URL IS " + pic

          filtered_suggestion = suggestion_filter_individual_words(t["RightNowTicket"],findstr)
        
          if ((!filtered_suggestion.nil?) and
              (!filtered_suggestion.eql? "") and
              (Levenshtein.distance(findstr,filtered_suggestion[:paragraph].to_s) > 4))

            autocomplete_object_item = { :q => findstr, 
                                         :mr => (possible_user_name).to_s,
                                         :knows => filtered_suggestion[:paragraph].to_s,
                                         :for => findstr,
                                         :ticket_number => ticket_number,                
                                         :note_number => filtered_suggestion[:note_number].to_s,
                                         :selection_counter => filtered_suggestion[:selection_counter].to_i
                                       
            }        

            @suggestions.push (autocomplete_object_item)
            puts "SUGGESTIONS " + @suggestions.to_json
          end
        end
      end

      { 
       :query => params[:q].to_s,
       :suggestions => global_suggestions_filter(@suggestions,findstr)
      }.to_json
    end



  end


  post '/parse*' do

      @ticket = params[:ticket]
      addons.each do |a|
        k = a[:addon_name]
        v = a[:matching_lambda]
        puts "Processing regex key: " + k.to_s + " value: " + v.call.to_s
        v1 = v.call
        @ticket.gsub!(/#{v1}/) do |matched| 
                                matched.gsub!(" ","")
                                matched.gsub!("<br/>","")
                                m = (("<a href=\"" + (k.to_s + "/" + matched.to_s) + "\">") + matched.to_s + "</a>")
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
    

get '/leftmenu' do
  erb :leftmenu


end
  
  
get '/find_ticket' do
  initialize_mongo_database()
  find_ticket_by_number(params[:ticket_number])
end

def find_ticket_by_number(tik)  
  coll = @db['mts-tickets-indexed-by-paragraph']
  coll.find({"RightNowTicket.RefNum" => tik}).first
end

get '/suggestion_item.ejs' do
  File.read(File.join('views', 'suggestion_item.ejs'))


end


get '/tools' do
  erb :tools

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

