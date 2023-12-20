require 'levenshtein'
require 'json'
require 'mongo'
require 'bson'


  

  def similar_words_counter(p1,p2)
    p1_words = p1.split(" ").map{|i| i.downcase}.uniq.select{|w| (w.size >= 4)}
    p2_words = p2.split(" ").map{|i| i.downcase}.uniq.select{|w| (w.size >= 4)}
    count = 0

    if (p1_words.size <= p2_words.size)
      p1_words.each do |w|
        if p2_words.include? w.downcase
          count = count + 1
        end
      end
    else
      p2_words.each do |w|
        if p1_words.include? w.downcase
          count = count + 1
        end
      end
    end
    {:amount => count,:pa => p1,:pb => p2}
  end








  client = Mongo::MongoClient.new("10.64.255.84")
  db = client['pborda']
  coll = db['mts-tickets']    
  coll_processed = db['mts-tickets-indexed-by-paragraph_amount_of_equal_words_debug']


  process_by_paragraph = []
  process_by_sentence = []
  ticket_count = 0
  begin
    coll.find().each do |ticket|
      note_number_a = 0
       
      if (!ticket["RightNowTicket"].nil?)
        ticket["RightNowTicket"].each do |notea| 
          note_number_b = 0
          ticket["RightNowTicket"].each do |noteb|            
            note=[]
            note[0]=notea
            note[1]=noteb
            if ((!note[0].nil?) and (!note[1].nil?))
              current_note_a = note[0]["Note"]         
              current_note_b = note[1]["Note"]  
              #puts "CURRENT_NOTE_A " + current_note_a
              #puts "CURRENT_NOTE_B " + current_note_b
              distances_to_paragraph_b = []
              distances_from_a_paragraph_to_b_paragraph = []
              paragraph_count_a = 0
              amount_of_similar_words = {}
              current_note_a.split("<br>").each do |pa|
                paragraph_a = pa
                if (paragraph_a.size > 0)
                  paragraph_count_b = 0
                
                  #puts "CURRENT_NOTE_B " + current_note_b.split("<br>").each { |p| puts p.to_s }
                  current_note_b.split("<br>").each do |pb|
                    paragraph_b = pb
                    if (paragraph_b.size > 0)
                      amount_of_similar_words = similar_words_counter(pa,pb)
                      if (amount_of_similar_words[:amount] > 3)
                        distances_to_paragraph_b.push ({"note_number_b"=>note_number_b,"paragraph_number_b" => paragraph_count_b, "distance_to_paragraph_b_from_paragraph_a" => amount_of_similar_words[:amount], "paragraph_b" => amount_of_similar_words[:pb].to_s})
                        paragraph_count_b = paragraph_count_b + 1
                      end
                    end
                  end     
                  if (distances_to_paragraph_b.size > 0)
                    distances_from_a_paragraph_to_b_paragraph.push ({"note_number_a" => note_number_a, "paragraph_number_a" => paragraph_count_a, "distances_to_paragraphs_b" => ((distances_to_paragraph_b.sort_by {|obj| obj["distance_to_paragraph_b_from_paragraph_a"]})[0..19]), "paragraph_a" => amount_of_similar_words[:pa].to_s})
                    paragraph_count_a = paragraph_count_a + 1
                  end
                end
              end
            end
        
            
            paragraph_index = (distances_from_a_paragraph_to_b_paragraph.sort! {|x, y| x["distance_to_paragraph_b_from_paragraph_a"].to_i <=> y["distance_to_paragraph_b_from_paragraph_a"].to_i}).reverse
            if (paragraph_index.size > 0)
              ticket["paragraph_index"] = paragraph_index
            end
            note_number_b = note_number_b + 1
          end
        end
          note_number_a = note_number_a + 1        
      end
    
      ticket.delete("_id")           # to avoid insert duplicate element        
      #puts ticket

      if (BSON.serialize(ticket).size < 3194304)
        coll_processed.insert(ticket)
      end
      ticket_count = ticket_count + 1
    end    

  rescue Exception => e  
    puts e.message  
    puts e.backtrace.inspect  
  end
