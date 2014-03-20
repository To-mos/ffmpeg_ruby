$(function()
{
  $('#uploadNew').on('mousedown',function(){
    $(this).parent().append(
      "<br /><input type=\"text\" name=\"urls[]\" placeholder='http://' />"
      );
  }); 
});