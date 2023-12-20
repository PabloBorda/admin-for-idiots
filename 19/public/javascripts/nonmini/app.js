
   function check(){
        var t = $("#correct").val().toString();
        var u = $("#verify").val().toString();
        $.get( "/validate_request", JSON.stringify({ "original_request": t, "compare_to": u })).done(function( data ) { 
            $("#result").html(data);  
          });
   }
 



var levenshtein = function(s, t) {
    var d = []; //2d matrix

    // Step 1
    var n = s.length;
    var m = t.length;

    if (n == 0) return m;
    if (m == 0) return n;

    //Create an array of arrays in javascript (a descending loop is quicker)
    for (var i = n; i >= 0; i--) d[i] = [];

    // Step 2
    for (var i = n; i >= 0; i--) d[i][0] = i;
    for (var j = m; j >= 0; j--) d[0][j] = j;

    // Step 3
    for (var i = 1; i <= n; i++) {
        var s_i = s.charAt(i - 1);

        // Step 4
        for (var j = 1; j <= m; j++) {

            //Check the jagged ld total so far
            if (i == j && d[i][j] > 4) return n;

            var t_j = t.charAt(j - 1);
            var cost = (s_i == t_j) ? 0 : 1; // Step 5

            //Calculate the minimum
            var mi = d[i - 1][j] + 1;
            var b = d[i][j - 1] + 1;
            var c = d[i - 1][j - 1] + cost;

            if (b < mi) mi = b;
            if (c < mi) mi = c;

            d[i][j] = mi; // Step 6

            //Damerau transposition
            if (i > 1 && j > 1 && s_i == t.charAt(j - 2) && s.charAt(i - 2) == t_j) {
                d[i][j] = Math.min(d[i][j], d[i - 2][j - 2] + cost);
            }
        }
    }

    // Step 7
    return d[n][m];
}



$.fn.focusEnd = function() {
    $(this).focus();
    var tmp = $('<span />').appendTo($(this)),
        node = tmp.get(0),
        range = null,
        sel = null;

    if (document.selection) {
        range = document.body.createTextRange();
        range.moveToElementText(node);
        range.select();
    } else if (window.getSelection) {
        range = document.createRange();
        range.selectNode(node);
        sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
    }
    tmp.remove();
    return this;
}





function load_ticket_by_number(){
  var ticket_number = $("#find_by_ticket_number_field").val();
  $.get("/find_ticket",{"ticket_number" : ticket_number.toString()}).done(function(data){
 
    console.log(JSON.stringify(data));
   // remove_garbage = data.substring(0,52);
    //make_valid_json = "{" + remove_garbage
    my_note = JSON.parse(data);
   if (my_note!=null){
   // build_editor("",my_note.RightNowTicket.length);
    for (var i in my_note.RightNowTicket){
      console.log("LOADING NOTE " + JSON.stringify(my_note.RightNowTicket[i]));
      build_editor(my_note.RightNowTicket[i],i);
      parser_updater(i);
    }
   } else {
    alert("Input ticket number");
   }

  });
  

}





function fork_note(ticket,note_number) {

   alert(ticket + " " + note_number);

}


function view_ticket(ticket,note_number){

  alert(ticket + " " + note_number); 

}




function imgError(image) {
    image.onerror = "";
    image.src = "/images/nopic.png";
    return true;
}


function freshStyle(stylesheet){
   $('.questions').attr('href',stylesheet);
}



