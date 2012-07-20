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
module engine.Util;

import tango.math.Math;

const(char)[] Prop(const(char)[] type, const(char)[] name, const(char)[] get_attr = "", const(char)[] set_attr = "")()
{
	return
	"@property " ~ get_attr ~ "
	" ~ type ~ " " ~ name ~ "()
	{
		return " ~ name ~ "Val;
	}
	
	@property " ~ set_attr ~ "
	" ~ type ~ " " ~ name ~ "(" ~ type ~ " val)
	{
		return " ~ name ~ "Val = val;
	}";
}

T1 Interpolate(T1, T2)(T1 val1, T1 val2, T2 frac)
{
	return val1 + frac * (val2 - val1);
}

void Clamp(T)(ref T val, T max_val)
{
	if(val > max_val)
		val = max_val;
}

void Clamp(T)(ref T val, T min_val, T max_val)
{
	if(val > max_val)
		val = max_val;
	else if(val < min_val)
		val = min_val;
}

T RoundTowards(T)(T val, T to)
{
	if(to > val)
		return ceil(val);
	else
		return floor(val);
}
