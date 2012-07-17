module engine.Sprite;

import engine.Bitmap;
import engine.BitmapManager;
import engine.ConfigManager;
import engine.Util;

import tango.io.Path;
import tango.math.Math;

import allegro5.allegro;

final class CSprite
{
	this(const(char)[] file, CConfigManager config_manager, CBitmapManager bmp_manager)
	{
		auto ext = parse(file).ext();
		if(ext == "cfg")
		{
			auto cfg = config_manager.Load(file);
			auto bmp_name = cfg.Get!(const(char)[])("", "bitmap");
			if(bmp_name == "")
				throw new Exception("'" ~ file.idup ~ "' needs to specify a bitmap file.");
			
			Bitmap = bmp_manager.Load(bmp_name);
			Width = min(cfg.Get!(int)("", "width", Bitmap.Width), Bitmap.Width);
			Height = min(cfg.Get!(int)("", "height", Bitmap.Height), Bitmap.Height);
			FPS = cfg.Get!(float)("", "fps", 0);
			NumX = cast(int)(Bitmap.Width / Width);
			NumY = cast(int)(Bitmap.Height / Height);
		}
		else
		{
			Bitmap = bmp_manager.Load(file);
			Width = Bitmap.Width;
			Height = Bitmap.Height;
			FPS = 0;
			NumX = 1;
			NumY = 1;
		}
	}
	
	void Draw(float time, float cx, float cy, float dx, float dy, float theta, ALLEGRO_COLOR col)
	{
		time -= TimeOffset;
		
		const total = (NumX * NumY);
		int frame_idx = cast(int)(time * FPS) % total;
		if(frame_idx < 0)
			frame_idx += total;
		
		int x_div = frame_idx % NumX;
		int y_div = frame_idx / NumX;
		
		al_draw_tinted_scaled_rotated_bitmap_region(Bitmap.Get, cast(float)x_div * Width, cast(float)y_div * Height, 
		    cast(float)Width, cast(float)Height, col, cx, cy, dx, dy,
		    1.0, 1.0, theta, 0);
	}
	
	void Draw(float time, float cx, float cy, float dx, float dy, float theta)
	{
		Draw(time, cx, cy, dx, dy, theta, al_map_rgb_f(1, 1, 1));
	}
	
	void Draw(float time, float dx, float dy)
	{
		Draw(time, 0.0, 0.0, dx, dy, 0.0, al_map_rgb_f(1, 1, 1));
	}
	
	void Draw(float time, float dx, float dy, ALLEGRO_COLOR color)
	{
		Draw(time, 0.0, 0.0, dx, dy, 0.0, color);
	}
	
	mixin(Prop!("int", "Width", "", "protected"));
	mixin(Prop!("int", "Height", "", "protected"));
	float TimeOffset = 0;
protected:
	int WidthVal = 0;
	int HeightVal = 0;
	
	int NumY = 1;
	int NumX = 1;
	
	float FPS = 0;
	CBitmap Bitmap;
}