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
module game.components.Sword;

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
import tango.math.random.Random;

import allegro5.allegro;
import allegro5.allegro_primitives;

class CSword : CGameComponent, IWeapon
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
		DamageType = config.Get!(const(char)[])(name, "damage_type", "");
		SwingDistance = config.Get!(float)(name, "swing_distance", 16);
		SwingWidth = config.Get!(float)(name, "swing_width", 32);
		MinDamage = config.Get!(float)(name, "min_damage", 1);
		MaxDamage = config.Get!(float)(name, "max_damage", 2);
		FireBreath = config.Get!(bool)(name, "fire_breath", false);
		FireBreathExplosion = config.Get!(const(char)[])(name, "fire_breath_explosion");
		
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
			SRect rect;
			float sd = SwingDistance;
			float sw = SwingWidth / 2;
			switch(Direction.Direction)
			{
				case EDirection.Right:
					rect.Set(0, -sw, sd, sw);
					break;
				case EDirection.Left:
					rect.Set(-sd, -sw, 0, sw);
					break;
				case EDirection.Up:
					rect.Set(-sw, -sd, sw, 0);
					break;
				case EDirection.Down:
					rect.Set(-sw, 0, sw, sd);
					break;
				default:
			}
			rect.Offset(Position.Position + GetOffset(Direction.Direction));
			
			Level.DamageRectangle(rect, DamageType, MaxDamage > MinDamage ? rand.uniformR2(MinDamage, MaxDamage) : MaxDamage, FireBreath);
			
			if(FireBreath)
				Level.SpawnExplosion(FireBreathExplosion, Position.Position + GetOffset(Direction.Direction), Direction.GetTheta());
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
	const(char)[] FireBreathExplosion;
	SVector2D[EDirection.NumDirections] Offsets;
	CPosition Position;
	CDirection Direction;
	ILevel Level;
	const(char)[] DamageType;
	float SwingDistance;
	float SwingWidth;
	float MinDamage;
	float MaxDamage;

	double delegate() Time;
	float NextGoodTime = -float.infinity;
	float Duration = 0.1;
	float RangeVal;
	bool FireBreath = false;
}

