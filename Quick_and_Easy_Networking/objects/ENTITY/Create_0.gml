/// @description Initialize
// Any object who inherits this parent will be synchronized.

// Only entities on the host's game will receive an ID in the create event.
if (global.is_host)
{
	global.entity_id_counter += 1;
	network_id = global.entity_id_counter;
	ds_map_add(global.local_entity_list, network_id, id);
}