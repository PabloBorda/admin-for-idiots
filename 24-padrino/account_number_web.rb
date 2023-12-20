{
  :addon_name => "account_number",
  :type => "WEB",
  :matching_lambda => Proc.new { /([0-9]{19})/ },

  :render_lambda => Proc.new { |addon,matched|

                               (("<a name=\"" + addon.to_s + "\" href=\"" + (addon.to_s + "/" + matched.to_s) + "\">") + matched.to_s + "</a>")   # this could be an erb :mypage   call , and that page could have javascripts

                             },
  :modal => true,
  :on_mouse_over_lambda => Proc.new { |addon|
           "<script type=\"text/javascript\">"+ 
              "$(\"a[name='#{addon.to_s}']\").mouseover(function(){" +
                 "alert(\"#{addon.to_s}\");" + 
              "});" + 
           "</script>"

  },
  :helper_methods_exposed_to_url => [{ :account_number => Proc.new { |params|
                                             redirect "https://admin.paypal.com/cgi-bin/admin?node=loaduserpage_home&account_number=" + params[:account_number].to_s + "&page_selector=ar_home"
                                           }
                      }                   
  ]


}