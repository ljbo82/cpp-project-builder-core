# Copyright (c) 2023 Leandro José Britto de Oliveira
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Host management

ifndef include_hosts_mk
include_hosts_mk := 1

ifndef project_mk
    $(error This file cannot be manually included)
endif

# Native host detection ********************************************************

# Hosts with supported auto-detection:
#    linux-x86, linux-x64, linux-arm, linux-arm64,
#    windows-x86, windows-x64, windows-arm, windows-arm64

ifdef NATIVE_OS
    $(error [NATIVE_OS] Reserved variable)
endif
ifdef NATIVE_ARCH
    $(error [NATIVE_ARCH] Reserved variable)
endif
ifdef NATIVE_HOST
    $(error [NATIVE_HOST] Reserved variable)
endif

ifeq ($(OS),Windows_NT)
    NATIVE_OS := windows
else
    include_hosts_mk_os := $(shell uname -s)
    ifneq ($(filter Linux linux,$(include_hosts_mk_os)),)
        NATIVE_OS := linux
    else
        ifneq ($(filter Darwin darwin, $(include_hosts_mk_os)),)
            NATIVE_OS := osx
        endif
    endif
endif

ifdef NATIVE_OS
    ifeq ($(NATIVE_OS),windows)
        include_hosts_mk_arch := $(shell cmd /C SET Processor | grep PROCESSOR_ARCHITECTURE | sed 's:PROCESSOR_ARCHITECTURE=::')
        ifeq ($(include_hosts_mk_arch),AMD64)
            NATIVE_ARCH := x64
        else
            ifeq ($(include_hosts_mk_arch),x86)
                NATIVE_ARCH := x86
            else
                ifneq ($(include_hosts_mk_arch),ARM32)
                    NATIVE_ARCH := arm
                else
                    ifeq ($(include_hosts_mk_arch),ARM64)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    else
        include_hosts_mk_arch := $(shell uname -m)
        ifeq ($(include_hosts_mk_arch),x86_64)
            NATIVE_ARCH := x64
        else
            ifneq ($(filter %86, $(include_hosts_mk_arch)),)
                NATIVE_ARCH := x86
            else
                ifneq ($(filter arm, $(include_hosts_mk_arch)),)
                    NATIVE_ARCH := arm
                else
                    ifneq ($(filter arm64, $(include_hosts_mk_arch)),)
                        NATIVE_ARCH := arm64
                    endif
                endif
            endif
        endif
    endif

    ifdef NATIVE_ARCH
        NATIVE_HOST := $(NATIVE_OS)-$(NATIVE_ARCH)
    else
        NATIVE_HOST := $(NATIVE_OS)
    endif
endif

ifndef HOST
    ifdef NATIVE_HOST
        HOST := $(NATIVE_HOST)
    endif
endif

ifeq ($(HOST),)
    $(error [HOST] Missing value)
else
    ifneq ($(words $(HOST)),1)
       $(error [HOST] Value cannot have whitespaces: $(HOST))
    endif
endif
# ******************************************************************************

# Host layers management *******************************************************

# Precedence:
# 1. Build-system-specific host definitions (from most generic to most specific,
#    for example: linux > linux/arm)
#
# 2. project-specific host definitions (from most generic to most specifc,
#    for example: linux > linux-arm > linux-arm-v9)


# Host layer factorizer auxiliary function template ----------------------------
#
# This template will be called multiple times in order to prepare the list of acceptable layers.
#
# Syntax: $(call include_hosts_mk_host_factorizer,hostLayer)
define include_hosts_mk_host_factorizer
include_hosts_mk_host_factorizer_current  := $$(if $$(include_hosts_mk_host_factorizer_previous),$$(include_hosts_mk_host_factorizer_previous)/$(1),$(1))
include_hosts_mk_host_factorizer_previous := $$(include_hosts_mk_host_factorizer_current)
include_hosts_mk_host_factorizer_factors  := $$(include_hosts_mk_host_factorizer_factors) $$(include_hosts_mk_host_factorizer_current)
endef
# ------------------------------------------------------------------------------

