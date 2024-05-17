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
# Syntax: $(call fn_text,1:msg,[2:ansiColor=])
$(call cpb_functions_mk_check_reserved,fn_text)
fn_text = $(if $(and $(2),$(cpb_functions_mk_term_support_colors)),$(shell printf "\033[$(2)m$(subst ",\",$(1))\033[0m"),$(1))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [Miscellaneous functions] ===========================================================
# ------------------------------------------------------------------------------
# Converts a value to boolean.
#
# Syntax: $(call fn_bool,1:value,[2:defaultValue=0],[3:resultTrueValue=1][4:resultFalseValue=])
$(call cpb_functions_mk_check_reserved,fn_bool)
fn_bool = $(if $(call fn_eq,0,$(if $(1),$(1),0)),$(4),$(if $(3),$(3),1))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Logs an info message.
#
# Syntax: $(call fn_info,1:message,[2:skipColor=0])
$(call cpb_functions_mk_check_reserved,fn_info)
fn_info = $(info $(call fn_text,$(1),$(if $(call fn_bool,$(2)),,96)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Logs a warning message.
#
# Syntax: $(call fn_warning,1:message,[2:skipColor=0])
$(call cpb_functions_mk_check_reserved,fn_warning)
fn_warning = $(warning $(call fn_text,$(1),$(if $(call fn_bool,$(2)),,93)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Logs an error and raises a fault.
#
# Syntax: $(call fn_error,1:message,[2:skipColor=0])
$(call cpb_functions_mk_check_reserved,fn_error)
fn_error = $(error $(call fn_text,$(1),$(if $(call fn_bool,$(2)),,91)))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [Validations] =============================================================
# ------------------------------------------------------------------------------
# Ensures a variable is not defined until the call the function.
#
# Syntax: $(call fn_check_reserved,1:varName,[2:errorMessage=<predefined_message>])
$(call cpb_functions_mk_check_reserved,fn_check_reserved)
fn_check_reserved = $(if $($(1)),$(call fn_error,$(if $(2),$(2),[$(1)] Reserved variable)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures the origin of an variable.
#
# Syntax: $(call fn_check_origin,1:varName,2:expectedOrigin,[3:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_check_origin)
fn_check_origin = $(if $(call fn_eq,$(origin $(1)),$(2)),,$(call fn_error,$(if $(3),$(3),[$(1)] Unexpected origin: '$(origin $(1))' (expected: '$(2)'))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures the origin of an variable.
#
# Syntax: $(call fn_check_not_origin,1:varName,2:forbiddenOrigin,[3:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_check_not_origin)
fn_check_not_origin = $(if $(call fn_eq,$(origin $(1)),$(2)),$(call fn_error,$(if $(3),$(3),[$(1)] Forbidden origin: '$(origin $(1))')),)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures the contents of a variable is one among a list of accepted values.
#
# Syntax: $(call fn_check_options,1:varName,2:acceptedOptions,[3:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_check_options)
fn_check_options=$(if $(or $(word 2,$($(1))),$(filter-out $(2),$($(1)))),$(call fn_error,$(if $(3),$(3),[$(1)] Invalid value: '$($(1))')),)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Checks if a variable, which should NOT be empty, has an empty value.
#
# Syntax: $(call fn_check_not_empty,1:varName,[2:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_check_not_empty)
fn_check_not_empty=$(if $(strip $($(1))),,$(call fn_error,$(if $(2),$(2),[$(1)] Missing value)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Ensures a variable value has no whitespaces.
#
# Syntax: $(call fn_check_no_whitespace,1:varName,[2:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_check_no_whitespace)
fn_check_no_whitespace=$(if $(call fn_eq,0,$(words $($(1)))),,$(if $(call fn_eq,1,$(words $($(1)))),,$(call fn_error,$(if $(2),$(2),[$(1)] Value cannot have whitespaces: '$($(1))'))))
# ------------------------------------------------------------------------------
# ==============================================================================

# = [Constants] ================================================================
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
# Syntax: $(call fn_eq,1:srt1,2:str2)
$(call fn_check_reserved,fn_eq)
fn_eq = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Factorizes a host string (used to decompose host string into a list of compatible layers).
#
# Syntax: $(call fn_host_factorize,1:hostString,[2:delimiter=-],[3:replacement=/])
$(call fn_check_reserved,fn_host_factorize)
$(call fn_check_reserved,fn_host_factorize[prev])
fn_host_factorize = $(foreach token,$(subst $(if $(2),$(2),-), ,$(1)),$(eval fn_host_factorize[prev]=$(if $(fn_host_factorize[prev]),$(fn_host_factorize[prev])$(if $(3),$(3),/)$(token),$(token)))$(fn_host_factorize[prev]))$(eval undefine fn_host_factorize[prev])
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Reverses a list of words.
#
# Syntax: $(call fn_reverse,1:word1 word2 ...)
$(call fn_check_reserved,fn_reverse)
fn_reverse = $(strip $(if $(1),$(call fn_reverse,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Explodes a delimited word into a list of words.
#
# Syntax: $(call fn_split,1:delimitedWord,2:delimiter,[3:tokenPrefix=__?__])
$(call fn_check_reserved,fn_split)
$(call fn_check_reserved,fn_split[prefix])
fn_split[prefix] := __?__
fn_split = $(subst $(2), $(if $(3),$(3),$(fn_split[prefix])),$(if $(3),$(3),$(fn_split[prefix]))$(1))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns a token on delimited word (i.e. explodes the word into a list of words and returns a word of generated list).
#
# Syntax: $(call fn_token,1:delimitedWord,2:delimiter,3:index)
$(call fn_check_reserved,fn_token)
fn_token = $(subst $(fn_split[prefix]),,$(word $(3),$(call fn_split,$(1),$(2))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns a string removing duplicate words without sorting.
#
# Syntax: $(call fn_unique,1:word1 word2 ...)
$(call fn_check_reserved,fn_unique)
fn_unique = $(strip $(if $(1),$(firstword $(1)) $(call fn_unique,$(filter-out $(firstword $(1)),$(1)))))
# ------------------------------------------------------------------------------
# ==============================================================================

# ==[Semantic version functions] ===============================================
# ------------------------------------------------------------------------------
# Checks if a semantic version string is valid.
#
# Syntax: $(call fn_semver,1:semanticVersion,[2:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_semver)
fn_semver = $(if $(shell echo $(1) | grep -E '^[0-9]+(\.[0-9]+){$(comma)2}(\-[A-Za-z0-9_\.\-]+)*$$'),$(1),$(call fn_error,$(if $(2),$(2),[fn_semver] Invalid semantic version: '$(1)')))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# syntax: $(call fn_semver_token,1:semVer,2:tokenIndex)
$(call fn_check_reserved,fn_semver_token)
$(call fn_check_reserved,fn_semver_token[val])
fn_semver_token = $(eval fn_semver_token[val]=$(call fn_token,$(call fn_semver,$(1)),.,$(2)))$(if $(fn_semver_token[val]),$(fn_semver_token[val]),0)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Checks if a version is compatible with a minimum one. If version is not compatible, it raises an error.
#
# Syntax: $(call fn_semver_check_compat,1:minVersion,2:version,[3:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_semver_check_compat)
$(call fn_check_reserved,fn_semver_check_compat[cmp])
fn_semver_check_compat = $(eval fn_semver_check_compat[cmp] := $(call fn_semver_cmp,$(1),$(2)))$(if $(or $(call fn_eq,$(fn_semver_check_compat[cmp]),0),$(call fn_eq,$(fn_semver_check_compat[cmp]),-1),$(call fn_eq,$(fn_semver_check_compat[cmp]),-2)),,$(call fn_error,$(if $(3),$(3),[fn_semver_check_compat] Tested version is not compatible: '$(2)' (version should be '$(1)+'))))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Compares two semantic versions.
#
# Syntax: $(call fn_semver_cmp,1:v1,2:v2)
$(call fn_check_reserved,fn_semver_cmp)
$(call fn_check_reserved,fn_semver_cmp[major])
$(call fn_check_reserved,fn_semver_cmp[minor])
$(call fn_check_reserved,fn_semver_cmp[patch])
fn_semver_cmp = $(strip \
    $(eval fn_semver_cmp[major] := $(call fn_number_cmp,$(call fn_semver_major,$(1)),$(call fn_semver_major,$(2))))\
    $(eval fn_semver_cmp[minor] := $(call fn_number_cmp,$(call fn_semver_minor,$(1)),$(call fn_semver_minor,$(2))))\
    $(eval fn_semver_cmp[patch] := $(call fn_number_cmp,$(call fn_semver_patch,$(1)),$(call fn_semver_patch,$(2))))\
    $(if $(call fn_eq,$(fn_semver_cmp[major]),-1),-3,\
        $(if $(call fn_eq,$(fn_semver_cmp[major]),1),3,\
            $(if $(call fn_eq,$(fn_semver_cmp[minor]),-1),-2,\
                $(if $(call fn_eq,$(fn_semver_cmp[minor]),1),2,\
                    $(if $(call fn_eq,$(fn_semver_cmp[patch]),-1),-1,$(if $(call fn_eq,$(fn_semver_cmp[patch]),1),1,0))\
                )\
            )\
        )\
    )\
)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the major component for given version.
#
# Syntax: $(call fn_semver_major,1:semanticVersion)
$(call fn_check_reserved,fn_semver_major)
fn_semver_major = $(word 1,$(subst -, ,$(call fn_semver_token,$(1),1)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the minor component for given version.
#
# Syntax: $(call fn_semver_minor,1:semanticVersion)
$(call fn_check_reserved,fn_semver_minor)
fn_semver_minor = $(word 1,$(subst -, ,$(call fn_semver_token,$(1),2)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the patch component for given version.
#
# Syntax: $(call fn_semver_patch,1:semanticVersion)
$(call fn_check_reserved,fn_semver_patch)
fn_semver_patch = $ $(word 1,$(subst -, ,$(call fn_semver_token,$(1),3)))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the metadata component for given version.
#
# Syntax: $(call fn_semver_metadata,1:semanticVersion)
$(call fn_check_reserved,fn_semver_metadata)
fn_semver_metadata = $(subst $(space),-,$(wordlist 2,1000,$(subst -, ,$(call fn_semver,$(1)))))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [File system functions] ===================================================
# ------------------------------------------------------------------------------
# Lists files in a directory.
#
# Syntax: $(call fn_find_files,1:directory,[2:findFlags=])
$(call fn_check_reserved,fn_find_files)
fn_find_files = $(call fn_shell,cd $(1) 2> /dev/null && find . -type $(strip f $(2)) | sed 's:./::')
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Returns the relative path for going from `fromDir` to `toDir`.
#
# Syntax: $(call fn_rel_dir,1:fromDir,2:toDir)
$(call fn_check_reserved,fn_rel_dir)
fn_rel_dir = $(call fn_shell,realpath -m --relative-to=$(1) $(2))
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Checks if a path is inside a directory.
#
# Syntax: $(call fn_is_inside_dir,1:parentDir,2:path)
$(call fn_check_reserved,fn_is_inside_dir)
fn_is_inside_dir = $(filter $(abspath $(1)) $(abspath $(1)/%),$(abspath $(2)))
# ------------------------------------------------------------------------------
# ==============================================================================

# == [Miscellaneous] ===========================================================
# ------------------------------------------------------------------------------
# syntax: $(call fn_log,1:message,[verbose=0])
$(call fn_check_reserved,fn_log)
fn_log = $(eval fn_log[verbose] := $(call fn_bool,$(2)))$(eval fn_log[skipColor] := $(if $(fn_log[verbose]),,1))$(if $(and $(fn_log[verbose]),$(fn_log[pad])),$(info ),)$(call fn_info,$(1),$(fn_log[skipColor]))$(eval export fn_log[pad] := 1)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Numeric comparison of two numbers.
#
# Syntax: $(call fn_number_cmp,[1:first=0],[2:second=0])
$(call fn_check_reserved,fn_number_cmp)
fn_number_cmp = $(call fn_shell,if [ $(if $(1),$(1),0) -eq $(if $(1),$(1),0) ] 2> /dev/null && [ $(if $(2),$(2),0) -eq $(if $(2),$(2),0) ] 2> /dev/null; then if [ $(if $(1),$(1),0) -eq $(if $(2),$(2),0) ]; then echo 0; elif [ $(if $(1),$(1),0) -gt $(if $(2),$(2),0) ]; then echo 1; else echo -1; fi else echo "?"; fi)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Executes a shell command and returns execution output.
#
# Syntax: $(call fn_shell,1:cmd,[2:errorMessage=<predefined_message>])
$(call fn_check_reserved,fn_shell)
fn_shell = $(shell $(1))$(if $(call fn_eq,$(.SHELLSTATUS),0),,$(call fn_error,$(if $(2),$(2),[fn_shell] Execution error)))
# ------------------------------------------------------------------------------
# ==============================================================================

endif # ifndef cpb_functions_mk
