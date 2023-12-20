{
  :addon_name => "ticket_number",
  :type => "WEB",
  :matching_lambda => Proc.new { /(([0-9]{6})-([0-9]{6}))/ },

  :render_lambda => Proc.new { |addon,matched|

                               (("<a name=\"" + addon.to_s + "\" href=\"" + (addon.to_s + "/" + matched.to_s) + "\">") + matched.to_s + "</a>")   # this could be an erb :mypage   call , and that page could have javascripts

                             },
  :modal => true,
  :on_mouse_over_lambda => Proc.new { |addon|
           "<script type=\"text/javascript\">"+ 
              "$(\"#{addon.to_s}\").mouseover(function(event){" +
                 "alert(addon.to_s);" + 
              "});" + 
           "</script>"

  },
  :helper_methods_exposed_to_url => [{ :ticket_number => Proc.new {|params|
 
    redirect "https://mts/wnvp/?method=GetRightNowTicketDetails&Custom=" + params[:ticketnum].to_s + "&ref_num=" + params[:ticketnum].to_s + "&dojo.preventCache=1420544362909"

  }}]







}