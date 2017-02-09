$('#last_name_header').style.fontWeight= 'bold'

$('tr').click( function (){
	$('tr.selected').removeClass('selected');
	$(this).addClass('selected');
});