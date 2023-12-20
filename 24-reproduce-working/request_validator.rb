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
    