
   function check(){
        var t = $("#correct").val().toString();
        var u = $("#verify").val().toString();
        $.get( "/validate_request", JSON.stringify({ "original_request": t, "compare_to": u })).done(function( data ) { 
            $("#result").html(data);  
          });
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






function fork_note(ticket,note_number) {

   alert(ticket + " " + note_number);

}


function view_ticket(ticket,note_number){

  alert(ticket + " " + note_number); 

}








   $(document).ready(function(){
   
$('#ppbutton').scroll(function() { 
    $('.followscroll').css('top', $(this).scrollTop());
});
   


  $('[data-slidepanel]').slidepanel({
              orientation: 'left',
              mode: 'overlay',
              static: false
          });


    $( ".accordion" ).accordion({
      collapsible: true,
      animate: 0
     });



   
      $ticket_process_stats = [];

      var latest_q = "";
    

      var processed = function(array,str){
        return (jQuery.grep(array,function (str){
                  return (this.matched==str);
                }).length > 0);
      }

      $('.editable').each(function(){
        this.contentEditable = true;
      });


       var parsecall = function(){        
        var currentText = $("#autocomplete1").html();
        $.post( "/parse", { ticket: currentText }).done(function( data ) {       
             //alert(JSON.stringify(data));
             console.log(data);
             if (!processed($ticket_process_stats,latest_q)){
               $ticket_process_stats.push({matched: latest_q.split(" ").last,parsed: true,render: true });
               if (!$("#autocomplete1").html().contains(latest_q)){
                 $("#autocomplete1").html($("#autocomplete1").html().replace(currentText,data));
                 $("#autocomplete1").focusEnd();
               }
               
            } 

          });
        
   

       }

       var delayed; 
       $("#autocomplete1").on('input', function() { times_parse=0;clearTimeout(delayed); delayed = setTimeout(function() {     
             parsecall();
           
        }, 1000); });


   

      $("#autocomplete1").keypress(function (e) {
        var key = e.which;
        if(key == 13)  // the enter key code
        {
          
          console.log($("#autocomplete1").html());
        }
       });   



var $ac =  $("#autocomplete1").autocomplete({
        isMultiline: true,
        delay: 300,
        minLength: 4,
        source: function(request, response) {       
          var separate_current_paragraphs = $("#autocomplete1").html().toString().replace("<br>","");
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

          // prevent autocomplete from updating the textbox
          //event.preventDefault();
          

          //alert(JSON.stringify(event));
          //alert(JSON.stringify(ui));
               

          // the .replace below needs to work only in the last matched typed string, not the previous ones

          var updated_text_content = $("#autocomplete1").text().substring(0,$("#autocomplete1").text().lastIndexOf(ui.item.q)) + "<br>";



          //$("#autocomplete1").val($("#autocomplete1").val().replace(ui.item.q,'') + '\r\n' + ui.item.knows);
          
          var ticket_text = updated_text_content + ui.item.knows;
          ticket = ticket_text;
          var note_number = ui.item.note_number;
          var ticket_number = ui.item.ticket_number;
       


          $.post('/record_selection',{"ticket_number": ticket_number, "note_number" : note_number,"findstr" : ui.item.q  });

          
          $("#autocomplete1").html(ticket.toString());
         
          

          $("#autocomplete1").focusEnd();


          // navigate to the selected item's url
          //window.open(ui.item.url);
        }
      });





        $ac.data("ui-autocomplete")._renderItem = function(ul, item) {
          var $a = $("<a></a>");
        

          var text_to_highlight = item.q.toString();
          var text_highlighted = item.knows.replace(text_to_highlight,("<label style=\"color: yellow!important;\">" + text_to_highlight + "</label>"));
          
          var ticket_number = item.ticket_number;
          var note_number = item.note_number;

          var mr = item.mr.toString();


          var markup = new EJS({url: '/suggestion_item.ejs'}).render({data: [note_number,ticket_number,text_highlighted,mr]});


           $a.append(markup);
      
           return $("<li></li>").append($a).appendTo(ul);
         };

        // $ac.data("ui-autocomplete")._move = function( direction, event ) {
        //   if ( !this.menu.element.is( ":visible" ) ) {
        //     this.search( null, event );
        //     return;
        //   }
        //   if ( this.menu.isFirstItem() && /^previous/.test( direction ) ||
        //     this.menu.isLastItem() && /^next/.test( direction ) ) {
        //     //this._value( this.term ); <-- Here it is!
        //     this.menu.blur();
        //     return;
        //   }
        //   this.menu[ direction ]( event );
        // }







     });
 

 //http://www.marcofolio.net/webdesign/a_fancy_apple.com-style_search_suggestion.html