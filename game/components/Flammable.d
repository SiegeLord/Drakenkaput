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
module game.components.Flammable;

import engine.MathTypes;
import engine.Config;
import engine.ComponentHolder;
import engine.Util;

import game.GameObject;
import game.components.Destroyable;

import tango.io.Stdout;
 
class CFlammable : CGameComponent
{	
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Destroyable, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		GameObject = game_obj;
		game_obj.Level.LogicEvent.Register(&Logic);
		Damage = config.Get!(float)(ComponentName!(typeof(this)), "damage");
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.LogicEvent.UnRegister(&Logic);
		if(DiedCallback !is null)
			DiedCallback();
	}
	
	void Logic(float dt)
	{
		if(OnFire)
			Destroyable.Damage(Damage * dt);
	}

	void SetOnFire()
	{
		if(!OnFire)
		{
			OnFire = true;
			DiedCallback = GameObject.Level.AddFireEffect(GameObject);
		}
	}
	
	mixin(Prop!("bool", "OnFire", "", "protected"));
protected:
	CGameObject GameObject;
	bool OnFireVal = false;
	float Damage;
	CDestroyable Destroyable;
	void delegate() DiedCallback;
}
