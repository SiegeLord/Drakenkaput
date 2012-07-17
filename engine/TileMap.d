module engine.TileMap;

import engine.ConfigManager;
import engine.Util;
import engine.TileSheet;
import engine.MathTypes;

import tango.math.Math;

final class CTileMap
{
	this(const(char)[] file, CTileSheet sheet, CConfigManager config_manager)
	{
		auto cfg = config_manager.Load(file);
		auto tilesheet_name = cfg.Get!(const(char)[])("", "tilesheet");
		if(tilesheet_name == "")
			throw new Exception("'" ~ file.idup ~ "' needs to specify a tilesheet file.");

		Width = max(cfg.Get!(int)("", "width", 1), 1);
		Height = max(cfg.Get!(int)("", "height", 1), 1);
		
		TileMap.length = Width * Height;
		foreach(idx, ref tile; TileMap)
			tile = idx % 4;
		
		Sheet = sheet;
	}
	
	void Draw(SVector2D screen_pos, SVector2D screen_size)
	{
		auto tw = Sheet.TileWidth;
		auto th = Sheet.TileHeight;
		
		auto start_x = cast(int)max(0.0f, screen_pos.X / tw);
		auto start_y = cast(int)max(0.0f, screen_pos.Y / th);
		auto end_x = cast(int)min((screen_pos.X + screen_size.X) / tw + 1, Width);
		auto end_y = cast(int)min((screen_pos.Y + screen_size.Y) / th + 1, Height);
		
		foreach(y; start_y..end_y)
		{
			foreach(x; start_x..end_x)
			{
				Sheet.DrawTile(TileMap[y * Width + x], x * Sheet.TileWidth, y * Sheet.TileHeight);
			}
		}
	}
protected:
	size_t[] TileMap;
	CTileSheet Sheet;
	int Width;
	int Height;
}
