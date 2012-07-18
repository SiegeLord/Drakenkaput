module engine.Camera;

import engine.MathTypes;
import allegro5.allegro;

class CCamera
{
	this(SVector2D position = SVector2D(0, 0))
	{
		Position = position;
	}
	
	void Update(SVector2D screen_size)
	{
		al_identity_transform(&Transform);
		al_translate_transform(&Transform, -Position.X, -Position.Y);
		al_translate_transform(&Transform, screen_size.X / 2, screen_size.Y / 2);
		UseTransform();
	}
	
	void UseTransform()
	{
		al_use_transform(&Transform);
	}
	
	SVector2D ToWorld(SVector2D view_pos)
	{
		al_transform_coordinates(&Transform, &view_pos.X, &view_pos.Y);
		return view_pos;
	}
	
	SVector2D ToView(SVector2D world_pos)
	{
		ALLEGRO_TRANSFORM inverse;
		al_copy_transform(&inverse, &Transform);
		al_invert_transform(&inverse);
		al_transform_coordinates(&inverse, &world_pos.X, &world_pos.Y);
		return world_pos;
	}
	
	SVector2D Position;
protected:
	ALLEGRO_TRANSFORM Transform;
}
