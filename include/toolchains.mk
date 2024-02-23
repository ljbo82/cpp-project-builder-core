# Copyright (c) 2022-2024 Leandro José Britto de Oliveira
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

ifndef cpb_builder_mk
    $(error This file cannot be manually included)
endif

ifndef cpb_include_toolchains_mk
cpb_include_toolchains_mk := $(lastword $(MAKEFILE_LIST))

# Reserved variables -----------------------------------------------------------
$(call FN_CHECK_RESERVED,cpb_include_toolchains_mk_host)
$(call FN_CHECK_RESERVED,cpb_include_toolchains_mk_layers)
$(call FN_CHECK_RESERVED,cpb_include_toolchains_mk_includes)
# ------------------------------------------------------------------------------

TOOLCHAIN ?= gcc

cpb_include_toolchains_mk_host := $(TOOLCHAIN)-$(HOST)

ifdef TOOLCHAIN_DIRS
    $(call FN_CHECK_ORIGIN,TOOLCHAIN_DIRS,file)
else
    ifneq ($(wildcard toolchains),)
        TOOLCHAIN_DIRS += toolchains
    endif
endif

TOOLCHAIN_DIRS := $(strip $(TOOLCHAIN_DIRS) $(dir $(cpb_builder_mk))toolchains)

# Precedence: From most specific to most generic. For example,
# for 'gcc-linux-arm-v7', accepted layers are:
#     gcc-linux-arm-v7 > gcc/linux/arm/v7 > gcc/linux/arm > gcc/linux > gcc
cpb_include_toolchains_mk_layers = $(cpb_include_toolchains_mk_host) $(call FN_REVERSE,$(call FN_HOST_FACTORIZE,$(cpb_include_toolchains_mk_host),-,/))

$(foreach toolchainDir,$(TOOLCHAIN_DIRS),$(foreach layer,$(cpb_include_toolchains_mk_layers),$(eval cpb_include_toolchains_mk_includes += $(if $(wildcard $(toolchainDir)/$(layer)/toolchain.mk),$(realpath $(toolchainDir)/$(layer)/toolchain.mk),))))

cpb_include_toolchains_mk_includes := $(strip $(cpb_include_toolchains_mk_includes))

ifneq ($(cpb_include_toolchains_mk_includes),)
    include $(cpb_include_toolchains_mk_includes)
endif

endif # ifndef cpb_include_toolchains_mk
