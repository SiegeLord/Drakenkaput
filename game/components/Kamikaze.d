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
module game.components.Kamikaze;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;
import engine.Util;

import game.GameObject;
import game.components.Position;

import tango.io.Stdout;
import tango.math.random.Random;

class CKamikaze : CGameComponent
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		auto name = ComponentName!(typeof(this));
		CollisionRect = SRect(config.Get!(SVector2D)(name, "top_left", SVector2D(0, 0)),
		                      config.Get!(SVector2D)(name, "bottom_right", SVector2D(0, 0)));
		DamageType = config.Get!(const(char)[])(name, "damage_type", "");
		MinDamage = config.Get!(float)(name, "min_damage", 1);
		MaxDamage = config.Get!(float)(name, "max_damage", 2);
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
		SRect world_rect = CollisionRect;
		world_rect.Min += Position;
		world_rect.Max += Position;
		if(GameObject.Level.CheckCollision(world_rect))
		{
			GameObject.Remove();
			GameObject.Level.DamageRectangle(world_rect, DamageType, MaxDamage > MinDamage ? rand.uniformR2(MinDamage, MaxDamage) : MaxDamage);
		}
	}
	
	mixin(Prop!("SRect", "CollisionRect", "", "protected"));
	CGameObject GameObject;
protected:
	
	CPosition Position;
	SRect CollisionRectVal;
	float MinDamage;
	float MaxDamage;
	const(char)[] DamageType;
}

