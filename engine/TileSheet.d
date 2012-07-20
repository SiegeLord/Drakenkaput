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
module engine.TileSheet;

import engine.Bitmap;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.Util;

import tango.text.convert.Format;
import tango.text.convert.Utf;
import tango.math.Math;

import allegro5.allegro;

final class CTileSheet
{
	this(const(char)[] file, CConfigManager config_manager, CBitmapManager bmp_manager)
	{
		auto cfg = config_manager.Load(file);
		auto bmp_name = cfg.Get!(const(char)[])("", "bitmap");
		if(bmp_name == "")
			throw new Exception("'" ~ file.idup ~ "' needs to specify a bitmap file.");
		
		Bitmap = bmp_manager.Load(bmp_name);
		TileWidth = cfg.Get!(int)("", "tile_width", 32);
		TileHeight = cfg.Get!(int)("", "tile_height", 32);
		
		if(TileWidth > Bitmap.Width || TileHeight > Bitmap.Height)
			throw new Exception("Bitmap is smaller than tile size");
		
		int num_x = Bitmap.Width / TileWidth;
		int num_y = Bitmap.Height / TileHeight;
		
		Tiles.length = num_x * num_y;
		NumX = num_x;
		
		foreach(idx, ref tile; Tiles)
		{
			auto section_name = Format("tile_{}", idx);
			tile.X = TileWidth * (idx % num_x);
			tile.Y = TileHeight * (idx / num_x);
			auto symbol_str = cfg.Get!(const(dchar)[])(section_name, "symbol", "");
			if(symbol_str.length > 0)
				SymbolMap[symbol_str[0]] = idx;
			tile.Solid = cfg.Get!(bool)(section_name, "solid", false);
		}
	}
	
	struct STile
	{
		float X;
		float Y;
		bool Solid = false;
	}
	
	void DrawTile(size_t idx, float x, float y)
	{
		auto tile = GetTile(idx);
		al_draw_bitmap_region(Bitmap.Get, tile.X, tile.Y, TileWidth, TileHeight, x, y, 0);
	}
	
	STile GetTile(float x, float y)
	{
		size_t tile_x = cast(size_t)max(0, floor(x / TileWidth));
		size_t tile_y = cast(size_t)max(0, floor(y / TileHeight));
		
		return GetTile(tile_x, tile_y);
	}
	
	STile GetTile(size_t x, size_t y)
	{
		return Tiles[y * NumX + x];
	}
	
	STile GetTile(size_t idx)
	{
		return Tiles[idx];
	}
	
	size_t GetIdx(dchar symbol)
	{
		auto idx_ptr = symbol in SymbolMap;
		if(idx_ptr is null)
		{
			char[6] buf;
			throw new Exception("Symbol " ~ encode(buf, symbol).idup ~ " is not present in this tilesheet.");
		}
		return *idx_ptr; 
	}
	
	mixin(Prop!("int", "TileWidth", "", "protected"));
	mixin(Prop!("int", "TileHeight", "", "protected"));
protected:
	int NumX;
	int TileWidthVal;
	int TileHeightVal;
	CBitmap Bitmap;
	STile[] Tiles;
	size_t[dchar] SymbolMap;
}

