module engine.ComponentHolder;

interface IComponent
{
	void WireUp(CComponentHolder holder);
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

	IComponent GetByInfo(ClassInfo type)
	{
		foreach(component; Components)
		{
			/* Component a subclass of type */
			auto base = component.classinfo;
			while(base !is null)
			{
				if(base is type)
					return component;

				base = base.base;
			}
		}

		return null;
	}
	
	@property
	CompT Get(CompT)()
	{
		return cast(CompT)GetByInfo(CompT.classinfo);
	}
protected:
	IComponent[] Components;
}
