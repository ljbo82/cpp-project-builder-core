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
                    cxxFlags += -m32
                    cFlags   += -m32
                    ldFlags  += -m32
                else
                    $(error Missing CROSS_COMPILE for arch '$(hostArch)')
                endif
            else ifeq ($(hostArch), x64)
                ifeq ($(nativeArch), x86)
                    cxxFlags += -m64
                    cFlags   += -m64
                    ldFlags  += -m64
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
        override ARTIFACT_NAME := $(ARTIFACT_BASE_NAME)
    endif
else
    ifeq ($(LIB_TYPE), static)
        __postTargets := 0
        ifeq ($(ARTIFACT_NAME), )
            override ARTIFACT_NAME := lib$(ARTIFACT_BASE_NAME).a
        endif
    else
        ifeq ($(ARTIFACT_NAME), )
            __postTargets := 1
            override ARTIFACT_NAME := lib$(ARTIFACT_BASE_NAME).so.$(projVersionMinor).$(projVersionPatch)

            postBuildDeps += $(buildDir)/lib$(ARTIFACT_BASE_NAME).so
            postDistDeps  += $(distDir)/lib/lib$(ARTIFACT_BASE_NAME).so
        else
            __postTargets := 0
        endif
    endif
endif
# ------------------------------------------------------------------------------

# postBuildDeps ================================================================
ifeq ($(__postTargets), 1)
$(buildDir)/lib$(ARTIFACT_BASE_NAME).so: $(buildDir)/$(ARTIFACT_NAME)
	@printf "$(nl)[BUILD] $@\n"
	$(v)ln -sf $(notdir $<) $@
endif
# ==============================================================================

# postDistDeps =================================================================
ifeq ($(__postTargets), 1)
$(distDir)/lib/lib$(ARTIFACT_BASE_NAME).so: $(buildDir)/lib$(ARTIFACT_BASE_NAME).so
	@printf "$(nl)[DIST] $@\n"
	@mkdir -p $(distDir)/lib
	$(v)ln -f $< $@
endif
# ==============================================================================

undefine __postTargets

endif #_include_hosts_linux_mk

