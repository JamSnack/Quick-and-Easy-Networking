/// @description Insert description here
// Manage the temporary data feed (important for displaying debug information)
if (str_temp_data_feed != str_temp_data_feed_target && temp_data_delay <= 0)
{
	var _pos = string_length(str_temp_data_feed);
	str_temp_data_feed += string_char_at(str_temp_data_feed_target, _pos+1);
	
	//Restart the timer
	temp_data_delay = 1;
	temp_data_erase_delay = room_speed*10;
}
else
{
	temp_data_delay -= 1;
	temp_data_erase_delay -= 1;
}

// - erase temp_data_feed
if (temp_data_erase_delay <= 0)
{
	str_temp_data_feed = "";
	str_temp_data_feed_target = "";
}