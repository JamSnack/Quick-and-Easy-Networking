/// @description Control Network

var n_id = ds_map_find_value(async_load, "id");         //get the ID of the socket receiving the data

if (n_id == global.server_socket)                                //check ID to make sure it is that of the server socket
{
	var t = ds_map_find_value(async_load, "type");          //get the type of network event
	
	if t == network_type_connect                            //if it is a connect event 
	{                                                   //get the socket ID of the connection
		var sock = ds_map_find_value(async_load, "socket"); //and store it in a variable
		ds_list_add(global.server_socket_list, sock);                      //then write it to a DS list for future reference
			
		str_temp_data_feed_target += "\nA client has connected to the server.";
	}
}
