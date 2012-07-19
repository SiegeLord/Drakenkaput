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
