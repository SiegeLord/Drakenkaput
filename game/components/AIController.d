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
module game.components.AIController;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;

import game.GameObject;
import game.ILevel;
import game.components.Velocity;
import game.components.Direction;
import game.components.Moving;
import game.components.Position;
import game.components.Collision;
import game.components.IWeapon;

import allegro5.allegro;

import tango.io.Stdout;
import tango.math.Math;
import tango.math.random.Random;

enum EState
{
	Chasing,
	Fleeing,
	Wandering
}
 
class CAIController : CGameComponent
{	
	this()
	{
		Left = Right = Up = Down = false;
		State = EState.Wandering;
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		Level = game_obj.Level;
		Level.LogicEvent.Register(&Logic);
		
		SenseRange = config.Get!(float)(ComponentName!(typeof(this)), "sense_range", 100);
		WanderProb = config.Get!(float)(ComponentName!(typeof(this)), "wander_prob", 0.6);
		PrefRangeFrac = config.Get!(float)(ComponentName!(typeof(this)), "pref_range_frac", 0.6);
		Speed = config.Get!(float)(ComponentName!(typeof(this)), "speed", 20);
		WeaponLineup = config.Get!(float)(ComponentName!(typeof(this)), "weapon_lineup", 20);
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		Level.LogicEvent.UnRegister(&Logic);
	}
	
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Velocity, holder, this);
		RequireComponent(Position, holder, this);
		RequireComponent(Collision, holder, this);
		GetComponent(Direction, holder, this);
		GetComponent(Moving, holder, this);
		GetComponent(Weapon, holder, this);
	}
	
	void Logic(float dt)
	{
		float mag = Speed;
		
		auto player = Level.Player;
		
		Up = Down = Left = Right = false;
		
		bool no_player = false;
		
		if(player !is null)
		{
			auto player_col = player.Get!(CCollision)();
			assert(player_col);
			auto player_pos = player_col.WorldCenter;
			auto my_pos = Collision.WorldCenter;
			SVector2D dir = player_pos - my_pos;
			if(dir.LengthSq < SenseRange * SenseRange)
			{
				State = EState.Chasing;
				
				if(Weapon !is null)
				{
					auto pref_range = PrefRangeFrac * Weapon.Range;
					auto weapon_dir = player_pos - Position;
					if(Direction !is null)
						weapon_dir -= Weapon.GetOffset(Direction);

					if(weapon_dir.LengthSq < pref_range * pref_range || Level.Dragon())
						State = EState.Fleeing;
					
					if(State == EState.Chasing && weapon_dir.LengthSq < Weapon.Range * Weapon.Range)
					{
						if(abs(weapon_dir.X) < WeaponLineup || abs(weapon_dir.Y) < WeaponLineup)
						{
							Weapon.Fire();
						}
					}
				}
				
				if(State == EState.Fleeing)
					dir = -dir;
				
				if(State != EState.Wandering)
					MoveDirection = dir;
			}
			else
			{
				no_player = true;
			}
		}
		else
		{
			no_player = true;
		}
			
		if(no_player)
		{
			if(State != EState.Wandering)
				MoveDirection.Set(0, 0);
			State = EState.Wandering;
		}
		
		float buffer = 8;
		
		if(State == EState.Wandering && rand.uniformR(1.0) < WanderProb * dt)
		{
			if(rand.uniformR(1.0) < 0.5)
			{
				MoveDirection.Set(buffer + 1.0, 0.0);
				MoveDirection.Rotate(rand.uniformR(2 * PI));
			}
			else
			{
				MoveDirection.Set(0, 0);
			}
		}
		
		if(MoveDirection.X > buffer)
			Right = true;
		else if(MoveDirection.X < -buffer)
			Left = true;
		
		if(MoveDirection.Y > buffer)
			Down = true;
		else if(MoveDirection.Y < -buffer)
			Up = true;
		
		void set_dir(EDirection dir)
		{
			if(Direction !is null)
				Direction = dir;
		}
		
		void set_move(bool moving)
		{
			if(Moving !is null)
			{
				Moving = moving;
			}
		}
		
		bool no_x = false;
		set_move(true);
		
		if((Left && !Right))
		{
			Velocity.X = -mag;
			set_dir(EDirection.Left);
		}
		else if((Right && !Left))
		{
			Velocity.X = mag;
			set_dir(EDirection.Right);
		}
		else
		{
			Velocity.X = 0;
			no_x = true;
		}
			
		if((Up && !Down))
		{
			Velocity.Y = -mag;
			set_dir(EDirection.Up);
		}
		else if((Down && !Up))
		{
			Velocity.Y = mag;
			set_dir(EDirection.Down);
		}
		else
		{
			Velocity.Y = 0;
			set_move(!no_x);
		}
	}
protected:
	float SenseRange = 100;
	float WanderProb = 0.6;
	float PrefRangeFrac = 0.5;
	float Speed;
	float WeaponLineup;

	EState State;
	SVector2D MoveDirection;
	
	ILevel Level;
	CVelocity Velocity;
	CDirection Direction;
	CPosition Position;
	CCollision Collision;
	CMoving Moving;
	IWeapon Weapon;
	bool Left, Right, Up, Down;
}
