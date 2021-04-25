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

ifndef __include_os_windows_mk__
__include_os_windows__ := 1

__selfDir__ := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__selfDir__)../project.mk

__libPrefix__       = lib
__sharedLibSuffix__ :=.dll
__staticLibSuffix__ := .dll.a

ifeq ($(DEBUG), 1)
    __debugSuffix__ := _d
endif

ifeq ($(PROJ_TYPE), app)
    artifactName     := $(PROJ_NAME)$(projVersionMajor)$(__debugSuffix__)
    __postDistDeps__ := $(__postDistDeps__) $(fullDistDir)/bin/$(artifactName)
else
    ifeq ($(LIB_TYPE), static)
        artifactName := $(__libPrefix__)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix__)$(__staticLibSuffix__)
    else
        artifactName     := $(__libPrefix__)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix__)$(__sharedLibSuffix__)
        __ldFlags__      += -Wl,--out-implib,$(__artifactName__).lib
        __ldFlags__      += -Wl,--output-def,$(__artifactName__).def
        __postDistDeps__ := $(__postDistDeps__) $(fullDistDir)/lib/$(artifactName) $(__postDistDeps__)
    endif
endif

$(fullDistDir)/bin/$(artifactName): __nl__ := $(__nl__)
$(fullDistDir)/bin/$(artifactName): __v__  := $(__v__)
$(fullDistDir)/bin/$(artifactName): $(fullBuildDir)/$(artifactName)
	@printf "$(__nl__)[DIST] $@\n"
	@mkdir -p $(fullDistDir)/bin
	$(__v__)ln $(fullBuildDir)/$(artifactName) $(fullDistDir)/bin

$(fullDistDir)/lib/$(artifactName): __nl__ := $(__nl__)
$(fullDistDir)/lib/$(artifactName): __v__  := $(__v__)
$(fullDistDir)/lib/$(artifactName): $(fullBuildDir)/$(artifactName)
	@printf "$(__nl__)[DIST] $@\n"
	@mkdir -p $(fullDistDir)/lib
	$(__v__)ln $(fullBuildDir)/$(artifactName) $(fullDistDir)/lib/$(artifactName)

undefine __selfDir__
undefine __libPrefix__
undefine __sharedLibSuffix__
undefine __staticLibSuffix__
undefine __debugSuffix__

endif #__include_os_windows_mk__

