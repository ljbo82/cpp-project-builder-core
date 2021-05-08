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

__os_windows_mk_dir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__os_windows_mk_dir)../defs.mk

ifeq ($(CROSS_COMPILE), )
    ifeq ($(hostArch), x64)
        CROSS_COMPILE := x86_64-w64-mingw32-
    else
        ifeq ($(hostArch), x86)
            CROSS_COMPILE := i686-w64-mingw32-
        else
            $(error Missing CROSS_COMPILE)
        endif
    endif
endif

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
	$(v)ln -f $< $@

$(distDir)/lib/$(artifactName).def: $(buildDir)/$(artifactName).def
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln -f $< $@
# ==============================================================================

undefine __os_windows_mk_dir
undefine __debugSuffix

endif #_include_os_windows_mk

