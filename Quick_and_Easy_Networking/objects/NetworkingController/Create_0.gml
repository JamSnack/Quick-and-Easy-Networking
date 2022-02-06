/// @description Initialize NetworkingController

global.draw_networking_debug_status = false; //Whether or not to draw networking stats to the screen.
global.ping = -1; //How much ping you have.
global.is_host = false; //Whether or not the current game is hosting. NOTE: This may or may not dynamically change in the future.
global.server_socket = -1; //This will eventually hold a client's connection to the server, or it will be initialzied via startServer();
global.client_socket = -1;
global.server_socket_list = ds_list_create();

//ENTITY SYSTEM
global.entity_id_counter = 0; //Increases everytime the host creates a new entity. Will be paired with that entity's local instance ID.
global.local_entity_list = ds_map_create(); //Takes in an entity_id as a key and accesses the local game's copy of that instance (instance ID).


//Other local variables
str_temp_data_feed = ""; //A string that is drawn in the DRAW GUI event which displays certain debug information.
str_temp_data_feed_target = "NetworkingController Initialized."; //The string that is slowly added to str_temp_data_feed. See step event.
temp_data_delay = 0; //A timer variable that controls how many steps must be taken before we add another character from temp_data_target to temp_data_feed..
temp_data_erase_delay = 0; //A timer variable that will reset temp_data_feed and temp_data_target when it reaches 0.