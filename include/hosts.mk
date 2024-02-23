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

# Host layers management

ifndef cpb_builder_mk
    $(error This file cannot be manually included)
endif

ifndef cpb_include_hosts_mk
cpb_include_hosts_mk := $(lastword $(MAKEFILE_LIST))

# Reserved variables -----------------------------------------------------------
$(call FN_CHECK_RESERVED,cpb_include_hosts_mk_layers)
$(call FN_CHECK_RESERVED,cpb_include_hosts_mk_layer_aux_parser)
$(call FN_CHECK_RESERVED,cpb_include_hosts_mk_includes)
$(call FN_CHECK_RESERVED,cpb_include_hosts_mk_src_dirs)
# ------------------------------------------------------------------------------

ifndef HOST
    ifdef NATIVE_HOST
        HOST := $(NATIVE_HOST)
    endif
endif

$(call FN_CHECK_NON_EMPTY,HOST)
$(call FN_CHECK_NO_WHITESPACE,HOST)

ifdef HOSTS_DIRS
    $(call FN_CHECK_ORIGIN,HOSTS_DIRS,file)
else
    ifneq ($(wildcard hosts),)
        HOSTS_DIRS += hosts
    endif
endif

HOSTS_DIRS := $(strip $(HOSTS_DIRS) $(dir $(cpb_builder_mk))hosts)

# Precedence: From most specific to most generic. For example,
# for host 'linux-arm-v7', accepted layers are:
#     linux-arm-v7 > linux/arm/v7 > linux/arm > linux
cpb_include_hosts_mk_layers = $(HOST) $(call FN_REVERSE,$(call FN_HOST_FACTORIZE,$(HOST),-,/))

# Auxiliar checker for 'host.mk' and 'src' directory in a layer directory ----
#
# This function will add values to 'cpb_include_hosts_mk_includes' and
# 'cpb_include_hosts_mk_src_dirs' on each call
#
# Syntax $(call cpb_include_hosts_mk_layer_aux_parser,hostsDir,layer)
define cpb_include_hosts_mk_layer_aux_parser
$(eval cpb_include_hosts_mk_includes += $(if $(wildcard $(1)/$(2)/host.mk),$(realpath $(1)/$(2)/host.mk),))
$(eval cpb_include_hosts_mk_src_dirs += $(if $(wildcard $(1)/$(2)/src),$(1)/$(2)/src,))
endef
# ------------------------------------------------------------------------------

$(foreach hostDir,$(HOSTS_DIRS),$(foreach layer,$(cpb_include_hosts_mk_layers),$(call cpb_include_hosts_mk_layer_aux_parser,$(hostDir),$(layer))))

cpb_include_hosts_mk_includes := $(strip $(cpb_include_hosts_mk_includes))
cpb_include_hosts_mk_src_dirs := $(strip $(cpb_include_hosts_mk_src_dirs))

ifneq ($(cpb_include_hosts_mk_includes),)
    include $(cpb_include_hosts_mk_includes)
endif

SRC_DIRS += $(cpb_include_hosts_mk_src_dirs)

endif # ifndef cpb_include_hosts_mk
