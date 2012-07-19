module game.ILevel;

import game.IGameMode;
import game.GameObject;

import engine.PriorityEvent;
import engine.UnorderedEvent;
import engine.GreasyBag;

alias CGreasyBag!(CGameObject).CElemHolder TObjHolder;

interface ILevel
{	
	@property
	CPriorityEvent!() DrawEvent();
	
	@property
	CUnorderedEvent!(float) LogicEvent();
	
	@property
	IGameMode GameMode();
	
	TObjHolder AddObject(CGameObject obj);
	void RemoveObject(CGameObject obj, TObjHolder holder);
}
