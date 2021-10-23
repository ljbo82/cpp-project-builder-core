/*
    This file is part of gcc-project-builder.
    Copyright (C) 2021 Leandro José Britto de Oliveira

    gcc-project-builder is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    gcc-project-builder is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>
*/
package com.github.ljbo82;

public class JniVector2D {
	// CLASS SCOPE =============================================================
	static {
		Jni.init();
	}

	private static native double vector_get_magnitude(double a, double b);
	// =========================================================================

	private double x, y;

	public JniVector2D(double x, double y) {
		this.x = x;
		this.y = y;
	}

	public double getX() {
		return x;
	}

	public JniVector2D setX(double x) {
		this.x = x;
		return this;
	}

	public double getY() {
		return y;
	}

	public JniVector2D setY(double y) {
		this.y = y;
		return this;
	}

	public double getMagnitude() {
		return vector_get_magnitude(y, x);
	}

	@Override
	public String toString() {
		return String.format("x: %.4f, y: %.4f, magnitude: %.4f", x, y, getMagnitude());
	}
}
