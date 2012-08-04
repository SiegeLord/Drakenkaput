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
module game.components.Gun;

import engine.MathTypes;
import engine.Config;
import engine.Sprite;
import engine.ComponentHolder;

import game.GameObject;
import game.ILevel;

import game.components.IWeapon;
import game.components.Direction;
import game.components.Position;

import tango.io.Stdout;
import tango.text.convert.Format;
import tango.math.random.Random;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CGun : CGameComponent, IWeapon
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Direction, holder, this);
		RequireComponent(Position, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		auto name = ComponentName!(typeof(this));
		Duration = config.Get!(float)(name, "duration", 0.1);
		RangeVal = config.Get!(float)(name, "range", 32);
		Bullet = config.Get!(const(char)[])(name, "bullet", "");
		
		int n = 0;
		while(true)
		{
			auto str = Format("velocity_{}", n);
			auto vec = config.Get!(SVector2D)(name, str);
			if(vec.X == 0 && vec.Y == 0)
				break;
			LaunchVelocities ~= vec;
			n++;
		}
		
		Level = game_obj.Level;
		Time = &game_obj.Level.Game.Time;
		
		foreach(ii; 0..EDirection.NumDirections)
		{
			Offsets[ii] = config.Get!(SVector2D)(ComponentName!(typeof(this)), "offset_" ~ DirectionToString(cast(EDirection)ii));
		}
	}
	
	override
	@property
	float Range()
	{
		return RangeVal;
	}
	
	override
	void Fire()
	{
		if(Time() >= NextGoodTime)
		{
			NextGoodTime = Time() + Duration;
			foreach(vel; LaunchVelocities)
			{
				vel.Rotate(Direction.GetTheta());
				Level.LaunchBullet(Bullet, Position + Offsets[Direction], vel);
			}
		}
	}
	
	override
	@property
	bool Visible()
	{
		return Time() < NextGoodTime;
	}
	
	SVector2D GetOffset(EDirection dir)
	{
		return Offsets[dir];
	}
protected:
	SVector2D[EDirection.NumDirections] Offsets;
	CPosition Position;
	CDirection Direction;
	ILevel Level;

	double delegate() Time;
	float NextGoodTime = -float.infinity;
	float Duration = 0.1;
	float RangeVal;
	const(char)[] Bullet;
	SVector2D[] LaunchVelocities;
}

