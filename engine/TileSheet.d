module engine.TileSheet;

import engine.Bitmap;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.Util;

import tango.text.convert.Format;
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
			tile.X = TileWidth * (idx % num_x);
			tile.Y = TileHeight * (idx / num_x);
		}
	}
	
	struct STile
	{
		float X;
		float Y;
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
	
	mixin(Prop!("int", "TileWidth", "", "protected"));
	mixin(Prop!("int", "TileHeight", "", "protected"));
protected:
	int NumX;
	int TileWidthVal;
	int TileHeightVal;
	CBitmap Bitmap;
	STile[] Tiles;
}

