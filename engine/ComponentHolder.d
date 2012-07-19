module engine.ComponentHolder;

import tango.io.Stdout;

interface IComponent
{
	void WireUp(CComponentHolder holder);
}

class CComponent : IComponent
{
	void WireUp(CComponentHolder holder)
	{
		
	}
}

class CComponentHolder
{
	void WireUp()
	{
		foreach(comp; Components)
			comp.WireUp(this);
	}
	
	void AddComponent(IComponent comp)
	{
		Components ~= comp;
	}
	
	@property
	TComp Get(TComp)()
	{
		TComp ret;
		foreach(component; Components)
		{
			if((ret = cast(TComp)component) !is null)
				break;
		}
		return ret;
	}
protected:
	IComponent[] Components;
}
