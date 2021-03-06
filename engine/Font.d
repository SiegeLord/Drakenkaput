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
module engine.Font;

import engine.Holder;

import allegro5.allegro_font;

class CFont : CHolder!(ALLEGRO_FONT*, al_destroy_font)
{
	this(ALLEGRO_FONT* font)
	{
		super(font);
	}
	
	int Height()
	{
		return al_get_font_line_height(Get);
	}
}
