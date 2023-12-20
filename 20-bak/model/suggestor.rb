require "sinatra/base"

module suggestor_helper

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









  
  def request_instance(req)
    original_lines = (req.split('\n'))
    processed_lines = SortedSet.new
    
    original_lines.each do |l|
      line_parts = l.split(' ')
      processed_lines.add([line_parts.first.to_s.gsub(' ',''),(set_to_array(line_parts)[1]).to_s.gsub(' ','')])
      
    end
    
    processed_lines
      
  end
  


  @suggest_me = lambda do |params|

    
    initialize_mongo_database()
    coll = @db['mts-tickets-indexed-by-paragraph']

    @suggestions = []

    # this is not good and I know, but i had to change this to filter html tags, since the jquery ui code is very odd to do that
    findstr = params[:q].to_s.split("<br>").last.to_s.gsub("&nbsp;"," ").to_s


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

end







end