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
module game.GameObject;

import engine.ComponentHolder;
import engine.Config;
import engine.ConfigManager;
import engine.Util;

import game.ILevel;
import game.ComponentFactory;

class CGameComponent : CComponent
{
	void Load(CGameObject game_object, CConfig config)
	{
		
	}
	
	void Unload(CGameObject game_object)
	{
		
	}
}

class CGameObject : CComponentHolder
{
	this(const(char)[] file, ILevel level, CConfigManager cfg_manager)
	{
		Level = level;
		auto cfg = cfg_manager.Load(file);

		foreach(name; cfg.Get!(const(char)[][])("", "components"))
			AddComponent(CreateComponent(name));
		
		WireUp();
		
		foreach(comp; Components)
			(cast(CGameComponent)comp).Load(this, cfg);
		
		Holder = Level.AddObject(this);
	}
	
	void Remove()
	{
		Level.RemoveObject(this, Holder);
		
		foreach(comp; Components)
			(cast(CGameComponent)comp).Unload(this);
	}
	
	mixin(Prop!("ILevel", "Level", "", "protected"));
protected:
	ILevel LevelVal;
	TObjHolder Holder;
}
