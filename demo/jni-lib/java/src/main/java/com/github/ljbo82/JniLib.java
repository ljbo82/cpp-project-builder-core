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

public class JniLib {
	private JniLib() {}

	private static native void nativeInit();

	private static native void nativeDeinit();

	private static boolean initialized = false;

	public static synchronized void init() {
		if (!initialized) {
			LibLoader.load("lib", "jni-demo0");
			nativeInit();
			initialized = true;
		}
	}

	public static synchronized void deinit() {
		if (initialized) {
			nativeDeinit();
			initialized = false;
		}
	}
}
