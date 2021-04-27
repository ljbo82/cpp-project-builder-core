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

ifndef _include_os_windows_mk
_include_os_windows_mk := 1

__selfDir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__selfDir)../defs.mk

# ------------------------------------------------------------------------------
appSuffix       := .exe
libPrefix       := lib
sharedLibSuffix :=.dll
staticLibSuffix := .dll.a

ifeq ($(DEBUG), 1)
    __debugSuffix := _d
endif

ifeq ($(PROJ_TYPE), app)
    artifactName  := $(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(appSuffix)
else
    ifeq ($(LIB_TYPE), static)
        artifactName  := $(libPrefix)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(staticLibSuffix)
    else
        artifactName  := $(libPrefix)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(sharedLibSuffix)
        _ldFlags      += -Wl,--out-implib,$(buildDir)/$(artifactName).lib
        _ldFlags      += -Wl,--output-def,$(buildDir)/$(artifactName).def
        _postDistDeps += $(distDir)/lib/$(artifactName).lib
        _postDistDeps += $(distDir)/lib/$(artifactName).def
    endif
endif
# ------------------------------------------------------------------------------

# _postDistDeps ================================================================
$(distDir)/lib/$(artifactName).lib: $(buildDir)/$(artifactName).lib
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln $< $@

$(distDir)/lib/$(artifactName).def: $(buildDir)/$(artifactName).def
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln $< $@
# ==============================================================================

undefine __selfDir
undefine __debugSuffix

endif #_include_os_windows_mk

