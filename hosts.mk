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

# host management

# Hosts with supported auto-detection:
#    linux-x86, linux-x64, linux-arm, linux-arm64,
#    windows-x86, windows-x64, windows-arm, windows-arm64

ifndef __hosts_mk__
__hosts_mk__ := 1

ifndef __project_mk__
    $(error This file cannot be manually included)
endif

# Native host detection ========================================================
ifeq ($(__TDC__),0)
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
        __hosts_mk_os__ := $(shell uname -s)
        ifneq ($(filter Linux linux,$(__hosts_mk_os__)),)
            NATIVE_OS := linux
        else
            ifneq ($(filter Darwin darwin, $(__hosts_mk_os__)),)
                NATIVE_OS := osx
            endif
        endif
    endif

    ifdef NATIVE_OS
        ifeq ($(NATIVE_OS),windows)
            __hosts_mk_arch__ := $(shell cmd /C SET Processor | grep PROCESSOR_ARCHITECTURE | sed 's:PROCESSOR_ARCHITECTURE=::')
            ifeq ($(__hosts_mk_arch__),AMD64)
                NATIVE_ARCH := x64
            else
                ifeq ($(__hosts_mk_arch__),x86)
                    NATIVE_ARCH := x86
                else
                    ifneq ($(__hosts_mk_arch__),ARM32)
                        NATIVE_ARCH := arm
                    else
                        ifeq ($(__hosts_mk_arch__),ARM64)
                            NATIVE_ARCH := arm64
                        endif
                    endif
                endif
            endif
        else
            __hosts_mk_arch__ := $(shell uname -m)
            ifeq ($(__hosts_mk_arch__),x86_64)
                NATIVE_ARCH := x64
            else
                ifneq ($(filter %86, $(__hosts_mk_arch__)),)
                    NATIVE_ARCH := x86
                else
                    ifneq ($(filter arm, $(__hosts_mk_arch__)),)
                        NATIVE_ARCH := arm
                    else
                        ifneq ($(filter arm64, $(__hosts_mk_arch__)),)
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
endif

ifeq ($(HOST),)
    $(error [HOST] Missing value)
else
    ifneq ($(words $(HOST)),1)
       $(error [HOST] Value cannot have whitespaces: $(HOST))
    endif
endif
# ==============================================================================

# Host layers management =======================================================

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
# Syntax: $(call __hosts_mk_host_factorizer__,hostLayer)
define __hosts_mk_host_factorizer__
__hosts_mk_host_factorizer_current__  := $$(if $$(__hosts_mk_host_factorizer_previous__),$$(__hosts_mk_host_factorizer_previous__)/$(1),$(1))
__hosts_mk_host_factorizer_previous__ := $$(__hosts_mk_host_factorizer_current__)
__hosts_mk_host_factorizer_factors__  := $$(__hosts_mk_host_factorizer_factors__) $$(__hosts_mk_host_factorizer_current__)
endef
# ------------------------------------------------------------------------------

# Host layer factorizer auxiliary function -------------------------------------
#
# This function will set the accepted layers in the variable __hosts_mk_host_factorizer_factors__
#
# Syntax: $(call __hosts_mk_host_factorize__,hostString)
define __hosts_mk_host_factorize__
    undefine __hosts_mk_host_factorizer_current__
    undefine __hosts_mk_host_factorizer_previous__
    undefine __hosts_mk_host_factorizer_factors__
    $$(foreach token,$$(subst -, ,$(1)),$$(eval $$(call __hosts_mk_host_factorizer__,$$(token))))
endef
# ------------------------------------------------------------------------------

# Factorizer function for a host -----------------------------------------------
#
# Function will return a list of accepted layers for a given host.
#
# Syntax: $(call __hosts_mk_host_factorize__,hostString)
__hosts_mk_fn_host_factorize__ = $(eval $(call __hosts_mk_host_factorize__,$(1)))$(__hosts_mk_host_factorizer_factors__)

# Contains all valid layers for current HOST
__hosts_mk_host_layers__ := $(call FN_UNIQUE,$(call __hosts_mk_fn_host_factorize__,$(HOST)) $(HOST))

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

HOSTS_DIRS := $(call FN_UNIQUE,$(HOSTS_DIRS) $(__hosts_mk_self_dir__)hosts)

# Auxiliar checker for 'host.mk' and 'src' directory into a layer directory ----
#
# This function will add values to '__hosts_mk_hosts_mk_includes__' and
# '__hosts_mk_hosts_src_dirs__' on each call
#
# Syntax $(call __hosts_mk_layer_aux_parser__,hostsDir,layer)
define __hosts_mk_layer_aux_parser__
__hosts_mk_hosts_mk_includes__ += $(if $(wildcard $(1)/$(2)/host.mk),$(realpath $(1)/$(2)/host.mk),)
__hosts_mk_hosts_src_dirs__    += $(if $(wildcard $(1)/$(2)/src),$(1)/$(2)/src,)
endef
# ------------------------------------------------------------------------------

$(foreach hostDir,$(HOSTS_DIRS),$(eval $$(foreach layer,$$(__hosts_mk_host_layers__),$$(eval $$(call __hosts_mk_layer_aux_parser__,$(hostDir),$$(layer))))))

__hosts_mk_hosts_mk_includes__ := $(call FN_UNIQUE,$(strip $(__hosts_mk_hosts_mk_includes__)))
__hosts_mk_hosts_src_dirs__    := $(strip $(__hosts_mk_hosts_src_dirs__))

ifneq ($(__hosts_mk_hosts_mk_includes__),)
    include $(__hosts_mk_hosts_mk_includes__)
endif

ifneq ($(filter app lib,$(PROJ_TYPE)),)
    SRC_DIRS := $(call FN_UNIQUE,$(SRC_DIRS) $(__hosts_mk_hosts_src_dirs__))
endif
#===============================================================================

undefine __hosts_mk_os__
undefine __hosts_mk_arch__
undefine __hosts_mk_host_factorizer__
undefine __hosts_mk_host_factorizer_current__
undefine __hosts_mk_host_factorizer_previous__
undefine __hosts_mk_host_factorizer_factors__
undefine __hosts_mk_host_factorize__
undefine __hosts_mk_fn_host_factorize__
undefine __hosts_mk_host_layers__
undefine __hosts_mk_layer_aux_parser__
undefine __hosts_mk_hosts_mk_includes__
undefine __hosts_mk_hosts_src_dirs__

endif # ifndef __hosts_mk__
