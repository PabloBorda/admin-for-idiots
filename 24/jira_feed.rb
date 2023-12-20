require 'rubygems'
require 'mechanize'

 {:base_url => "https://jira.paypal.com",
  :username => "pborda",
  :password => "pan.hot.red-504",
  :addon_name => "jira_feed",
  :type => "FEED",
  :matching_lambda => Proc.new { /([0-9]{19})/ },
  :login => Proc.new { 
    #m = Mechanize.new{|a|  a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE, a.gzip_enabled = false}
    #page = m.get("https://jira.paypal.com")      
    #puts "================================================= " + page.title
      
    #form_login = page.forms.first
    #form_login['login-form-username'] = a[:username]
    #form_login['login-form-password'] = a[:password]
    #form_login.submit
    ""
  },
  :retriever => Proc.new { |login_result,search_term|
      main_jira_page = login_result.submit
      main_jira_page.forms.first['quickSearchInput'] = search_term
      bugs = main_jira_page.forms.first.submit()
      bugs.links      
  },
  :processor => Proc.new { |my_bug_links,findstr|
    
      suggestions = []
      suggestions_for_jira = my_bug_links.map { |l| { :q => findstr, 
                                                      :mr => "JIRA",
                                                      :knows => l.text,
                                                      :for => findstr,
                                                      :ticket_number => "0",                
                                                      :note_number => "0",
                                                      :selection_counter => 0
                                       
      } }

     suggestions_for_jira_only_ticket_subjects = suggestions_for_jira.select {|s| ((s[:knows].match /[A-Z]{3,}-[0-9]+/).to_a.size <= 0) }

     puts "SUGGESTIONS FOR JIRA " + suggestions_for_jira[0..5].to_json

     suggestions = suggestions + suggestions_for_jira_only_ticket_subjects[0..4]

  },
  :how_many_results => 10,
  :helper_methods_exposed_to_url => []
  
        
}
