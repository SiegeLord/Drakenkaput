module game.ICollisionManager;

import engine.MathTypes;
import engine.Util;
import engine.GreasyBag;
import game.components.Collision;

alias CGreasyBag!(CCollision).CElemHolder TColHolder;

interface ICollisionManager
{
	SVector2D Move(CCollision collision, SVector2D from, SVector2D to);
	
	TColHolder AddCollision(CCollision col);
	void RemoveCollision(CCollision col, TColHolder holder);
}
