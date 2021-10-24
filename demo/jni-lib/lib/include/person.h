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
#pragma once

typedef struct __person person_t;
typedef const char*     cstring_t;

#ifdef __cplusplus
extern "C" {
#endif

void person_init();

void person_deinit();

person_t* person_new(cstring_t name, int age);

void person_delete(person_t* person);

cstring_t person_get_name(person_t* person);

int person_get_age(person_t* person);

void person_set_name(person_t* person, cstring_t name);

void person_set_age(person_t* person, int age);

#ifdef __cplusplus
}
#endif
