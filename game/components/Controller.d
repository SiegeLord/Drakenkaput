/*
Copyright 2012 Pavel Sountsov

This file is part of TINSEngine.

TINSEngine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

TINSEngine is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with TINSEngine.  If not, see <http://www.gnu.org/licenses/>.
*/
module game.components.Controller;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;

import game.GameObject;
import game.components.Velocity;

import allegro5.allegro;

import tango.io.Stdout;
 
class CController : CGameComponent
{	
	this()
	{
		Left = Right = Up = Down = false;
		LastLeft = LastUp = false;
	}
	
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Velocity, holder, this);
	}
	
	void Input(ALLEGRO_EVENT* event)
	{
		float mag = 100;
		
		switch(event.type)
		{
			case ALLEGRO_EVENT_KEY_DOWN:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_UP:
						Up = true;
						LastUp = true;
						break;
					case ALLEGRO_KEY_DOWN:
						Down = true;
						LastUp = false;
						break;
					case ALLEGRO_KEY_LEFT:
						Left = true;
						LastLeft = true;
						break;
					case ALLEGRO_KEY_RIGHT:
						Right = true;
						LastLeft = false;
						break;
					default:
				}
				break;
			}
			case ALLEGRO_EVENT_KEY_UP:
			{
				switch(event.keyboard.keycode)
				{
					case ALLEGRO_KEY_UP:
						Up = false;
						break;
					case ALLEGRO_KEY_DOWN:
						Down = false;
						break;
					case ALLEGRO_KEY_LEFT:
						Left = false;
						break;
					case ALLEGRO_KEY_RIGHT:
						Right = false;
						break;
					default:
				}
				break;
			}
			default:
		}
		
		if((Left && !Right) || (Left && Right && LastLeft))
			Velocity.X = -mag;
		else if((Right && !Left) || (Left && Right && !LastLeft))
			Velocity.X = mag;
		else
			Velocity.X = 0;
			
		if((Up && !Down) || (Up && Down && LastUp))
			Velocity.Y = -mag;
		else if((Down && !Up) || (Up && Down && !LastUp))
			Velocity.Y = mag;
		else
			Velocity.Y = 0;
	}
protected:
	CVelocity Velocity;
	bool Left, Right, Up, Down;
	bool LastLeft, LastUp;
}
