module game.ILevel;

import engine.PriorityEvent;
import engine.UnorderedEvent;
import engine.GreasyBag;
import engine.BitmapManager;
import engine.ConfigManager;

import game.IGame;
import game.IGameMode;
import game.GameObject;
import game.ICollisionManager;

alias CGreasyBag!(CGameObject).CElemHolder TObjHolder;

interface ILevel
{	
	@property
	CPriorityEvent!() DrawEvent();
	
	@property
	CUnorderedEvent!(float) LogicEvent();
	
	@property
	IGameMode GameMode();
	
	@property
	IGame Game();
	
	TObjHolder AddObject(CGameObject obj);
	void RemoveObject(CGameObject obj, TObjHolder holder);
	
	@property
	CBitmapManager BitmapManager();
	
	@property
	CConfigManager ConfigManager();
	
	@property
	ICollisionManager CollisionManager();
}
