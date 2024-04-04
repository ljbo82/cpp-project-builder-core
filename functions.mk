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

# Helper functions

ifndef cpb_functions_mk
cpb_functions_mk := $(lastword $(MAKEFILE_LIST))

# Checks if a reserved variable is defined elsewhere
#
# Syntax: $(call fn_check_reserved,varName,errorMessage=?)
$(call fn_check_reserved,fn_check_reserved)
fn_check_reserved = $(if $($(1)),$(error $(if $(2),$(2),[$(1)] Reserved variable)))

# = [Constants] ================================================================
$(call fn_check_reserved,cpb_functions_mk_split_prefix)
cpb_functions_mk_split_prefix := __?__

$(call fn_check_reserved,cpb_functions_mk_comma)
cpb_functions_mk_comma :=,

$(call fn_check_reserved,cpb_functions_mk_empty)
cpb_functions_mk_empty :=

$(call fn_check_reserved,cpb_functions_mk_space)
cpb_functions_mk_space := $(cpb_functions_mk_empty) $(cpb_functions_mk_empty)
# ==============================================================================

# = [Text functions] ===========================================================
$(call fn_check_reserved,fn_split)
fn_split = $(subst $(2), $(if $(3),$(3),$(cpb_functions_mk_split_prefix)),$(if $(3),$(3),$(cpb_functions_mk_split_prefix))$(1))

$(call fn_check_reserved,fn_token)
fn_token = $(subst $(cpb_functions_mk_split_prefix),,$(word $(3),$(call fn_split,$(1),$(2))))

$(call fn_check_reserved,fn_unique)
fn_unique = $(strip $(if $(1),$(firstword $(1)) $(call fn_unique,$(filter-out $(firstword $(1)),$(1)))))

$(call fn_check_reserved,fn_eq)
fn_eq = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))

$(call fn_check_reserved,fn_reverse)
fn_reverse = $(strip $(if $(1),$(call fn_reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1)))
# ==============================================================================

# ==[Semantic version functions] ===============================================
$(call fn_check_reserved,fn_semver)
$(call fn_check_reserved,fn_semver_val)
fn_semver = $(if $(shell echo $(1) | grep -E '^[0-9]+(\.[0-9]+){$(cpb_functions_mk_comma)2}(\-[A-Za-z0-9_\.\-]+)*$$'),$(1),$(error $(if $(2),$(2),[fn_semver] Invalid semantic version: $(1))))

# syntax: $(call cpb_functions_mk_semver_token,semVer,tokenIndex)
$(call fn_check_reserved,cpb_functions_mk_semver_token)
cpb_functions_mk_semver_token = $(eval fn_semver_val=$(call fn_token,$(call fn_semver,$(1)),.,$(2)))$(if $(fn_semver_val),$(fn_semver_val),0)

$(call fn_check_reserved,fn_semver_major)
fn_semver_major = $(word 1,$(subst -, ,$(call cpb_functions_mk_semver_token,$(1),1)))

$(call fn_check_reserved,fn_semver_minor)
fn_semver_minor = $(word 1,$(subst -, ,$(call cpb_functions_mk_semver_token,$(1),2)))

$(call fn_check_reserved,fn_semver_patch)
fn_semver_patch = $ $(word 1,$(subst -, ,$(call cpb_functions_mk_semver_token,$(1),3)))

$(call fn_check_reserved,fn_semver_metadata)
fn_semver_metadata = $(subst $(cpb_functions_mk_space),-,$(wordlist 2,1000,$(subst -, ,$(call fn_semver,$(1)))))

$(call fn_check_reserved,fn_semver_cmp)
$(call fn_check_reserved,fn_semver_cmp_major)
$(call fn_check_reserved,fn_semver_cmp_minor)
$(call fn_check_reserved,fn_semver_cmp_patch)
fn_semver_cmp = $(strip \
    $(eval fn_semver_cmp_major := $(call fn_number_cmp,$(call fn_semver_major,$(1)),$(call fn_semver_major,$(2))))\
    $(eval fn_semver_cmp_minor := $(call fn_number_cmp,$(call fn_semver_minor,$(1)),$(call fn_semver_minor,$(2))))\
    $(eval fn_semver_cmp_patch := $(call fn_number_cmp,$(call fn_semver_patch,$(1)),$(call fn_semver_patch,$(2))))\
    $(if $(call fn_eq,$(fn_semver_cmp_major),-1),-3,\
        $(if $(call fn_eq,$(fn_semver_cmp_major),1),3,\
            $(if $(call fn_eq,$(fn_semver_cmp_minor),-1),-2,\
                $(if $(call fn_eq,$(fn_semver_cmp_minor),1),2,\
                    $(if $(call fn_eq,$(fn_semver_cmp_patch),-1),-1,$(if $(call fn_eq,$(fn_semver_cmp_patch),1),1,0))\
                )\
            )\
        )\
    )\
)

