module game.GameObject;

import engine.ComponentHolder;
import engine.Config;
import engine.ConfigManager;
import game.ILevel;
import game.ComponentFactory;
import engine.GreasyBag;

class CGameComponent : CComponent
{
	this(CConfig config)
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
			AddComponent(CreateComponent(cfg, name));
		
		WireUp();
		
		Holder = Level.AddObject(this);
	}
	
	void Remove()
	{
		Level.RemoveObject(this, Holder);
	}
protected:
	ILevel Level;
	TObjHolder Holder;
}
