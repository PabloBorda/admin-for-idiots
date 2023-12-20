require "sinatra/base"

module parser_helper



    def parse(params) do

      @ticket = params[:ticket]
      new_text_with_replacements = ""
      generated_text_to_replace_match = ""
      addons.each do |a|
        k = a[:addon_name]
        v = a[:matching_lambda]
        r = a[:render_lambda]
        mo = a[:on_mouse_over_lambda]
        puts "Processing regex key: " + k.to_s + " value: " + v.call.to_s
        v1 = v.call
        if !@ticket.nil?
          @ticket.gsub!("\n","<br/>")
          @ticket.gsub!(/#{v1}/) do |matched| 
                                  matched.gsub!(" ","")
                                  matched.gsub!("<br/>","")
                                  generated_text_to_replace_match = r.call(k.to_s,matched) + mo.call(k.to_s)
                                  #generated_text_to_replace_match = (("<a href=\"" + (k.to_s + "/" + matched.to_s) + "\">") + matched.to_s + "</a>")
                                  if (!@ticket.include? generated_text_to_replace_match)                                
                                    puts "Generated link: " + generated_text_to_replace_match + " AND MATCHED " + matched.to_s
                                    generated_text_to_replace_match
                                  else
                                    matched
                                  end


          end
        end
        
      end
      puts @ticket.to_s      
      @ticket

    end
  



end