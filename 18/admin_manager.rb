require 'rubygems'
require 'mechanize'


module AdminManager

  class AdminManager
  
    @logged_in_page = nil
    
    def initialize
    
      m = Mechanize.new{|a|  a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE, a.gzip_enabled = false}
      page = m.get("https://admin.paypal.com/cgi-bin/admin")      
      puts "================================================= " + page.title
      
      form_login = page.forms.first
      form_login['id_username'] = "pborda"
      form_login['id_password'] = "pan.hot.red-502"
      @logged_in_page = form_login.submit
      puts @logged_in_page.body
    end
    
    
    # https://admin.paypal.com/cgi-bin/admin?node=transactionlog_flow&account_number=2203545717721305823
    

    
    def transaction_id(id)
      form_find_user = @logged_in_page.forms['form_findUser']
      form_find_user['id_transactionId'] = id
      find_user_response = form_find_user.submit    
      find_user_response.body.to_s
    end
    
    
    
    
    
    
    
  end
    
    
    
  
  
  
  
  
end
