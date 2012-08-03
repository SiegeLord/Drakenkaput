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
module game.components.Direction;

enum EDirection
{
	Left,
	Down,
	Right,
	Up,
	NumDirections
}

const(char)[] DirectionToString(EDirection dir)
{
	auto idir = cast(int)dir;
	if(idir > cast(int)EDirection.Up)
		assert(0);
	
	return ["left", "down", "right", "up"][idir];
}

import game.GameObject;

import tango.math.Math;
 
class CDirection : CGameComponent
{	
	alias Direction this;
	
	EDirection Direction = EDirection.Down;
	
	float GetTheta()
	{
		return 2 * PI * cast(int)Direction / cast(int)EDirection.NumDirections;
	}
}
