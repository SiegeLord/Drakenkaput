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
