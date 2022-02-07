/// @description INITIALIZE NEW HOST


//Make sure all entities have an entity ID.
if (!instance_exists(obj_player))
{
	create_entity(100,100, "Instances",obj_player);	
}

/*global.entity_id_counter = 0;

with (ENTITY)
{
	global.entity_id_counter++;
	network_id = global.entity_id_counter;
}
