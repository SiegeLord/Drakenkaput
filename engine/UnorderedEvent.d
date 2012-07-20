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
module engine.UnorderedEvent;

import tango.core.Array;

final class CUnorderedEvent(TArgs...)
{
	alias void delegate(TArgs) TDelegate;
	
	void Register(TDelegate dg)
	{
		Delegates ~= dg;
	}
	
	void UnRegister(TDelegate dg)
	{
		auto new_len = Delegates.partition((TDelegate a) => dg !is a);
		Delegates.length = new_len;
	}
	
	void Trigger(TArgs args)
	{
		foreach(dg; Delegates)
			dg(args);
	}
	
protected:
	TDelegate[] Delegates;
} 

version(UnitTest)
{
	unittest
	{
		auto event = new CUnorderedEvent!(int);
		
		int a_vals = 0;
		int b_vals = 0;
		
		void delegate(int) dg = (int v) { a_vals += v; };
		
		event.Register(dg);
		event.Register((v) {b_vals += v;});
		event.Trigger(5);
		assert(a_vals == 5);
		assert(b_vals == 5);
		event.UnRegister(dg);
		event.Trigger(5);
		assert(a_vals == 5);
		assert(b_vals == 10);
	}
}
