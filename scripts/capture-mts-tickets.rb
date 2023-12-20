require 'rubygems'
require 'mongo'
require 'date'
require 'mechanize'
require 'json'
require 'open-uri'
require 'net/http'



def get_ticket(number)  


#uri = URI.parse("https://mts:443/wnvp/?method=GetRightNowTicketDetails&ref_num=" + number.to_s)
#args = {include_entities: 0, include_rts: 0, screen_name: 'pborda', count: 2, trim_user: 1}
#uri.query = URI.encode_www_form(args)
#http = Net::HTTP.new(uri.host, uri.port)
#http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#http.use_ssl = true

#request = Net::HTTP::Get.new(uri.request_uri)

#response = http.request(request)
#puts response.body

 m = Mechanize.new{|a|  a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE, a.gzip_enabled = false}
 m.cert = "mtscert.cer"
 m.ssl_version = :TLSv1
 m.user_agent_alias = 'Windows Mozilla'
 page = m.get("https://mts/wnvp/?method=GetRightNowTicketDetails&ref_num=" + number.to_s)
 puts page.body
 page.body



 # m = Mechanize.new{|a|  a.ssl_version, a.gzip_enabled = false}
 # m.ssl_version = :SSLv3
 # m.user_agent_alias = 'Windows Mozilla'
 # m.add_auth('https://mts:443','pborda','pan.hot.red-503')

 # page = m.get("https://mts:443/wnvp/?method=GetRightNowTicketDetails&ref_num=" + number.to_s) do     
 #   puts "================================================= " + page.title
 # end

 # page.body





end



def ticket_content_or_nil (number)
  ticket = get_ticket(number)
  JSON.parse(ticket)
  if (ticket["RightNowTicket"].size > 0)
    ticket
  else
    nil 
  end
end








def steal_tickets(fromdate,todate)
    d= Date.strptime(fromdate, '%Y-%m-%d')
    d1 = Date.strptime(todate, '%Y-%m-%d')
    puts "From date " + d.to_s
    puts "To date " + d1.to_s


    (d..d1).each do |d|
      si = (d.to_s.size)
      check_this_date = d.to_s[2..(si-1)].gsub("-","")
      puts "check this date " + check_this_date.to_s
      numtic = 0
      thereisticket = true
      basic = "000000"
      while (numtic < 999999) and (thereisticket)
          
          numticket_right = (basic[-((6-(numtic.to_s.size)))].to_s + numtic.to_s).to_s
          ticket_to_download = check_this_date + "-" + numticket_right       
          puts "Downloading ticket: " + ticket_to_download.to_s        
          
          curr_ticket = ticket_content_or_nil ticket_to_download.to_s
          puts curr_ticket

          numtic = numtic + 1
          
      end

    end
end


#log  steal_tickets("13-01-01","15-01-09")


steal_tickets("15-01-09","2015-02-02")