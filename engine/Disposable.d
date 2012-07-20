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
module engine.Disposable;

version(DebugDisposable) import tango.stdc.stdio;

/**
 * A simple class that formalizes the non-managed resource management. The advantage of using this
 * is that with version DebugDisposable defined, it will track whether all the resources were disposed of
 */
class CDisposable
{
	this()
	{
		version(DebugDisposable)
		{
			InstanceCounts[this.classinfo.name]++;
		}
		
		IsDisposed = false;
	}
	
	void Dispose()
	{
		version(DebugDisposable)
		{
			if(!IsDisposed)
			{
				InstanceCounts[this.classinfo.name]--;
			}
		}

		IsDisposed = true;
	}
	
protected:
	bool IsDisposed = false;
}

version(DebugDisposable)
{
	size_t[char[]] InstanceCounts;

	static ~this()
	{
		printf("Disposable classes instance counts:\n");
		bool any = false;
		foreach(name, num; InstanceCounts)
		{
			if(num)
			{
				printf("%s: \033[1;31m%d\033[0m\n", (name ~ "\0").ptr, num);
				any = true;
			}
		}
		if(!any)
			printf("No leaked instances!\n");
	}
}
