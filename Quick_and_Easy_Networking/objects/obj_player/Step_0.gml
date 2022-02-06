/// @description Insert description here
// You can write your code in this editor

var key_right = (keyboard_check(ord("D")) || keyboard_check(vk_right));
var key_left = (keyboard_check(ord("A")) || keyboard_check(vk_left));
var key_up = (keyboard_check(ord("W")) || keyboard_check(vk_up));
var key_down = (keyboard_check(ord("S")) || keyboard_check(vk_down));

var h_move = (key_right - key_left);
var v_move = (key_down - key_up);


//Horizontal movement and collisions
var _hspd = h_move * walkspeed;

if (h_move != 0)
{
	if (collision_rectangle(bbox_left + _hspd, bbox_top, bbox_right + _hspd, bbox_bottom, OBSTA, false, false))
	{
		var _hdir = sign(_hspd);
		
		while !(collision_rectangle(bbox_left + _hdir, bbox_top, bbox_right + _hdir, bbox_bottom, OBSTA, false, false))
		{
			x += _hdir;	
		}
		
		_hspd = 0;
	}
}

x += _hspd;


//Vertical movement and collisions
var _vspd = v_move * walkspeed;

if (v_move != 0)
{
	if (collision_rectangle(bbox_left, bbox_top + _vspd, bbox_right, bbox_bottom + _vspd, OBSTA, false, false))
	{
		var _vdir = sign(_vspd);
		
		while !(collision_rectangle(bbox_left, bbox_top + _vdir, bbox_right, bbox_bottom + _vdir, OBSTA, false, false))
		{
			y += _vdir;	
		}
		
		_vspd = 0;
	}
}

y += _vspd;	