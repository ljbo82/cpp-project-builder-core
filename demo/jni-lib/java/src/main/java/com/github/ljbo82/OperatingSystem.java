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

enum OperatingSystem {
	WINDOWS ("", ".dll"),
	UNIX    ("lib", ".so"),
	MAC     ("lib", ".dylib");

	static OperatingSystem getNative() {
		String os = System.getProperty("os.name");

		String osLowerCase = os.toLowerCase();

		if (osLowerCase.indexOf("win") >= 0)
			return WINDOWS;

		if (osLowerCase.indexOf("mac") >= 0)
			return MAC;

		if (osLowerCase.indexOf("nix") >= 0 || osLowerCase.indexOf("nux") >= 0 || osLowerCase.indexOf("aix") > 0)
			return UNIX;

		throw new RuntimeException(String.format("Unsupported operating system: %s", os));
	}

	final String libPrefix;
	final String libSuffix;

	OperatingSystem(String libPrefix, String libSuffix) {
		this.libPrefix = libPrefix;
		this.libSuffix = libSuffix;
	}
}
