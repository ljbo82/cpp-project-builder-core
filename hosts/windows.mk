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

ifndef _include_hosts_windows_mk
_include_hosts_windows_mk := 1

# ------------------------------------------------------------------------------
ifeq ($(_project_mk_dir), )
    $(error project.mk not included yet)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(CROSS_COMPILE), )
    ifeq ($(hostArch), x64)
        CROSS_COMPILE := x86_64-w64-mingw32-
    else
        ifeq ($(hostArch), x86)
            CROSS_COMPILE := i686-w64-mingw32-
        else
            _preBuildError := Missing CROSS_COMPILE for HOST '$(HOST)'
        endif
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), app)
    __postTargets := 0
    ifeq ($(ARTIFACT_NAME), )
        ARTIFACT_NAME := $(ARTIFACT_BASE_NAME).exe
    endif
else
    ifeq ($(LIB_TYPE), static)
        __postTargets := 0
        ifeq ($(ARTIFACT_NAME), )
            ARTIFACT_NAME := lib$(ARTIFACT_BASE_NAME).a
        endif
    else
        ifeq ($(ARTIFACT_NAME), )
            __postTargets := 1
            ARTIFACT_NAME := $(ARTIFACT_BASE_NAME).dll

            ldFlags       += -Wl,--out-implib,$(buildDir)/$(ARTIFACT_NAME).lib
            ldFlags       += -Wl,--output-def,$(buildDir)/$(ARTIFACT_NAME).def
            postDistDeps  += $(distDir)/lib/$(ARTIFACT_NAME).lib
            postDistDeps  += $(distDir)/lib/$(ARTIFACT_NAME).def
        else
            __postTargets := 0
        endif
    endif
endif
# ------------------------------------------------------------------------------

# postDistDeps =================================================================
ifeq ($(__postTargets), 1)
$(distDir)/lib/$(ARTIFACT_NAME).lib: $(buildDir)/$(ARTIFACT_NAME).lib
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln -f $< $@

$(distDir)/lib/$(ARTIFACT_NAME).def: $(buildDir)/$(ARTIFACT_NAME).def
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln -f $< $@
endif
# ==============================================================================

undefine __postTargets

endif #_include_hosts_windows_mk