function parser_updater(note_number){
  var search_string = "#autocomplete" + note_number.toString(); 
  

  var parsecall = function (){
    var currentText = $(search_string).html();  
    $.post( "/parse", { ticket: currentText }).done(function( data ) {
      var new_data = $(search_string).html().toString().replace(currentText,data);
      console.log(data);     
      $(search_string).html(new_data);
      $(search_string).focusEnd();                  
    });
  }


  $(search_string).trigger("input");

  var delayed;
  $(search_string).on('input', function() { times_parse=0;clearTimeout(delayed); delayed = setTimeout(function() {     
    parsecall();           
  }, 1000); });
        
  $(search_string).keypress(function (e) {
    var key = e.which;
    if(key == 13)  // the enter key code
    {         
      console.log($(search_string).html());
    }
  });   
 
}


    function build_editor(note,note_number){ 
       
         var search_string = "#autocomplete" + note_number.toString(); 
         var search_string_node_javascript_version = "autocomplete" + note_number.toString();
         var currentText = $(search_string).html();
           




         var date = note.DateEntered;
         var contact_email = note.ContactEmail;
         var severity = note.Severity;
         var who_writes = note.AccountID;
         var status = note.Status;
         if ((who_writes!=undefined)&&(who_writes!="")){
           var who_writes_name_and_lastname_separated = who_writes.split(" ");
           var who_writes_possible_user_name = who_writes_name_and_lastname_separated[0].charAt(0).toLowerCase() + who_writes_name_and_lastname_separated[1].toLowerCase();

         } else {
          if (note_number==0){
            who_writes = "User Typing";

          } else {
          who_writes = "Unknown Person";
          }
         }
 


         var pic_url = "http://myhub.corp.ebay.com/User%20Photos/Profile%20Pictures/_w/corp_" + who_writes_possible_user_name + "_MThumb_jpg.jpg"


         var build_editor_html = new EJS({url: '/new_editor.ejs'}).render({data: [pic_url,who_writes,note_number,date,status]});
         
         

         build_editor_html = $($.parseHTML(build_editor_html));
        
         $(".questions").append(build_editor_html);
         $(search_string).html($.parseHTML(note.Note));
         $(".questions").accordion("refresh");



         

  

         var $ac =  $(search_string).autocomplete({
            isMultiline: true,
            delay: 300,
            minLength: 4,
            source: function(request, response) {       
              var separate_current_paragraphs = $(search_string).html().toString().replace("<br>","");
              console.log ("Separate current paragraphs" + JSON.stringify(separate_current_paragraphs));
             // latest_words = separate_current_paragraphs[separate_current_paragraphs.length - 1].toString().split(" ");
              //latest_words_as_string = (latest_words[latest_words.length-1] + " " + latest_words[latest_words.length-2]);                
              var last_paragraph = separate_current_paragraphs[separate_current_paragraphs.length - 1];
              console.log ("Last last_paragraph: " + last_paragraph);
              //parsecall();
              latest_q = separate_current_paragraphs
              $.getJSON("/suggest_me", {                  
                q: separate_current_paragraphs
               //q: request.term
              }, function(data) {
                // data is an array of objects and must be transformed for autocomplete to use
                var array = data.error ? [] : $.map(data.suggestions, function(m) {
                  return {
                    q: m.q,
                    mr: m.mr,
                    knows: m.knows,
                    for_: m.for,
                    ticket_number: m.ticket_number,               
                    note_number: m.note_number,
                    selection_counter: m.selection_counter
                
                  };
                });
                response(array);
              });
            },
            focus: function(event, ui) {
              // prevent autocomplete from updating the textbox
              event.preventDefault();
            },
            search: function(event,ui){
              //parsecall();

            },
            select: function(event, ui) { 
                  var updated_text_content = $(search_string).text().substring(0,$(search_string).text().lastIndexOf(ui.item.q)) + "<br>";
                  var ticket_text = updated_text_content + ui.item.knows;
                  ticket = ticket_text;
                  var note_number = ui.item.note_number;
                  var ticket_number = ui.item.ticket_number;
    
                  $.post('/record_selection',{"ticket_number": ticket_number, "note_number" : note_number,"findstr" : ui.item.q  });
               
                  $(search_string).html(ticket.toString());                 
  
                  $(search_string).focusEnd();
                }
         });
  

         $ac.autocomplete("instance")._renderItem = function(ul, item) {
           var $a = $("<a></a>");
       

           var segmented_query = item.q.toString().split(" ");
           var text_to_highlight = item.knows.split(" ");
           var text_highlighted = "";
            
           for (var i in segmented_query){

             for (var j in text_to_highlight){
               if (segmented_query[i]==text_to_highlight[j]){
                 text_highlighted = text_highlighted + " <label style=\"color: yellow!important;\">" + text_to_highlight[j] + "</label> ";
               } else {
                 text_highlighted = text_highlighted + " " + text_to_highlight[j] + " ";
               }

             }


           }
                   
           var ticket_number = item.ticket_number;
           var note_number = item.note_number;

           var mr = item.mr.toString();

           var markup = new EJS({url: '/suggestion_item.ejs'}).render({data: [note_number,ticket_number,text_highlighted,mr]});
             $a.append(markup);
      
             return $("<li></li>").append($a).appendTo(ul);
         };   


          

     }






   $(document).ready(function(){

     var latest_q = "";
   
     $('#ppbutton').scroll(function() { 
        $('.followscroll').css('top', $(this).scrollTop()); 
     });
   

     $('[data-slidepanel]').slidepanel({
        orientation: 'left',
        mode: 'overlay',
        static: false
     });

//   ------------------------------------ACCORDION STUFF--------------------------------------
     $( "> div", "#questionsDispos" ).draggable({
        helper: "clone",
        revert: "invalid",
        cursor: "move",
        handle: "h3",
        connectToSortable: ".questions"
    });
    
    $( ".questions" ).accordion({
        header: "> div > h3",
        collapsible: true,
        animate: false,
        active: false,
        autoHeight: false,
        autoActivate: true
    });
    
    $( ".questions" ).sortable({
        axis: "y",
        handle: "h3",
        items: "div",
        receive: function(event, ui) {
            $(ui.item).removeClass();
            $(ui.item).removeAttr("style");
            $( ".questions" ).accordion("add", "<div>" + ui.item.hmtl() + "</div>");
        }
    });
    

    
// ----------------------------------------------------------------------------------------



   });  
 //http://www.marcofolio.net/webdesign/a_fancy_apple.com-style_search_suggestion.html