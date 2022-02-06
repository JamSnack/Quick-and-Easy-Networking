// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function startServer(port, max_clients)
{
	global.server_socket = network_create_server(network_socket_tcp, port, max_clients);

	while (global.server_socket < 0 && port < 65535)
	{
	    port++;
	    global.server_socket = network_create_server(network_socket_tcp, port, max_clients);
	}
	
	
	//Change some NetworkingController variables if the server was created successfully, else show failure message.
	if (global.server_socket > 0)
	{
		global.is_host = true;
		global.draw_networking_debug_status = true;
		
		NetworkingController.str_temp_data_feed_target += "\nServer created successfully!\nPort: "+string(port);
	}
	else
	{
		NetworkingController.str_temp_data_feed_target += "\nFailed to create the server."
	}
}

function joinServer(ip_address, port)
{
	global.client_socket = network_create_socket(network_socket_tcp);
	
	var server = network_connect(global.client_socket , ip_address, port);
	
	if server < 0
	{
		NetworkingController.str_temp_data_feed_target += "Failed to connect to "+string(ip_address);
	}
	else
	{
		//Connected!
		NetworkingController.str_temp_data_feed_target += "\nConnected to "+string(ip_address)+" successfully.";
		global.is_host = false;
		global.draw_networking_debug_status = true;
	}	
}

function synchronize_all_entities()
{
	//Find every entity, send their data to the clients.
	if (global.is_host)
	{
		with (ENTITY)
		{
			var data = variable_instance_get_names(id);
			
			for (_d = 0; _d < array_length(data); _d++)
			{
				//data[_d]	
			}
		}
	}
}

/*function send_data(data_array)
{
	var t_buffer = buffer_create(256, buffer_grow, 1);
	buffer_seek(t_buffer, buffer_seek_start, 0);
	buffer_write(t_buffer , buffer_u16, IDENTIFIER_CONSTANT);
	buffer_write(t_buffer , buffer_string,”Hello”);

	for (var i = 0; i < ds_list_size(socketlist); ++i;)
	    {
	    network_send_packet(ds_list_find_value(socket_list, i), t_buffer, buffer_tell(t_buffer));
	    }
	buffer_delete(t_buffer);	
}