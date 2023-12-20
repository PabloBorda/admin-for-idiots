{
  :addon => "account_number",
  :match_lambda => Proc.new { /([0-9]{19})/ },

  :render_lambda => Proc.new { |addon,matched|

                               (("<a name=\"" + addon.to_s + "\" href=\"" + (addon.to_s + "/" + matched.to_s) + "\">") + matched.to_s + "</a>")   # this could be an erb :mypage   call , and that page could have javascripts

                             },
  :modal => true,
  :on_mouse_over => Proc.new { |addon|
           "<script type=\"text/javascript\">"+ 
              "$(\"#{addon.to_s}\").mouseover(function(event){" +
                 "alert(#{addon.to_s});" + 
              "});" + 
           "</script>"

  }


}