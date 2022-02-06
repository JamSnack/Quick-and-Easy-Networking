/// @description Networking debug status

//------- Draw networking debug status --------

if (global.draw_networking_debug_status == true)
{
	var str_ping = global.ping == -1 ? "Not responding or host." : "Ping: "+string(global.ping);
	
	draw_set_color(c_white);
	draw_text(3,10,str_ping);
	draw_text(3,21,"is_host: "+string(global.is_host));
}

//Draw the temporary data feed
draw_set_valign(fa_top);
draw_text( 3, display_get_gui_height()-20-string_height(str_temp_data_feed), str_temp_data_feed);
draw_set_valign(fa_middle);
