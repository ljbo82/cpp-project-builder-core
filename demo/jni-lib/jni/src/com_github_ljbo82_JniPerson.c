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
#include <com_github_ljbo82_JniPerson.h>
#include <person.h>

JNIEXPORT jlong JNICALL Java_com_github_ljbo82_JniPerson_native_1new(JNIEnv* env, jclass cls, jstring str, jint age) {
	return (jlong)person_new((*env)->GetStringUTFChars(env, str, NULL), age);
}

JNIEXPORT void JNICALL Java_com_github_ljbo82_JniPerson_native_1delete(JNIEnv* env, jclass cls, jlong person) {
	person_delete((person_t*)person);
}

JNIEXPORT jstring JNICALL Java_com_github_ljbo82_JniPerson_native_1get_1name(JNIEnv* env, jclass cls, jlong person) {
	return (*env)->NewStringUTF(env, person_get_name((person_t*)person));
}

JNIEXPORT void JNICALL Java_com_github_ljbo82_JniPerson_native_1set_1name(JNIEnv* env, jclass cls, jlong person, jstring str) {
	person_set_name((person_t*)person, (*env)->GetStringUTFChars(env, str, NULL));
}

JNIEXPORT jint JNICALL Java_com_github_ljbo82_JniPerson_native_1get_1age(JNIEnv* env, jclass cls, jlong person) {
	return person_get_age((person_t*)person);
}

JNIEXPORT void JNICALL Java_com_github_ljbo82_JniPerson_native_1set_1age(JNIEnv* env, jclass cls, jlong person, jint age) {
	person_set_age((person_t*)person, age);
}
