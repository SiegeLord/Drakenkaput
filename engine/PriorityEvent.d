module engine.PriorityEvent;

import tango.core.Array;

final class CPriorityEvent(TArgs...)
{
	alias void delegate(TArgs) TDelegate;
	
	struct SDelegateHolder
	{
		TDelegate Delegate;
		int Priority;
		
		static bool Less(SDelegateHolder a, SDelegateHolder b)
		{
			return a.Priority < b.Priority || (a.Priority == b.Priority
			       && (a.Delegate.ptr < b.Delegate.ptr || (a.Delegate.ptr == b.Delegate.ptr
			       && a.Delegate.funcptr < b.Delegate.funcptr)));
		}
	}
	
	void Register(TDelegate dg, int priority)
	{
		auto holder = SDelegateHolder(dg, priority);
		auto where = DelegateHolders.lbound(holder, &SDelegateHolder.Less);
		DelegateHolders.length = DelegateHolders.length + 1;
		
		foreach(ii; where..DelegateHolders.length - 1)
			DelegateHolders[ii + 1] = DelegateHolders[ii];
		
		DelegateHolders[where] = holder;
	}
	
	void UnRegister(TDelegate dg)
	{
		auto new_len = DelegateHolders.removeIf((SDelegateHolder a) => dg is a.Delegate);
		DelegateHolders.length = new_len;
	}
	
	void Trigger(TArgs args)
	{
		foreach(holder; DelegateHolders)
			holder.Delegate(TArgs);
	}
	
protected:
	SDelegateHolder[] DelegateHolders;
} 

version(UnitTest)
{
	import tango.text.convert.Format;
	unittest
	{
		auto event = new CPriorityEvent!();
		int[] call_stack;

		void delegate() dg = {call_stack ~= 2;};
		event.Register({call_stack ~= 3;}, 3);
		event.Register({call_stack ~= 1;}, 1);
		event.Register(dg, 2);
		event.Trigger();
		assert(call_stack == [1, 2, 3], Format("{}", call_stack));
		call_stack.length = 0;
		
		event.UnRegister(dg);
		event.Trigger();
		assert(call_stack == [1, 3], Format("{}", call_stack));
	}
}
