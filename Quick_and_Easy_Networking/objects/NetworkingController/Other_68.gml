/// @description Control Network
var n_id = ds_map_find_value(async_load, "id");         //get the ID of the socket receiving the data

//str_temp_data_feed_target += "\nAsync Event. server_socket is: "+string(global.server_socket)+" client_socket is: "+string(global.client_socket)+"\ncurrent socket is: "+string(n_id);

if (global.is_host == true)                                //check ID to make sure it is that of the server socket
{
	var t = ds_map_find_value(async_load, "type");          //get the type of network event
	var sock = ds_map_find_value(async_load, "socket");
	
    switch(t)
    {
	    case network_type_connect:
		{
	        ds_list_add(global.server_socket_list, sock);
			str_temp_data_feed_target += "\nA client has connected.";
			synchronize_all_entities();
		}	
	    break;
			
	    case network_type_disconnect:
		{
	        ds_map_delete(global.server_socket_list, sock);
			str_temp_data_feed_target += "\nA client has disconnected.";
		}
	     break;
			
	    case network_type_data:
		{
			str_temp_data_feed_target += "\nServer received data.";
			handleServerData();
		}
		break;
	}
}
else
{
	//Handle data as a client.
	var t = ds_map_find_value(async_load, "type");          //get the type of network event
	
	if (t == network_type_data)
	{
		handleClientData();
		str_temp_data_feed_target += "\nClient received data.";
	}
}
