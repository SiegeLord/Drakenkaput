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
module game.CollisionManager;

import engine.TileMap;
import engine.MathTypes;
import engine.Util;
import engine.GreasyBag;

import game.ICollisionManager;

import game.components.Collision;

import tango.math.Math;
import tango.io.Stdout;

final class CCollisionManager : ICollisionManager
{
	this(int width, int height, int tile_width, int tile_height)
	{
		Width = width;
		Height = height;
		TileWidth = tile_width;
		TileHeight = tile_height;
		BoundsRect.Set(0, 0, Width * TileWidth, Height * TileHeight);
		Collisions = new typeof(Collisions);
		
		Tiles.length = Width * Height;
	}
	
	void UpdateTileMap(CTileMap map)
	{
		assert(map.Width == Width);
		assert(map.Height == Height);
		
		foreach(y; 0..Height)
		{
			foreach(x; 0..Width)
			{
				Tiles[y * Width + x].Solid = map.GetTile(x, y).Solid;
			}
		}
	}
	
	void Logic(float dt)
	{
		Collisions.Prune();
	}
	
	/* Not thread safe */
	SVector2D Move(CCollision collision, SVector2D from, SVector2D to)
	{
		//Stdout("ono").nl.nl;
		auto col_rect = collision.CollisionRect;
		auto from_rect = SRect(col_rect.Min + from, col_rect.Max + from);
		auto to_rect = SRect(col_rect.Min + to, col_rect.Max + to);
		auto total_rect = from_rect;
		total_rect.Union(to_rect);
		
		__gshared static CCollision[] eligible_collisions;
		size_t eligible_collision_count;
		
		//Stdout(eligible_collisions.length).nl;
		
		void add_collision(CCollision col)
		{
			if(eligible_collision_count >= eligible_collisions.length)
				eligible_collisions.length = 3 * (eligible_collisions.length + 1) / 2;
			eligible_collisions[eligible_collision_count++] = col;
		}
		
		//Stdout("From: ")(from.X, from.Y).nl;
		
		foreach(coll; Collisions)
		{
			if(coll != collision && coll.WorldCollisionRect.Collide(total_rect))
				add_collision(coll);
		}
		
		bool test_rect_vs_tilemap(SRect rect)
		{
			auto start_x = cast(int)max(0.0f, rect.Min.X / TileWidth);
			auto start_y = cast(int)max(0.0f, rect.Min.Y / TileHeight);
			auto end_x = cast(int)min(rect.Max.X / TileWidth + 1, Width);
			auto end_y = cast(int)min(rect.Max.Y / TileHeight + 1, Height);
			
			foreach(y; start_y..end_y)
			{
				foreach(x; start_x..end_x)
				{
					SRect tile_rect = void;
					tile_rect.Set(x * TileWidth, y * TileHeight, (x + 1) * TileWidth, (y + 1) * TileHeight);
					if(Tiles[y * Width + x].Solid && rect.Collide(tile_rect))
						return true;
				}
			}
			return false;
		}
		
		bool test_rect(float x, float y)
		{
			auto pos = SVector2D(x, y);
			auto rect = SRect(col_rect.Min + pos, col_rect.Max + pos);
			if(BoundsRect.CollideBounds(rect) || test_rect_vs_tilemap(rect))
			{
				return true;
			}
			else
			{
				foreach(coll; eligible_collisions[0..eligible_collision_count])
				{
					if(coll.WorldCollisionRect.Collide(rect))
					{
						//Stdout("rect ")(rect.Min.X, rect.Min.Y, rect.Max.X, rect.Max.Y).nl;
						//Stdout("other ")(coll.WorldCollisionRect.Min.X, coll.WorldCollisionRect.Min.Y, coll.WorldCollisionRect.Max.X, coll.WorldCollisionRect.Max.Y).nl;
						return true;
					}
				}
				return false;
			}
		}
		
		//Stdout("total ")(total_rect.Min.X, total_rect.Min.Y, total_rect.Max.X, total_rect.Max.Y)(" count ")(eligible_collision_count).nl;
		
		assert(!test_rect(from.X, from.Y), "Objects embedded in level geometry or each other");
		
		if(eligible_collision_count || BoundsRect.CollideBounds(total_rect) || test_rect_vs_tilemap(total_rect))
		{
			SVector2D pos;
			/* Take the first step */
			pos.X = RoundTowards(from.X, to.X);
			pos.Y = RoundTowards(from.Y, to.Y);
			
			/* Can't even take the first step */
			if(test_rect(pos.X, pos.Y))
				return from;
			
			float dx = to.X - from.X;
			float dy = to.Y - from.Y;
			float dy_step = dy > 0 ? 1 : -1;
			float dx_step = dx > 0 ? 1 : -1;
			
			bool done;
			SVector2D valid_pos;
			if(dy > dx)
			{
				float dxdy = dx / dy;
				do
				{
					valid_pos = pos;
					pos.X += dxdy * dy_step;
					pos.Y += dy_step;
					if(dx_step * pos.X > dx_step * to.X || dy_step * pos.Y > dy_step * to.Y)
					{
						done = true;
						break;
					}
				} while(!test_rect(pos.X, pos.Y));
			}
			else
			{
				float dydx = dy / dx;
				do
				{
					valid_pos = pos;
					pos.X += dx_step;
					pos.Y += dydx * dx_step;
					if(dx_step * pos.X > dx_step * to.X || dy_step * pos.Y > dy_step * to.Y)
					{
						done = true;
						break;
					}
				} while(!test_rect(pos.X, pos.Y));
			}
			
			pos = valid_pos;
			
			do
			{
				valid_pos = pos;
				pos.X += dx_step;
				if(dx_step * pos.X > dx_step * to.X)
				{
					break;
				}
			} while(!test_rect(pos.X, pos.Y));
			
			pos.X = to.X;
			pos.Y = valid_pos.Y;
			if(!test_rect(pos.X, pos.Y))
				valid_pos = pos;
			
			pos = valid_pos;
			
			do
			{
				valid_pos = pos;
				pos.Y += dy_step;
				if(dy_step * pos.Y > dy_step * to.Y)
				{
					break;
				}
			} while(!test_rect(pos.X, pos.Y));
			
			pos.X = valid_pos.X;
			pos.Y = to.Y;
			if(!test_rect(pos.X, pos.Y))
				valid_pos = pos;
			
			//Stdout("To: ")(valid_pos.X, valid_pos.Y).nl;
			
			//assert(!test_rect(valid_pos.X, valid_pos.Y));
			
			return valid_pos;
		}
		else
		{
			return to;
		}
	}
	
	TColHolder AddCollision(CCollision col)
	{
		return Collisions.Add(col);
	}
	
	void RemoveCollision(CCollision col, TColHolder holder)
	{
		Collisions.RemoveLater(holder);
	}
	
	CGreasyBag!(CCollision) Collisions;
protected:

	SRect BoundsRect;
	int Width;
	int Height;
	int TileWidth;
	int TileHeight;
	
	struct STile
	{
		bool Solid = false;
	}
	
	STile[] Tiles;
}
