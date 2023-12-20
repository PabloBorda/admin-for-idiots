
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
