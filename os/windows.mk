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
ifeq ($(PROJ_NAME),  )
    $(error Missing PROJ_NAME)
endif

ifneq (1, $(words $(PROJ_NAME)))
    $(error PROJ_NAME cannot have spaces)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
__libPrefix       = lib
__sharedLibSuffix :=.dll
__staticLibSuffix := .dll.a

ifeq ($(DEBUG), 1)
    __debugSuffix := _d
endif

ifeq ($(PROJ_TYPE), app)
    _artifactName := $(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)
    _postDistDeps += $(distDir)/bin/$(_artifactName)
else
    ifeq ($(LIB_TYPE), static)
        _artifactName := $(__libPrefix)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(__staticLibSuffix)
    else
        _artifactName := $(__libPrefix)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(__sharedLibSuffix)
        _ldFlags      += -Wl,--out-implib,$(_artifactName).lib
        _ldFlags      += -Wl,--output-def,$(_artifactName).def
        _postDistDeps += $(distDir)/lib/$(_artifactName)
    endif
endif
# ------------------------------------------------------------------------------

# ==============================================================================
$(distDir)/bin/$(_artifactName): $(buildDir)/$(_artifactName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/bin
	$(v)ln $(buildDir)/$(_artifactName) $@
# ==============================================================================

# ==============================================================================
$(distDir)/lib/$(_artifactName): $(buildDir)/$(_artifactName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln $(fullBuildDir)/$(_artifactName) $@
# ==============================================================================

undefine __selfDir
undefine __libPrefix
undefine __sharedLibSuffix
undefine __staticLibSuffix
undefine __debugSuffix

endif #_include_os_windows_mk

