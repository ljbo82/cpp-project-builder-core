# This file is part of gcc-project-builder.
# Copyright (C) 2021 Leandro José Britto de Oliveira
#
# gcc-project-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# gcc-project-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>

ifndef __include_native_host_mk__
__include_native_host_mk__ := 1

ifeq ($(OS), Windows_NT)
    hostOS := windows
else
    __host_uname_s__ := $(shell uname -s)
    ifeq ($(__host_uname_s__), Linux)
        hostOS := linux
    else
        $(error [ERROR] Unsupported host operating system: $(__host_uname_s__))
    endif
endif
undefine __host_uname_s__

ifeq ($(hostOS), windows)
    ifeq ($(PROCESSOR_ARCHITECTURE), AMD64)
        hostArch := x64
    else ifeq ($(PROCESSOR_ARCHITECTURE), x86)
        hostArch := x86
    else
        $(error [ERROR] Unsupported architecture for host $(hostOS): $(PROCESSOR_ARCHITECTURE))
    endif
else
    __host_uname_m__ := $(shell uname -m)
    ifeq ($(__host_uname_m__), x86_64)
        hostArch := x64
    else
        ifneq ($(filter %86, $(__host_uname_m__)),)
            hostArch := x86
        else
            $(error [ERROR] Unsupported architecture for host $(hostOS): $(__host_uname_m__)
        endif
    endif
endif
undefine __host_uname_m__

host := $(hostOS)-$(hostArch)

endif # __include_native_host_mk__

