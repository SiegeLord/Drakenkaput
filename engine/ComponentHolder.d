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
	
	bool Get(TComp)(ref TComp comp)
	{
		return (comp = Get!(TComp)()) !is null;
	}
protected:
	IComponent[] Components;
}

@property
immutable(char)[] ComponentName(TComp)()
{
	return TComp.stringof[1..$];
}

void RequireComponent(TThis, TComp)(ref TComp component, CComponentHolder holder, TThis this_obj)
{
	component = holder.Get!(TComp);
	if(component is null)
		throw new Exception("'" ~ ComponentName!(TThis) ~ "' component requires a '" ~ ComponentName!(TComp) ~ "' component.");
}
