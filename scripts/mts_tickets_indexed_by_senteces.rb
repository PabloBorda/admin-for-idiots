require 'levenshtein'
require 'json'
require 'mongo'
require 'bson'



    client = Mongo::MongoClient.new("10.64.255.84")
    db = client['pborda']
    coll = db['mts-tickets']    
    coll_processed = db['mts-tickets-indexed-by-sentence']


    process_by_sentence = []
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

            distances_to_sentence_b = []
            distances_from_a_sentence_to_b_sentence = []
            sentence_count_a = 0
            current_note_a.split(".").each do |pa|
        
              sentence_count_b = 0
              current_note_b.split(".").each do |pb|
                distances_to_sentence_b.push ({"note_number_b"=>note_number_b,"sentence_number_b" => sentence_count_b, "distance_to_sentence_b_from_sentence_a" => Levenshtein.distance(pa,pb)})
                sentence_count_b = sentence_count_b + 1
              end     
              distances_from_a_sentence_to_b_sentence.push ({"note_number_a" => note_number_a, "sentence_number_a" => sentence_count_a, "distances_to_sentences_b" => ((distances_to_sentence_b.sort_by {|obj| obj["distance_to_sentence_b_from_sentence_a"]})[0..19]) })
              sentence_count_a = sentence_count_a + 1
            end
        
            
            ticket["sentence_index"] = distances_from_a_sentence_to_b_sentence
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
