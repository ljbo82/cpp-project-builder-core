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
#include <com_github_ljbo82_JniVector2D.h>

#include <math.h>

JNIEXPORT jdouble JNICALL Java_com_github_ljbo82_JniVector2D_vector_1get_1magnitude(JNIEnv* env, jclass cls, jdouble x, jdouble y) {
	return sqrt(pow(x, 2) + pow(y, 2));
}