$(call fn_check_reserved,fn_semver_check_compat)
$(call fn_check_reserved,fn_semver_check_compat_cmp)

fn_semver_check_compat = $(eval fn_semver_check_compat_cmp := $(call fn_semver_cmp,$(2),$(1)))$(if $(or $(call fn_eq,$(fn_semver_check_compat_cmp),0),$(call fn_eq,$(fn_semver_check_compat_cmp),1)),,$(error $(if $(3),$(3),[fn_semver_check_compat] Tested version is not compatible: $(2) (version should be $(1)+))))
# ==============================================================================

# == [File system functions] ===================================================
$(call fn_check_reserved,fn_find_files)
fn_find_files = $(call fn_shell,cd $(1) 2> /dev/null && find . -type f $(2) | sed 's:./::')

$(call fn_check_reserved,fn_rel_dir)
fn_rel_dir = $(call fn_shell,realpath -m --relative-to=$(1) $(2))

$(call fn_check_reserved,fn_is_inside_dir)
fn_is_inside_dir = $(filter $(abspath $(1)) $(abspath $(1)/%),$(abspath $(2)))
# ==============================================================================

# == [General utils] ===========================================================
$(call fn_check_reserved,fn_number_cmp)
fn_number_cmp = $(call fn_shell,if [ $(if $(1),$(1),0) -eq $(if $(1),$(1),0) ] 2> /dev/null && [ $(if $(2),$(2),0) -eq $(if $(2),$(2),0) ] 2> /dev/null; then if [ $(if $(1),$(1),0) -eq $(if $(2),$(2),0) ]; then echo 0; elif [ $(if $(1),$(1),0) -gt $(if $(2),$(2),0) ]; then echo 1; else echo -1; fi else echo "?"; fi)

$(call fn_check_reserved,fn_host_factorize)
$(call fn_check_reserved,fn_host_factorize_previous)
fn_host_factorize = $(foreach token,$(subst $(if $(2),$(2),-), ,$(1)),$(eval fn_host_factorize_previous=$(if $(fn_host_factorize_previous),$(fn_host_factorize_previous)$(if $(3),$(3),/)$(token),$(token)))$(fn_host_factorize_previous))$(eval undefine fn_host_factorize_previous)

$(call fn_check_reserved,fn_shell)
fn_shell = $(shell $(1))$(if $(call fn_eq,$(.SHELLSTATUS),0),,$(error $(if $(2),$(2),[fn_shell] Execution error)))

$(call fn_check_reserved,fn_check_origin)
fn_check_origin = $(if $(call fn_eq,$(origin $(1)),$(2)),,$(error $(if $(3),$(3),[$(1)] Unexpected origin: "$(origin $(1))" (expected: "$(2)"))))

$(call fn_check_reserved,fn_check_options)
fn_check_options=$(if $(or $(word 2,$($(1))),$(filter-out $(2),$($(1)))),$(error $(if $(3),$(3),[$(1)] Invalid value: $($(1)))),)

$(call fn_check_reserved,fn_check_non_empty)
fn_check_non_empty=$(if $(strip $($(1))),,$(error $(if $(2),$(2),[$(1)] Missing value)))

$(call fn_check_reserved,fn_check_no_whitespace)
fn_check_no_whitespace=$(if $(call fn_eq,0,$(words $($(1)))),,$(if $(call fn_eq,1,$(words $($(1)))),,$(error $(if $(2),$(2),[$(1)] Value cannot have whitespaces: "$($(1))"))))
# ==============================================================================

# == [Colored output] ==========================================================
$(call fn_check_reserved,cpb_functions_mk_term_support_colors)
$(call fn_check_reserved,fn_colored_text)
$(call fn_check_reserved,fn_log)
$(call fn_check_reserved,fn_log_info)

cpb_functions_mk_term_support_colors := $(shell tput colors 2> /dev/null)
ifneq ($(cpb_functions_mk_term_support_colors),)
    ifneq ($(cpb_functions_mk_term_support_colors),0)
        cpb_functions_mk_term_support_colors := 1
    else
        cpb_functions_mk_term_support_colors :=
    endif
endif

fn_colored_text = $(if $(and $(cpb_functions_mk_term_support_colors),$(1)),\033[$(1)m,)$(2)$(if $(and $(cpb_functions_mk_term_support_colors),$(1)),\033[0m,)

fn_log = @printf "$(if $(1),\n,)$(call fn_colored_text,$(1),$(2))\n"

fn_log_info = $(call fn_log,$(if $(call fn_eq,$(if $(1),$(1),0),0),,96),$(2))
# ==============================================================================

endif # ifndef cpb_functions_mk
