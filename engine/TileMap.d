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
module engine.TileMap;

import engine.ConfigManager;
import engine.Util;
import engine.TileSheet;
import engine.MathTypes;

import tango.math.Math;
import tango.text.convert.Format;

import allegro5.allegro;

final class CTileMap
{
	this(const(char)[] file, CTileSheet sheet, CConfigManager config_manager)
	{
		Sheet = sheet;
		
		auto cfg = config_manager.Load(file);
		auto tilesheet_name = cfg.Get!(const(char)[])("tilemap", "tilesheet");
		if(tilesheet_name == "")
			throw new Exception("'" ~ file.idup ~ "' needs to specify a tilesheet file.");

		Width = max(cfg.Get!(int)("tilemap", "width", 1), 1);
		Height = max(cfg.Get!(int)("tilemap", "height", 1), 1);
		
		TileMap.length = Width * Height;
		
		foreach(y; 0..Height)
		{
			auto key_str = Format("row_{}", y);
			auto row_str = cfg.Get!(const(dchar)[])("tilemap", key_str, "");
			foreach(x, symbol; row_str)
			{
				if(x >= Width)
					break;
				TileMap[y * Width + x] = Sheet.GetIdx(symbol);
			}
		}
	}
	
	void Draw(SVector2D screen_pos, SVector2D screen_size)
	{		
		auto tw = TileWidth;
		auto th = TileHeight;
		
		auto start_x = cast(int)max(0.0f, screen_pos.X / tw);
		auto start_y = cast(int)max(0.0f, screen_pos.Y / th);
		auto end_x = cast(int)min((screen_pos.X + screen_size.X) / tw + 1, Width);
		auto end_y = cast(int)min((screen_pos.Y + screen_size.Y) / th + 1, Height);
		
		bool was_held = al_is_bitmap_drawing_held();
		al_hold_bitmap_drawing(true);
		
		foreach(y; start_y..end_y)
		{
			foreach(x; start_x..end_x)
			{
				Sheet.DrawTile(TileMap[y * Width + x], x * TileWidth, y * TileHeight);
			}
		}
		
		if(!was_held)
			al_hold_bitmap_drawing(false);
	}
	
	@property
	SVector2D PixelSize()
	{
		return SVector2D(Width * TileWidth, Height * TileHeight);
	}
	
	CTileSheet.STile GetTile(int x, int y)
	{
		return Sheet.GetTile(TileMap[y * Width + x]);
	}
	
	@property
	int TileWidth()
	{
		return Sheet.TileWidth;
	}
	
	@property
	int TileHeight()
	{
		return Sheet.TileHeight;
	}
	
	mixin(Prop!("int", "Width", "", "protected"));
	mixin(Prop!("int", "Height", "", "protected"));
protected:
	size_t[] TileMap;
	CTileSheet Sheet;
	int WidthVal;
	int HeightVal;
}