# Host layer factorizer auxiliary function -------------------------------------
#
# This function will set the accepted layers in the variable include_hosts_mk_host_factorizer_factors
#
# Syntax: $(call include_hosts_mk_host_factorize,hostString)
define include_hosts_mk_host_factorize
    undefine include_hosts_mk_host_factorizer_current
    undefine include_hosts_mk_host_factorizer_previous
    undefine include_hosts_mk_host_factorizer_factors
    $$(foreach token,$$(subst -, ,$(1)),$$(eval $$(call include_hosts_mk_host_factorizer,$$(token))))
endef
# ------------------------------------------------------------------------------

# Factorizer function for a host -----------------------------------------------
#
# Function will return a list of accepted layers for a given host.
#
# Syntax: $(call include_hosts_mk_fn_host_factorize,hostString)
include_hosts_mk_fn_host_factorize = $(eval $(call include_hosts_mk_host_factorize,$(1)))$(include_hosts_mk_host_factorizer_factors)

# Contains all valid layers for current HOST
include_hosts_mk_host_layers := $(strip $(call include_hosts_mk_fn_host_factorize,$(HOST)) $(HOST))

SKIP_DEFAULT_HOSTS_DIR ?= 0
ifneq ($(origin SKIP_DEFAULT_HOSTS_DIR),file)
    $(error [SKIP_DEFAULT_HOSTS_DIR] Not defined in a makefile (origin: $(origin SKIP_DEFAULT_HOSTS_DIR)))
endif
ifneq ($(SKIP_DEFAULT_HOSTS_DIR),0)
    ifneq ($(SKIP_DEFAULT_HOSTS_DIR),1)
        $(error [SKIP_DEFAULT_HOSTS_DIR] Invalid value: $(SKIP_DEFAULT_HOSTS_DIR))
    endif
endif
ifdef $(HOSTS_DIRS)
    ifneq ($(origin HOSTS_DIRS),file)
        $(error [HOSTS_DIRS] Not defined in a makefile (origin: $(origin HOSTS_DIRS)))
    endif
endif
ifeq ($(SKIP_DEFAULT_HOSTS_DIR),0)
    ifneq ($(wildcard hosts),)
        HOSTS_DIRS := hosts $(HOSTS_DIRS)
    endif
endif

HOSTS_DIRS := $(strip $(project_mk_self_dir)hosts $(HOSTS_DIRS))

# Auxiliar checker for 'host.mk' and 'src' directory into a layer directory ----
#
# This function will add values to 'include_hosts_mk_include_hosts_mk_includes' and
# 'include_hosts_mk_hosts_src_dirs' on each call
#
# Syntax $(call include_hosts_mk_layer_aux_parser,hostsDir,layer)
define include_hosts_mk_layer_aux_parser
include_hosts_mk_include_hosts_mk_includes += $(if $(wildcard $(1)/$(2)/host.mk),$(realpath $(1)/$(2)/host.mk),)
include_hosts_mk_hosts_src_dirs    += $(if $(wildcard $(1)/$(2)/src),$(1)/$(2)/src,)
endef
# ------------------------------------------------------------------------------

$(foreach hostDir,$(HOSTS_DIRS),$(eval $$(foreach layer,$$(include_hosts_mk_host_layers),$$(eval $$(call include_hosts_mk_layer_aux_parser,$(hostDir),$$(layer))))))

include_hosts_mk_include_hosts_mk_includes := $(strip $(include_hosts_mk_include_hosts_mk_includes))
include_hosts_mk_hosts_src_dirs    := $(strip $(include_hosts_mk_hosts_src_dirs))

ifneq ($(include_hosts_mk_include_hosts_mk_includes),)
    include $(include_hosts_mk_include_hosts_mk_includes)
endif

ifneq ($(filter app lib,$(PROJ_TYPE)),)
    SRC_DIRS := $(SRC_DIRS) $(include_hosts_mk_hosts_src_dirs)
endif
# ******************************************************************************

undefine include_hosts_mk_os
undefine include_hosts_mk_arch
undefine include_hosts_mk_host_factorizer
undefine include_hosts_mk_host_factorizer_current
undefine include_hosts_mk_host_factorizer_previous
undefine include_hosts_mk_host_factorizer_factors
undefine include_hosts_mk_host_factorize
undefine include_hosts_mk_fn_host_factorize
undefine include_hosts_mk_host_layers
undefine include_hosts_mk_layer_aux_parser
undefine include_hosts_mk_include_hosts_mk_includes
undefine include_hosts_mk_hosts_src_dirs

endif # ifndef include_hosts_mk
