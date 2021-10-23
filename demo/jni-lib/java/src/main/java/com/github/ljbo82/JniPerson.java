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
		Jni.init();
	}

	private static native long person_new(String name, int age);

	private static native void person_delete(long person);

	private static native String person_get_name(long person);

	private static native void person_set_name(long person, String name);

	private static native int person_get_age(long person);

	private static native void person_set_age(long person, int age);
	// =========================================================================

	private final long nativePersonPtr;

	public JniPerson(String name, int age) {
		nativePersonPtr = person_new(name, age);
	}

	@Override
	protected void finalize() throws Throwable {
		person_delete(nativePersonPtr);
	}

	public String getName() {
		return person_get_name(nativePersonPtr);
	}

	public JniPerson setName(String name) {
		person_set_name(nativePersonPtr, name);
		return this;
	}

	public int getAge() {
		return person_get_age(nativePersonPtr);
	}

	public JniPerson setAge(int age) {
		person_set_age(nativePersonPtr, age);
		return this;
	}

	@Override
	public String toString() {
		return String.format("name: %s, age: %d", getName(), getAge());
	}
}
