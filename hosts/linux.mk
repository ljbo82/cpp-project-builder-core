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

ifndef _include_hosts_linux_mk
_include_hosts_linux_mk := 1

# ------------------------------------------------------------------------------
ifeq ($(_project_mk_dir), )
    $(error project.mk not included yet)
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(CROSS_COMPILE), )
    ifeq ($(nativeArch), )
        $(error Missing CROSS_COMPILE)
    else
        ifneq ($(hostArch), $(nativeArch))
            ifeq ($(hostArch), x86)
                ifeq ($(nativeArch), x64)
                    _cxxFlags += -m32
                    _cFlags   += -m32
                    _ldFlags  += -m32
                else
                    $(error Missing CROSS_COMPILE for arch '$(hostArch)')
                endif
            else ifeq ($(hostArch), x64)
                ifeq ($(nativeArch), x86)
                    _cxxFlags += -m64
                    _cFlags   += -m64
                    _ldFlags  += -m64
                else
                    $(error Missing CROSS_COMPILE for arch '$(hostArch)')
                endif
            else
                $(error Missing CROSS_COMPILE for arch '$(hostArch)')
            endif
        endif
    endif
endif
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
ifeq ($(PROJ_TYPE), app)
    __postTargets := 0
    ifeq ($(ARTIFACT_NAME), )
        ARTIFACT_NAME := $(ARTIFACT_BASE_NAME)
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
            ARTIFACT_NAME      := lib$(ARTIFACT_BASE_NAME).so.$(projVersionMinor).$(projVersionPatch)
            _postBuildDeps     += $(buildDir)/lib$(ARTIFACT_BASE_NAME).so
            _postDistDeps      += $(distDir)/lib/lib$(ARTIFACT_BASE_NAME).so
        else
            __postTargets := 0
        endif
    endif
endif
# ------------------------------------------------------------------------------

# _postBuildDeps ===============================================================
ifeq ($(__postTargets), 1)
$(buildDir)/lib$(ARTIFACT_BASE_NAME).so: $(buildDir)/$(ARTIFACT_NAME)
	@printf "$(nl)[BUILD] $@\n"
	$(v)ln -sf $(notdir $<) $@
endif
# ==============================================================================

# _postDistDeps ================================================================
ifeq ($(__postTargets), 1)
$(distDir)/lib/lib$(ARTIFACT_BASE_NAME).so: $(buildDir)/lib$(ARTIFACT_BASE_NAME).so
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln -f $< $@
endif
# ==============================================================================

undefine __postTargets

endif #_include_hosts_linux_mk

