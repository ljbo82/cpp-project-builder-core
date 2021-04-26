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

PROJ_NAME := app_lib
PROJ_TYPE := app

include ../../defs.mk

ifeq ($(DEBUG), 1)
  __debugSuffix := _d
endif

ifeq ($(hostOS), windows)
    __libSuffix := .dll
else
    __libSuffix := .so
endif

BUILD_DEPS     := ../lib/$(buildDir)/libmylib0$(__debugSuffix)$(__libSuffix)
POST_DIST_DEPS := $(distDir)/bin/libmylib0$(__debugSuffix)$(__libSuffix)
INCLUDE_DIRS   += ../lib/include
LDFLAGS        := -Wl,-rpath,./ -L../lib/$(buildDir) -lmylib0$(__debugSuffix)

# ==============================================================================
../lib/$(buildDir)/libmylib0$(__debugSuffix)$(__libSuffix):
	@printf "$(nl)[BUILD] $@\n"
	@$(MAKE) clean > /dev/null
	$(v)$(MAKE) -C ../lib
# ==============================================================================

# ==============================================================================
$(distDir)/bin/libmylib0$(__debugSuffix)$(__libSuffix): ../lib/$(buildDir)/libmylib0$(__debugSuffix)$(__libSuffix)
	@printf "$(nl)[DIST] $@\n"
	$(v)cp $< $@
# ==============================================================================

undefine __debugSuffix
undefine __libSuffix

include ../../project.mk
