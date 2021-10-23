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
#include <person.h>

#include <stdlib.h>
#include <string.h>

#define __DEBUG_ENABLED 1

#if __DEBUG_ENABLED
	#include <stdio.h>
	#define __DEBUG(msg, ...) { printf(msg "\n", ##__VA_ARGS__); fflush(stdout); }
#else
	#define __DEBUG(msg, ...)
#endif

struct __person {
	char name[128];
	int  age;
};

person_t* person_new(cstring_t name, int age) {
	person_t* person = malloc(sizeof(person_t));
	__DEBUG("[NATIVE] person_new");
	strcpy(person->name, name);
	person->age = age;
	return person;
}

void person_delete(person_t* person) {
	free(person);
	__DEBUG("[NATIVE] person_delete");
}

cstring_t person_get_name(person_t* person) {
	return person->name;
}

int person_get_age(person_t* person) {
	return person->age;
}

void person_set_name(person_t* person, cstring_t name) {
	strcpy(person->name, name);
}

void person_set_age(person_t* person, int age) {
	person->age = age;
}
