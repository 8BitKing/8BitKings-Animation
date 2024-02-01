// 8BitKing's Animation
// Visit 8bitking.itch.io


// endactions dictate how an animation behaves once the image_index reaches out of the bounds of
// the Animation, either image_index >= image_number or image_index < 0;
// loop: This will just loop in the respective direction: 1>2>3 > 1>2>3 or 3>2>1 > 3>2>1
// bounce: This will reverse the animation: 1>2>3 > 3>2>1 > 1>2>3 > 3>2>1
// hold: This wild hold the last animation frame : 1>2>3 > 3>3>3 or 3>2>1 > 1>1>1 (image_speed is set to 0)
// next: If the Animation is in a Sequenze it will be destroyed so the next one can play
enum animation_endaction
{
	loop,
	bounce,
	hold,
	next
}


// This can either just draw a sprite wherever you want or can act as an container 
// to hold multiple animation that move as one and scale as one or fade as one (image_alpha)
// and play all at the same time at their own speeds. Properties popagade down the hirachy
// so an image_speed of .5 will half the speed of all children of this regardless of their own
// image_speed.
function Animation(_sprite_index = noone, _x = 0, _y = 0, _image_index = 0, _image_speed = 1, _endaction = animation_endaction.loop) constructor
{
	image_index = _image_index;
	image_speed = _image_speed;
	image_angle = 0;
	image_alpha = 1;
	image_xscale = 1;
	image_yscale = 1;
	image_blend = c_white;
	
	image_speed_direction = 1;
	endaction = _endaction;
	image_number = 0;
	x = _x;
	y = _y;
		
	stack = [];			
	
	static sprite_index_set = function(_sprite_index)
	{
		sprite_index = _sprite_index;
		sprite_speed = sprite_index == noone ? 0 : sprite_get_speed(sprite_index);
		sprite_speed_type = sprite_index == noone ? spritespeed_framespergameframe : sprite_get_speed_type(sprite_index);
		
		//this must be because otherwise it will not compile in YYC Compiler, it thinks image_number is a build in var
		self[$ "image_number"] = sprite_index == noone ? 0 : sprite_get_number(sprite_index);
	}
	
	sprite_index_set(_sprite_index);
	
	parent = noone;
	anim_endaction = function(_anim){};

	
	events = {};
	
	static event_add = function(_frame, _callback)
	{
		events[$ _frame] = _callback;
	}
	
	static add = function(_animation)
	{
		_animation.parent = self;
		array_push(stack, _animation);
		return _animation;
	}
	
	static destroy = function(_index)
	{
		return array_shift(stack);	
	}
	
	static empty = function()
	{
		stack = [];
	}
	
	static get = function(_index)
	{
		if (_index >= array_length(stack) or _index < 0) return undefined;
		
		return stack[_index];
	}

	static update = function(_speed_mult = 1)
	{		
		for (var _i = 0; _i < array_length(stack); _i++)
		{
		    var _elem = stack[_i];
			_elem.update(_speed_mult * image_speed);
		}		
		
		if (sprite_index == noone) return;
		
		update_animation(_speed_mult);
	}
	
	static update_animation = function(_speed_mult)
	{			
		var _frame = floor(image_index);
		var _speed = 0;
				
		switch (sprite_speed_type)
		{
			case spritespeed_framespergameframe:
				_speed = image_speed*sprite_speed*image_speed_direction*_speed_mult;
			break;
			case spritespeed_framespersecond:
				var _spd = (sprite_speed/game_get_speed(gamespeed_fps));
				_speed = image_speed*_spd*image_speed_direction*_speed_mult;
			break;
		}
		
		
		var _previous_image_index = image_index;
		image_index += _speed;					
		
		if (image_index >= image_number and image_speed_direction > 0)
		{
			if (parent != noone)
			{
				parent.anim_endaction(self);
			}		
			
			switch (endaction)
			{
				case animation_endaction.loop:					
					image_index = image_number - image_index;
				break;
				case animation_endaction.bounce:
					
					image_index = (image_number - 1) - (image_index - image_number);
					image_speed_direction = -1;
				break;
				case animation_endaction.hold:
					image_speed = 0;
					image_index = image_number-1;
				break;
				case animation_endaction.next:
					sprite_index = noone;
					image_speed = 0;
					image_index = image_number-1;
					return;
				break;
			}
			
			if (events[$ image_number] != undefined)
			{
				events[$ image_number]();
			}
			
		}
		else if (image_index <= 0 and image_speed_direction < 0 )
		{
			if (parent != noone)
			{
				parent.anim_endaction(self);
			}
			
			switch (endaction)
			{
				case animation_endaction.loop:
					image_index = image_number + image_index;
				break;
				case animation_endaction.bounce:
				
					image_index = (0 - image_index);
					image_speed_direction = 1;
				break;
				case animation_endaction.hold:
					image_speed = 0;
					image_index = 0;
				break;
				case animation_endaction.next:
					sprite_index = noone;
					image_speed = 0;
					image_index = 0;
					return;
				break;
			}
					
			if (events[$ image_number] != undefined)
			{
				events[$ image_number]();
			}
			
		}
		
		if (abs(image_index) < 0.001) image_index = 0;
		
		if (floor(image_index) != floor(_previous_image_index) and variable_struct_exists(events, floor(image_index)))
		{
			events[$ floor(image_index)]();
		}		
		
	}

	static draw = function(_xoffset = 0, _yoffset = 0, _xscale_mult = 1, _yscale_mult = 1, _angle_offset = 0, _blend_mult = c_white, _alpha_mult = 1)
	{
		for (var _i = 0; _i < array_length(stack); _i++)
		{
		    var _elem = stack[_i];
			_elem.draw(x + _xoffset, y + _yoffset, image_xscale * _xscale_mult, image_yscale * _yscale_mult, image_angle + _angle_offset, image_blend, image_alpha * _alpha_mult);
		}	
		
		if (sprite_index == noone) return;
		draw_sprite_ext(sprite_index, image_index, x + _xoffset, y + _yoffset, image_xscale * _xscale_mult, image_yscale * _yscale_mult, image_angle + _angle_offset, image_blend, image_alpha * _alpha_mult);
	}
}

// This is intendet to be used as an container to hold Animations. If these Animations have
// the endaction animation_endaction.next it will discard them at their last frame and starts
// playing the next one in order. Otherwise functions like the Animation.
function Animation_Sequence() : Animation() constructor
{	
	anim_endaction = function(_anim)
	{
		if (_anim.endaction == animation_endaction.next)
		{
			array_shift(stack);
		}
	}
	
	static update = function(_speed_mult = 1)
	{		
		if (array_length(stack) > 0)
		{
			stack[0].update(_speed_mult * image_speed);
		}
		
		if (sprite_index == noone) return;		
		update_animation(_speed_mult);	
	}
	
	static draw = function(_xoffset = 0, _yoffset = 0, _xscale_mult = 1, _yscale_mult = 1, _angle_offset = 0, _blend_mult = c_white, _alpha_mult = 1)
	{
		if (array_length(stack) > 0)
		{
			stack[0].draw(x + _xoffset, y + _yoffset, image_xscale * _xscale_mult, image_yscale * _yscale_mult, image_angle + _angle_offset, image_blend, image_alpha * _alpha_mult);
		}
		
		if (sprite_index == noone) return;
		draw_sprite_ext(sprite_index, image_index, x + _xoffset, y + _yoffset, image_xscale * _xscale_mult, image_yscale * _yscale_mult, image_angle + _angle_offset, image_blend, image_alpha * _alpha_mult);
	}
}