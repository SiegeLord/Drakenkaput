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
module game.components.BulletAnimation;

import engine.MathTypes;
import engine.Config;
import engine.Sprite;
import engine.ComponentHolder;

import game.GameObject;

import game.components.Direction;
import game.components.Position;
import game.components.Velocity;

import tango.io.Stdout;
import tango.math.Math;
import allegro5.allegro;
 
class CBulletAnimation : CGameComponent
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
		RequireComponent(Velocity, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		game_obj.Level.DrawEvent.Register(&Draw, 1);
		
		foreach(dir; 0..EDirection.NumDirections)
		{
			auto sprite_str = DirectionToString(cast(EDirection)dir);
			auto sprite_file = config.Get!(const(char)[])(ComponentName!(typeof(this)), sprite_str, "");
			if(sprite_file == "")
				throw new Exception(config.Filename.idup ~ ":" ~ ComponentName!(typeof(this)).idup ~ "needs " ~ sprite_str.idup);
			Sprites[dir] = new CSprite(sprite_file, game_obj.Level.ConfigManager, game_obj.Level.BitmapManager);
		}
		
		Time = &game_obj.Level.Game.Time;
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.DrawEvent.UnRegister(&Draw);
	}
	
	void Draw()
	{
		auto sprite = Sprites[DirectionFromTheta(atan2(Velocity.Y, Velocity.X))];		
		sprite.Draw(Time(), Position.X, Position.Y);
	}
protected:
	double delegate() Time;
	
	CSprite[EDirection.NumDirections] Sprites;

	CPosition Position;
	CVelocity Velocity;
}
