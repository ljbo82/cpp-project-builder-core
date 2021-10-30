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

public class JniPerson {
	// CLASS SCOPE =============================================================
	static {
		JniLib.init();
	}

	private static native long native_new(String name, int age);

	private static native void native_delete(long person);

	private static native String native_get_name(long person);

	private static native void native_set_name(long person, String name);

	private static native int native_get_age(long person);

	private static native void native_set_age(long person, int age);
	// =========================================================================

	private long nativePersonPtr;

	private void checkDisposed() {
		if (nativePersonPtr == 0)
			throw new NullPointerException("Instance already disposed");
	}

	public JniPerson(String name, int age) {
		nativePersonPtr = native_new(name, age);
	}

	public void dispose() {
		checkDisposed();

		native_delete(nativePersonPtr);
		nativePersonPtr = 0;
	}

	@Override
	protected void finalize() throws Throwable {
		dispose();
	}

	public String getName() {
		checkDisposed();

		return native_get_name(nativePersonPtr);
	}

	public JniPerson setName(String name) {
		checkDisposed();

		native_set_name(nativePersonPtr, name);
		return this;
	}

	public int getAge() {
		checkDisposed();

		return native_get_age(nativePersonPtr);
	}

	public JniPerson setAge(int age) {
		checkDisposed();

		native_set_age(nativePersonPtr, age);
		return this;
	}

	@Override
	public String toString() {
		if (nativePersonPtr == 0)
			return "(DISPOSED INSTANCE)";

		return String.format("name: %s, age: %d", native_get_name(nativePersonPtr), native_get_age(nativePersonPtr));
	}
}
