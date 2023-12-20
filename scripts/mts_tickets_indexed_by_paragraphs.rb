require 'levenshtein'
require 'json'
require 'mongo'
require 'bson'



    client = Mongo::MongoClient.new("10.64.255.84")
    db = client['pborda']
    coll = db['mts-tickets']    
    coll_processed = db['mts-tickets-indexed-by-paragraph']


    process_by_paragraph = []
    process_by_sentence = []
    ticket_count = 1
  begin
    coll.find().each do |ticket|
      note_counter = 1     
       
      if (!ticket["RightNowTicket"].nil?)

        ticket["RightNowTicket"].each_slice(2) do |note|
          if ((!note[0].nil?) and (!note[1].nil?))
            current_note_a = note[0]["Note"]         
            current_note_b = note[1]["Note"]
            note_number_a = note_counter
            note_number_b = note_counter + 1

            distances_to_paragraph_b = []
            distances_from_a_paragraph_to_b_paragraph = []
            paragraph_count_a = 0
            current_note_a.split("<br>").each do |pa|
        
              paragraph_count_b = 0
              current_note_b.split("<br>").each do |pb|
                distances_to_paragraph_b.push ({"note_number_b"=>note_number_b,"paragraph_number_b" => paragraph_count_b, "distance_to_paragraph_b_from_paragraph_a" => Levenshtein.distance(pa,pb)})
                paragraph_count_b = paragraph_count_b + 1
              end     
              distances_from_a_paragraph_to_b_paragraph.push ({"note_number_a" => note_number_a, "paragraph_number_a" => paragraph_count_a, "distances_to_paragraphs_b" => ((distances_to_paragraph_b.sort_by {|obj| obj["distance_to_paragraph_b_from_paragraph_a"]})[0..19]) })
              paragraph_count_a = paragraph_count_a + 1
            end
        
            
            ticket["paragraph_index"] = distances_from_a_paragraph_to_b_paragraph
            note_counter = note_counter + 1      
          end
        end
        


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
