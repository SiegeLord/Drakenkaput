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
module game.components.Velocity;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;

import game.GameObject;
import game.components.Position;
import game.components.Collision;

import tango.io.Stdout;
 
class CVelocity : CGameComponent
{	
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
		holder.Get(Collision);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		GameObject = game_obj;
		game_obj.Level.LogicEvent.Register(&Logic);
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.LogicEvent.UnRegister(&Logic);
	}
	
	void Logic(float dt)
	{
		if(Collision is null)
		{
			Position.Position += Velocity * dt;
		}
		else
		{
			if(Velocity != SVector2D(0, 0))
			{
				auto new_pos = Position.Position + Velocity * dt;
				Position.Position = GameObject.Level.CollisionManager.Move(Collision, Position.Position, new_pos);
			}
		}
	}
	
	alias Velocity this;
	SVector2D Velocity;
protected:
	CGameObject GameObject;
	CPosition Position;
	CCollision Collision;
}
