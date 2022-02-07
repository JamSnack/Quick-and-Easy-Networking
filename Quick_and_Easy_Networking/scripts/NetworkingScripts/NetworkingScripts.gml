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
	
	var server = network_connect_async(global.client_socket , ip_address, port);
	
	if server < 0
	{
		NetworkingController.str_temp_data_feed_target += "Failed to connect to "+string(ip_address);
	}
	else
	{
		//Connected!
		NetworkingController.str_temp_data_feed_target += "\nConnected to "+string(ip_address)+" on port " + string(port) + " successfully.";
		global.is_host = false;
		global.draw_networking_debug_status = true;
		
		create_entity(100,100,"Instances",obj_player);
	}	
}

function send_data(data, target, packet_id)
{
	if ( !is_string(data) && ds_exists(data, ds_type_map))
	{
		data = json_stringify(data);
		show_debug_message("send_data> stringified some data!");
	}
	
	switch (target)
	{
		//Send information to all clients from the server
		case "CLIENT_ALL":
		{
			if (global.is_host == true)
			{
				var t_buffer = buffer_create(256, buffer_grow, 1);
				buffer_seek(t_buffer, buffer_seek_start, 0);
				buffer_write(t_buffer , buffer_u8, packet_id);
				
				var data_type = is_string(data) ? buffer_string : buffer_u16;
				
				buffer_write(t_buffer, data_type, data);
	

				for (var i = 0; i < ds_list_size(global.server_socket_list); ++i;)
				{
					network_send_packet(ds_list_find_value(global.server_socket_list, i), t_buffer, buffer_tell(t_buffer));
				}
	
				buffer_delete(t_buffer);
			}
		}
		break;
		
		
		//Send information to the server from the client
		case "SERVER":
		{
			if (global.is_host == false)
			{
				var t_buffer = buffer_create(256, buffer_grow, 1);
				buffer_seek(t_buffer, buffer_seek_start, 0);
				buffer_write(t_buffer , buffer_u8, packet_id);
				
				var data_type = is_string(data) ? buffer_string : buffer_u16;
				
				buffer_write(t_buffer, data_type, data);
	
				network_send_packet(global.client_socket, t_buffer, buffer_tell(t_buffer));
	
				buffer_delete(t_buffer);
			}
		}
		break;
	}
	
}

function handleServerData()
{
	//Handle data received from clients!
	var t_buffer = ds_map_find_value(async_load, "buffer");
	var cmd_type = buffer_read(t_buffer, buffer_u8 );
	//var inst = ds_map_find_value(global.server_socket_list, async_load[? "socket"]);
			
	switch (cmd_type)
	{
		case PACKET_ID.msg:
		{
			var data = buffer_read(t_buffer, buffer_string);
			if is_string(data) then str_temp_data_feed_target += "\n"+data else str_temp_data_feed_target += "\nReceived a non-string.";
		}
		break;
		
		case PACKET_ID.entity_create_request:
		{
			var data = buffer_read(t_buffer, buffer_string);
			var data_map = json_parse(data);
			var _inst = instance_create_layer(data_map[? "x"], data_map[? "y"], "Instances", data_map[? "object_index"]);
			
			create_entity(_inst.x, _inst.y, "Instances", _inst.object_index);
		}
		break;
	}
}

function handleClientData()
{
	//Handle data received from the server!
	var t_buffer = ds_map_find_value(async_load, "buffer"); 
	var cmd_type = buffer_read(t_buffer, buffer_u8 );
	//var inst = ds_map_find_value(global.server_socket_list, async_load[? "socket"]);
			
	switch (cmd_type)
	{
		case PACKET_ID.entity_sync:
		{
			var data = buffer_read(t_buffer, buffer_string);
			
			data = json_parse(data);
			
			if ( data != undefined && ds_exists(data, ds_type_map) )
			{
				if (!ds_map_empty(data))
				{
					if (data[? "network_id"] != undefined)
					{
						var e_id = global.local_entity_list[? data[? "network_id"]];
						
						if (is_undefined(e_id))
						{
							e_id = instance_create_layer(data[? "x"], data[? "y"], "Instances", data[? "object_index"]);
						}
						
						with (e_id)
						{
							var vars = variable_instance_get_names(e_id);
							
							for(var _z = 0; _z < array_length(vars); _z++)
							{
								variable_instance_set( e_id, vars[_z], data[? string(vars[_z]) ] );
							}
						}
						
					} 
					else NetworkingController.str_temp_data_feed_target += "\nhandleClientPacket> Error. network_id is: "+string(data[? "network_id"]);
				} 
				else NetworkingController.str_temp_data_feed_target += "\nhandleClientPacket> Data is empty.";
			} 
			else NetworkingController.str_temp_data_feed_target += "\nhandleClientPacket> Data is undefined or does not exist.";
		} 
		break;
	}
}

function get_all_instance_values_from_list(variable_list, inst_id)
{
	if (variable_list != undefined)
	{
		var _map = ds_map_create();
		
		for(var _z = 0; _z < array_length(variable_list); _z++)
		{
			ds_map_add(_map, variable_list[_z], variable_instance_get(inst_id, variable_list[_z]) );
		}
		
		return _map;
	}
}

function synchronize_all_entities()
{
	//Find every entity, send their data to the clients, else request instance data
	if (global.is_host)
	{
		//send data
		for (var _e = 0; _e < instance_number(ENTITY); _e++)
		{
			var _inst = instance_find(ENTITY, _e);
			
			if (_inst != noone)
			{
				var var_list = variable_instance_get_names(_inst);
				var var_map = get_all_instance_values_from_list(var_list, _inst);
				
				ds_map_add(var_map, "x", _inst.x);
				ds_map_add(var_map, "y", _inst.y);
				ds_map_add(var_map, "network_id", _inst.network_id);
			
				send_data(var_map, "CLIENT_ALL", PACKET_ID.entity_sync);
			
				NetworkingController.str_temp_data_feed_target += "\nSyncing entities...";
				NetworkingController.str_temp_data_feed_target += "Entity.net_id is: "+string(var_map[? "network_id"]);
			}
		}
	}
	else
	{
		//request data	
	}
}

function variable_instance_get_all(inst)
{
	var var_list = variable_instance_get_names(inst);
	var var_map = get_all_instance_values_from_list(var_list,inst);
	
	ds_map_add(var_map, "x", inst.x);
	ds_map_add(var_map, "y", inst.y);
	ds_map_add(var_map, "object_index", inst.obj);
	ds_map_add(var_map, "sprite_index", inst.sprite_index);
	ds_map_add(var_map, "image_index", inst.image_index);
	
	return var_map;
}

function create_entity(_x, _y, layer_id_or_name, obj)
{
	//Define the mob
	var var_map = ds_map_create();
	
	ds_map_add(var_map, "x", _x);
	ds_map_add(var_map, "y", _y);
	ds_map_add(var_map, "object_index", obj);
	
	if (global.is_host)
	{	
		var _inst = instance_create_layer(_x, _y, layer_id_or_name, obj);
		var var_list = variable_instance_get_names(_inst);
		
		var_map = get_all_instance_values_from_list(var_list, _inst);
		ds_map_add(var_map, "network_id", _inst.network_id);
			
		send_data(var_map, "CLIENT_ALL", PACKET_ID.entity_sync);
	}
	else
	{
		send_data(var_map,"SERVER", PACKET_ID.entity_create_request);
	}
}
