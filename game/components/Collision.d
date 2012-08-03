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
module game.components.Collision;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;
import engine.Util;

import game.ICollisionManager;
import game.GameObject;
import game.components.Position;

import tango.io.Stdout;
 
class CCollision : CGameComponent
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		CollisionRect = SRect(config.Get!(SVector2D)(ComponentName!(typeof(this)), "top_left", SVector2D(0, 0)),
		                      config.Get!(SVector2D)(ComponentName!(typeof(this)), "bottom_right", SVector2D(0, 0)));
		Holder = game_obj.Level.CollisionManager.AddCollision(this);
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.CollisionManager.RemoveCollision(this, Holder);
	}
	
	@property
	SRect WorldCollisionRect()
	{
		return SRect(CollisionRect.Min + Position.Position, CollisionRect.Max + Position.Position);
	}
	
	@property
	SVector2D WorldCenter()
	{
		return (CollisionRect.Min + CollisionRect.Max) / 2 + Position.Position;
	}
	
	mixin(Prop!("SRect", "CollisionRect", "", "protected"));
protected:
	CPosition Position;
	SRect CollisionRectVal;
	TColHolder Holder;
}

