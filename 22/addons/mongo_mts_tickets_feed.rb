require 'rubygems'
require 'mechanize'
require 'mongo'
require 'levenshtein'

load 'helpers/suggestions_filter.rb'

{
  :addon_name => "mongo_mts_tickets",
  :type => "FEED",
  :matching_lambda => Proc.new { /(([0-9]{6})-([0-9]{6}))/ },
  :base_url => "https://jira.paypal.com",
  :username => "",
  :password => "",
  :login => Proc.new { |url,user,pass|
    client = Mongo::MongoClient.new (url)
    db = client['pborda']
    db
  },
  :retriever => Proc.new { |login_result,parameters|

      db = login_result
      coll = db['mts-tickets-indexed-by-paragraph']

      findstr = parameters[:q]
      all_suggestions = []
  
      # this is not good and I know, but i had to change this to filter html tags, since the jquery ui code is very odd to do that
      
      #findstr = params[:q].to_s.split("<br>").last.to_s.gsub("&nbsp;"," ").to_s
  
  
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
              all_suggestions.push (autocomplete_object_item)
            end
          end      
        end


      if (all_suggestions.size<=10)
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

              all_suggestions.push (autocomplete_object_item)
              puts "SUGGESTIONS " + all_suggestions.to_json
            end
          end
        end


      end
  },
  :processor => Proc.new { |my_bug_links,findstr|
    
    my_bug_links

  },
  :how_many_results => 10,
  :helper_methods => [{:find_ticket_by_number => Proc.new {|tik,db|
                                                           coll = db['mts-tickets-indexed-by-paragraph']
                                                           coll.find({"RightNowTicket.RefNum" => tik}).first

                      }},
                      {:record_selection => Proc.new { |params|                      
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
                      }}]
  
        
}

#b = a[:login].call(a[:url],a[:username],a[:password])
#params = {:q => "Thank you for"}
#a[:retriever].call(b,params)
#puts a.to_json