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

override undefine include_hosts_mk_host_factorizer
override undefine include_hosts_mk_host_factorizer_current
override undefine include_hosts_mk_host_factorizer_previous
override undefine include_hosts_mk_host_factorizer_factors
override undefine include_hosts_mk_host_factorize
override undefine include_hosts_mk_fn_host_factorize
override undefine include_hosts_mk_host_layers
override undefine include_hosts_mk_layer_aux_parser
override undefine include_hosts_mk_include_hosts_mk_includes
override undefine include_hosts_mk_hosts_src_dirs

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

SKIP_DEFAULT_HOSTS_DIR ?= 0
$(call FN_CHECK_NON_EMPTY,SKIP_DEFAULT_INCLUDE_DIR)
$(call FN_CHECK_ORIGIN,SKIP_DEFAULT_HOSTS_DIR,file)
$(call FN_CHECK_WORDS,SKIP_DEFAULT_HOSTS_DIR,0 1)
ifdef $(HOSTS_DIRS)
    $(call FN_CHECK_ORIGIN,HOSTS_DIRS,file)
endif
ifeq ($(SKIP_DEFAULT_HOSTS_DIR),0)
    ifneq ($(wildcard hosts),)
        HOSTS_DIRS := hosts $(HOSTS_DIRS)
    endif
endif

HOSTS_DIRS := $(strip $(project_mk_self_dir)hosts $(HOSTS_DIRS))

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
    override undefine include_hosts_mk_host_factorizer_current
    override undefine include_hosts_mk_host_factorizer_previous
    override undefine include_hosts_mk_host_factorizer_factors
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

# Auxiliar checker for 'host.mk' and 'src' directory into a layer directory
#
# This function will add values to 'include_hosts_mk_include_hosts_mk_includes' and
# 'include_hosts_mk_hosts_src_dirs' on each call
#
# Syntax $(call include_hosts_mk_layer_aux_parser,hostsDir,layer)
define include_hosts_mk_layer_aux_parser
include_hosts_mk_include_hosts_mk_includes += $(if $(wildcard $(1)/$(2)/host.mk),$(realpath $(1)/$(2)/host.mk),)
include_hosts_mk_hosts_src_dirs += $(if $(wildcard $(1)/$(2)/src),$(1)/$(2)/src,)
endef
# ------------------------------------------------------------------------------

$(foreach hostDir,$(HOSTS_DIRS),$(eval $$(foreach layer,$$(include_hosts_mk_host_layers),$$(eval $$(call include_hosts_mk_layer_aux_parser,$(hostDir),$$(layer))))))

include_hosts_mk_include_hosts_mk_includes := $(strip $(include_hosts_mk_include_hosts_mk_includes))
include_hosts_mk_hosts_src_dirs := $(strip $(include_hosts_mk_hosts_src_dirs))

ifneq ($(include_hosts_mk_include_hosts_mk_includes),)
    include $(include_hosts_mk_include_hosts_mk_includes)
endif

SRC_DIRS := $(SRC_DIRS) $(include_hosts_mk_hosts_src_dirs)
# ******************************************************************************

endif # ifndef include_hosts_mk
