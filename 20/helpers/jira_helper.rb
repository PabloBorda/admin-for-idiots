require 'rubygems'
require 'mechanize'

module Datafeed
  
class Jirafeed


  @current_page

  def initialize
    @current_page = login
  end



  def login
  	  m = Mechanize.new{|a|  a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE, a.gzip_enabled = false}
      page = m.get("https://jira.paypal.com")      
      puts "================================================= " + page.title
      
      form_login = page.forms.first
      form_login['login-form-username'] = "pborda"
      form_login['login-form-password'] = "pan.hot.red-503"
      form_login.submit
  
  end




  def jira_search(text)
      m = login
      m.forms.first['quickSearchInput'] = text
      bugs = m.forms.first.submit()
      bugs.links
  end


  def get_ticket_by_reference(reference)
  	my_links = jira_search(reference)
  	lnk = my_links.select {|l| l.text.include? reference }
  	ticket_text = lnk.click
  	puts ticket_text.body

  end


  def get_ticket_text()
      m = login
      m.page.forms.first['quickSearchInput'] = "missing tax"
      bugs = m.page.forms.first.submit()
      all_links = bugs.links.map {|l| l.text }
  end

end


end