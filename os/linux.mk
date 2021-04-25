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

ifndef __include_os_linux_mk__
__include_os_linux__ := 1

__selfDir__ := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__selfDir__)../project.mk

__libPrefix__       = lib
__sharedLibSuffix__ :=.so
__staticLibSuffix__ := .a

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
        __artifactBaseName__ := $(__libPrefix__)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix__)$(__sharedLibSuffix__)
        artifactName         := $(__artifactBaseName__).$(projVersionMinor).$(projVersionPatch)
        __postBuildDeps__    := $(__postBuildDeps__) $(fullBuildDir)/$(__artifactBaseName__)
        __postDistDeps__     := $(__postDistDeps__) $(fullDistDir)/lib/$(__artifactBaseName__) $(fullDistDir)/lib/$(artifactName) $(__postDistDeps__)
    endif
endif

$(fullDistDir)/bin/$(artifactName): __nl__ := $(__nl__)
$(fullDistDir)/bin/$(artifactName): __v__  := $(__v__)
$(fullDistDir)/bin/$(artifactName): $(fullBuildDir)/$(artifactName)
	@printf "$(__nl__)[DIST] $@\n"
	@mkdir -p $(fullDistDir)/bin
	$(__v__)ln $(fullBuildDir)/$(artifactName) $(fullDistDir)/bin

$(fullBuildDir)/$(__artifactBaseName__): __nl__                := $(__nl__)
$(fullBuildDir)/$(__artifactBaseName__): __v__                 := $(__v__)
$(fullBuildDir)/$(__artifactBaseName__): __artifactBaseName__  := $(__artifactBaseName__)
$(fullBuildDir)/$(__artifactBaseName__): $(fullBuildDir)/$(artifactName)
	@printf "$(__nl__)[BUILD] $@\n"
	$(__v__)cd $(fullBuildDir); ln -sf $(artifactName) $(__artifactBaseName__)

$(fullDistDir)/lib/$(__artifactBaseName__): __nl__                := $(__nl__)
$(fullDistDir)/lib/$(__artifactBaseName__): __v__                 := $(__v__)
$(fullDistDir)/lib/$(__artifactBaseName__): __artifactBaseName__  := $(__artifactBaseName__)
$(fullDistDir)/lib/$(__artifactBaseName__): $(fullBuildDir)/$(__artifactBaseName__)
	@printf "$(__nl__)[DIST] $@\n"
	@mkdir -p $(fullDistDir)/lib
	$(__v__)ln $(fullBuildDir)/$(__artifactBaseName__) $(fullDistDir)/lib/$(__artifactBaseName__)

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
undefine __artifactBaseName__

endif #__include_os_linux_mk__

