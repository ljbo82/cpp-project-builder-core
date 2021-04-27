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

ifndef _include_os_linux_mk
_include_os_linux_mk := 1

__selfDir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__selfDir)../defs.mk

# ------------------------------------------------------------------------------
libPrefix       := lib
sharedLibSuffix := .so
staticLibSuffix := .a

ifeq ($(DEBUG), 1)
    __debugSuffix := _d
endif

ifeq ($(PROJ_TYPE), app)
    artifactName  := $(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)
    _postDistDeps += $(distDir)/bin/$(artifactName)
else
    ifeq ($(LIB_TYPE), static)
        artifactName  := $(libPrefix)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(staticLibSuffix)
        _postDistDeps += $(distDir)/lib/$(artifactName)
    else
        _artifactBaseName := $(libPrefix)$(PROJ_NAME)$(projVersionMajor)$(__debugSuffix)$(sharedLibSuffix)
        artifactName      := $(_artifactBaseName).$(projVersionMinor).$(projVersionPatch)
        _postBuildDeps    += $(buildDir)/$(_artifactBaseName)
        _postDistDeps     += $(distDir)/lib/$(artifactName)
        _postDistDeps     += $(distDir)/lib/$(_artifactBaseName)
    endif
endif
# ------------------------------------------------------------------------------

# _postDistDeps ================================================================
$(distDir)/bin/$(artifactName): $(buildDir)/$(artifactName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/bin
	$(v)ln $< $@

$(distDir)/lib/$(artifactName): $(buildDir)/$(artifactName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln $< $@

$(distDir)/lib/$(_artifactBaseName): $(buildDir)/$(_artifactBaseName)
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln $< $@
# ==============================================================================

# _postBuildDeps ===============================================================
$(buildDir)/$(_artifactBaseName): build $(buildDir)/$(artifactName)
	@printf "$(nl)[BUILD] $@\n"
	$(v)ln -sf $(notdir $<) $@
# ==============================================================================

undefine __selfDir
undefine __debugSuffix

endif #_include_os_linux_mk

