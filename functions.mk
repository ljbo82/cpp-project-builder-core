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

# == [Checking terminal capabilities] ==========================================
# ------------------------------------------------------------------------------
$(if $(cpb_functions_mk_check_reserved),$(error [cpb_functions_mk_check_reserved] Reserved variable))
cpb_functions_mk_check_reserved = $(if $($(1)),$(error $(if $(2),$(2),[$(1)] Reserved variable)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
$(call cpb_functions_mk_check_reserved,cpb_functions_mk_term_support_colors)
cpb_functions_mk_term_support_colors := $(shell tput colors 2> /dev/null)
ifneq ($(cpb_functions_mk_term_support_colors),)
    ifneq ($(cpb_functions_mk_term_support_colors),0)
        cpb_functions_mk_term_support_colors := 1
    else
        cpb_functions_mk_term_support_colors :=
    endif
endif
# ------------------------------------------------------------------------------
# ==============================================================================

# = [Text functions] ===========================================================
# ------------------------------------------------------------------------------
#Generate a colored string.
#
# Syntax: $(call fn_text,[ansiColor],msg)
$(call cpb_functions_mk_check_reserved,fn_text)
fn_text = $(shell printf "$(if $(and $(cpb_functions_mk_term_support_colors),$(1)),\033[$(1)m,)$(subst ",\",$(2))$(if $(and $(cpb_functions_mk_term_support_colors),$(1)),\033[0m,)")
# ------------------------------------------------------------------------------
# ==============================================================================

# == [Miscellaneous functions] ===========================================================
# ------------------------------------------------------------------------------
# Logs a warning message.
#
# Syntax: $(call fn_warning,message)
$(call cpb_functions_mk_check_reserved,fn_warning)
fn_warning = $(warning $(call fn_text,93,$(1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Logs an error and raises a fault.
#
# Syntax: $(call fn_error,message)
$(call cpb_functions_mk_check_reserved,fn_error)
fn_error = $(error $(call fn_text,91,$(1)))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [Validations] =============================================================
# ------------------------------------------------------------------------------
# Ensures a variable is not defined until the call the function.
#
# Syntax: $(call fn_check_reserved,varName,[errorMessage])
$(call cpb_functions_mk_check_reserved,fn_check_reserved)
fn_check_reserved = $(if $($(1)),$(call fn_error,$(if $(2),$(2),[$(1)] Reserved variable)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures the origin of an variable.
#
# Syntax: $(call fn_check_origin,varName,expectedOrigin,[errorMessage])
$(call fn_check_reserved,fn_check_origin)
fn_check_origin = $(if $(call fn_eq,$(origin $(1)),$(2)),,$(call fn_error,$(if $(3),$(3),[$(1)] Unexpected origin: '$(origin $(1))' (expected: '$(2)'))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures the origin of an variable.
#
# Syntax: $(call fn_check_not_origin,varName,forbiddenOrigin,[errorMessage])
$(call fn_check_reserved,fn_check_not_origin)
fn_check_not_origin = $(if $(call fn_eq,$(origin $(1)),$(2)),$(call fn_error,$(if $(3),$(3),[$(1)] Forbidden origin: '$(origin $(1))')),)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures the contents of a variable is one among a list of accepted values.
#
# Syntax: $(call fn_check_options,varName,acceptedOptions,[errorMessage])
$(call fn_check_reserved,fn_check_options)
fn_check_options=$(if $(or $(word 2,$($(1))),$(filter-out $(2),$($(1)))),$(call fn_error,$(if $(3),$(3),[$(1)] Invalid value: '$($(1))')),)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Checks if a variable, which should NOT be empty, has an empty value.
#
# Syntax: $(call fn_check_not_empty,varName,[errorMessage])
$(call fn_check_reserved,fn_check_not_empty)
fn_check_not_empty=$(if $(strip $($(1))),,$(call fn_error,$(if $(2),$(2),[$(1)] Missing value)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures a variable value has no whitespaces.
#
# Syntax: $(call fn_check_no_whitespace,varName,[errorMessage])
$(call fn_check_reserved,fn_check_no_whitespace)
fn_check_no_whitespace=$(if $(call fn_eq,0,$(words $($(1)))),,$(if $(call fn_eq,1,$(words $($(1)))),,$(call fn_error,$(if $(2),$(2),[$(1)] Value cannot have whitespaces: '$($(1))'))))
# ------------------------------------------------------------------------------
# ==============================================================================

# = [Constants] ================================================================
# ------------------------------------------------------------------------------
$(call fn_check_reserved,cpb_functions_mk_split_prefix)
cpb_functions_mk_split_prefix := __?__
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
$(call fn_check_reserved,comma)
comma :=,
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
$(call fn_check_reserved,empty)
empty :=
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
$(call fn_check_reserved,space)
space := $(empty) $(empty)
# ------------------------------------------------------------------------------
# ==============================================================================

# = [Text functions] ===========================================================
# ------------------------------------------------------------------------------
# Checks if two strings are equal each other.
#
# Syntax: $(call fn_eq,srt1,str2)
$(call fn_check_reserved,fn_eq)
fn_eq = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Factorizes a host string (used to decompose host string into a list of compatible layers).
#
# Syntax: $(call fn_host_factorize,hostString,[delimiter],[replacement])
$(call fn_check_reserved,fn_host_factorize)
$(call fn_check_reserved,cpb_functions_mk_host_factorize_prev)
fn_host_factorize = $(foreach token,$(subst $(if $(2),$(2),-), ,$(1)),$(eval cpb_functions_mk_host_factorize_prev=$(if $(cpb_functions_mk_host_factorize_prev),$(cpb_functions_mk_host_factorize_prev)$(if $(3),$(3),/)$(token),$(token)))$(cpb_functions_mk_host_factorize_prev))$(eval undefine cpb_functions_mk_host_factorize_prev)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Reverses a list of words.
#
# Syntax: $(call fn_reverse,word1 word2 ...)
$(call fn_check_reserved,fn_reverse)
fn_reverse = $(strip $(if $(1),$(call fn_reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Explodes a delimited word into a list of words.
#
# Syntax: $(call fn_split,delimitedWord,delimiter,[tokenPrefix])
$(call fn_check_reserved,fn_split)
fn_split = $(subst $(2), $(if $(3),$(3),$(cpb_functions_mk_split_prefix)),$(if $(3),$(3),$(cpb_functions_mk_split_prefix))$(1))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns a token on delimited word (i.e. explodes the word into a list of words and returns a word of generated list).
#
# Syntax: $(call fn_token,delimitedWord,delimiter,index)
$(call fn_check_reserved,fn_token)
fn_token = $(subst $(cpb_functions_mk_split_prefix),,$(word $(3),$(call fn_split,$(1),$(2))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns a string removing duplicate words without sorting.
#
# Syntax: $(call fn_unique,word1 word2 ...)
$(call fn_check_reserved,fn_unique)
fn_unique = $(strip $(if $(1),$(firstword $(1)) $(call fn_unique,$(filter-out $(firstword $(1)),$(1)))))
# ------------------------------------------------------------------------------
# ==============================================================================

# ==[Semantic version functions] ===============================================
# ------------------------------------------------------------------------------
# Checks if a semantic version string is valid.
#
# Syntax: $(call fn_semver,semanticVersion,[errorMessage])
$(call fn_check_reserved,fn_semver)
$(call fn_check_reserved,cpb_functions_mk_semver_val)
fn_semver = $(if $(shell echo $(1) | grep -E '^[0-9]+(\.[0-9]+){$(comma)2}(\-[A-Za-z0-9_\.\-]+)*$$'),$(1),$(call fn_error,$(if $(2),$(2),[fn_semver] Invalid semantic version: '$(1)')))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Checks if a version is compatible with a minimum one. If version is not compatible, it raises an error.
#
# Syntax: $(call fn_semver_check_compat,minVersion,version,[errorMessage])
$(call fn_check_reserved,fn_semver_check_compat)
$(call fn_check_reserved,fn_semver_check_compat_cmp)
fn_semver_check_compat = $(eval fn_semver_check_compat_cmp := $(call fn_semver_cmp,$(1),$(2)))$(if $(or $(call fn_eq,$(fn_semver_check_compat_cmp),0),$(call fn_eq,$(fn_semver_check_compat_cmp),-1),$(call fn_eq,$(fn_semver_check_compat_cmp),-2)),,$(call fn_error,$(if $(3),$(3),[fn_semver_check_compat] Tested version is not compatible: '$(2)' (version should be '$(1)+'))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Compares two semantic versions.
#
# Syntax: $(call fn_semver_cmp,v1,v2)
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
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# syntax: $(call cpb_functions_mk_semver_token,semVer,tokenIndex)
$(call fn_check_reserved,cpb_functions_mk_semver_token)
cpb_functions_mk_semver_token = $(eval cpb_functions_mk_semver_val=$(call fn_token,$(call fn_semver,$(1)),.,$(2)))$(if $(cpb_functions_mk_semver_val),$(cpb_functions_mk_semver_val),0)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the major component for given version.
#
# Syntax: $(call fn_semver_major,semanticVersion)
$(call fn_check_reserved,fn_semver_major)
fn_semver_major = $(word 1,$(subst -, ,$(call cpb_functions_mk_semver_token,$(1),1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the minor component for given version.
#
# Syntax: $(call fn_semver_minor,semanticVersion)
$(call fn_check_reserved,fn_semver_minor)
fn_semver_minor = $(word 1,$(subst -, ,$(call cpb_functions_mk_semver_token,$(1),2)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the patch component for given version.
#
# Syntax: $(call fn_semver_patch,semanticVersion)
$(call fn_check_reserved,fn_semver_patch)
fn_semver_patch = $ $(word 1,$(subst -, ,$(call cpb_functions_mk_semver_token,$(1),3)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the metadata component for given version.
#
# Syntax: $(call fn_semver_metadata,semanticVersion)
$(call fn_check_reserved,fn_semver_metadata)
fn_semver_metadata = $(subst $(space),-,$(wordlist 2,1000,$(subst -, ,$(call fn_semver,$(1)))))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [File system functions] ===================================================
# ------------------------------------------------------------------------------
# Lists files in a directory.
#
# Syntax: $(call fn_find_files,directory,[findFlags])
$(call fn_check_reserved,fn_find_files)
fn_find_files = $(call fn_shell,cd $(1) 2> /dev/null && find . -type f $(2) | sed 's:./::')
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the relative path for going from `fromDir` to `toDir`.
#
# Syntax: $(call fn_rel_dir,fromDir,toDir)
$(call fn_check_reserved,fn_rel_dir)
fn_rel_dir = $(call fn_shell,realpath -m --relative-to=$(1) $(2))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Checks if a path is inside a directory.
#
# Syntax: $(call fn_is_inside_dir,parentDir,path)
$(call fn_check_reserved,fn_is_inside_dir)
fn_is_inside_dir = $(filter $(abspath $(1)) $(abspath $(1)/%),$(abspath $(2)))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [Miscellaneous] ===========================================================
# ------------------------------------------------------------------------------
# syntax: $(call cpb_functions_mk_log_cmd,[color],message)
$(call fn_check_reserved,cpb_functions_mk_log_cmd)
cpb_functions_mk_log_cmd = @printf "$(if $(and $(1),$(cpb_functions_mk_it)),\n,)$(call fn_text,$(1),$(2))\n$(eval export cpb_functions_mk_it := 1)"
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Generates an echo command (using `printf`) for log messages.
#
# Syntax: $(call fn_log_cmd,[useColor],msg)
$(call fn_check_reserved,fn_log_cmd)
fn_log_cmd = $(call cpb_functions_mk_log_cmd,$(if $(call fn_eq,$(if $(1),$(1),0),0),,96),$(2))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Numeric comparison of two numbers.
#
# Syntax: $(call fn_number_cmp,[first],[second])
$(call fn_check_reserved,fn_number_cmp)
fn_number_cmp = $(call fn_shell,if [ $(if $(1),$(1),0) -eq $(if $(1),$(1),0) ] 2> /dev/null && [ $(if $(2),$(2),0) -eq $(if $(2),$(2),0) ] 2> /dev/null; then if [ $(if $(1),$(1),0) -eq $(if $(2),$(2),0) ]; then echo 0; elif [ $(if $(1),$(1),0) -gt $(if $(2),$(2),0) ]; then echo 1; else echo -1; fi else echo "?"; fi)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Executes a shell command and returns execution output.
#
# Syntax: $(call fn_shell,cmd,[errorMessage])
$(call fn_check_reserved,fn_shell)
fn_shell = $(shell $(1))$(if $(call fn_eq,$(.SHELLSTATUS),0),,$(call fn_error,$(if $(2),$(2),[fn_shell] Execution error)))
# ------------------------------------------------------------------------------
# ==============================================================================

endif # ifndef cpb_functions_mk
