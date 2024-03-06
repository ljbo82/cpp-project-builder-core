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

# General purpose functions

ifndef cpb_include_functions_mk
cpb_include_functions_mk := $(lastword $(MAKEFILE_LIST))

# Checks if a reserved variable is defined elsewhere
#
# Syntax: $(call FN_CHECK_RESERVED,varName,errorMessage=?)
$(call FN_CHECK_RESERVED,FN_CHECK_RESERVED)
FN_CHECK_RESERVED = $(if $($(1)),$(error $(if $(2),$(2),[$(1)] Reserved variable)))

$(call FN_CHECK_RESERVED,cpb_include_functions_mk_token_prefix)
cpb_include_functions_mk_token_prefix := __?__

# = [Text functions] ===========================================================
# Splits a string into tokens.
#
# Since in makefiles empty tokens can be ignored, a token prefix can be
# used to force split of empty tokens (afterwards token prefix shall be
# removed).
#
# Syntax: $(call FN_SPLIT,baseString,delimiter,tokenPrefix?=$(cpb_include_functions_mk_token_prefix)
$(call FN_CHECK_RESERVED,FN_SPLIT)
FN_SPLIT = $(subst $(2), $(if $(3),$(3),$(cpb_include_functions_mk_token_prefix)),$(if $(3),$(3),$(cpb_include_functions_mk_token_prefix))$(1))

# Returns a token on delimited string.
#
# Syntax: $(call FN_TOKEN,baseString,delimiter,index)
$(call FN_CHECK_RESERVED,FN_TOKEN)
FN_TOKEN = $(subst $(cpb_include_functions_mk_token_prefix),,$(word $(3),$(call FN_SPLIT,$(1),$(2))))

# Removes duplicate words without sorting.
#
# Syntax: $(call FN_UNIQUE,list_of_words)
$(call FN_CHECK_RESERVED,FN_UNIQUE)
FN_UNIQUE = $(strip $(if $(1),$(firstword $(1)) $(call FN_UNIQUE,$(filter-out $(firstword $(1)),$(1)))))

# If str1 equals str2, returns str1. Otherwise, returns an empty value.
#
# Syntax: $(call FN_EQ,srt1,str2)
$(call FN_CHECK_RESERVED,FN_EQ)
FN_EQ = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))

# Reverses a list of words.
#
# Syntax: $(call FN_REVERSE,word1 word2 ...)
$(call FN_CHECK_RESERVED,FN_REVERSE)
FN_REVERSE = $(strip $(if $(1),$(call FN_REVERSE,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1)))

# Factorizes a host string (used to decompose host string into compatible layers).
#
# Syntax: $(call FN_HOST_FACTORIZE,factorized_string,delimiter?=-,replacements?=delimiter)
$(call FN_CHECK_RESERVED,FN_HOST_FACTORIZE)
$(call FN_CHECK_RESERVED,FN_HOST_FACTORIZE_previous)
FN_HOST_FACTORIZE = $(foreach token,$(subst $(if $(2),$(2),-), ,$(1)),$(eval FN_HOST_FACTORIZE_previous=$(if $(FN_HOST_FACTORIZE_previous),$(FN_HOST_FACTORIZE_previous)$(if $(3),$(3),$(if $(2),$(2),-))$(token),$(token)))$(FN_HOST_FACTORIZE_previous))$(eval undefine FN_HOST_FACTORIZE_previous)

# Numeric comparison of two numbers. Echoes the following output:
#
#  0: first == second
#  1: first > second
# -1: first < second
#  ?: Invalid values were given
#
# Syntax: $(call FN_NUMBER_CMP,first?=0,second?=0)
$(call FN_CHECK_RESERVED,FN_NUMBER_CMP)
FN_NUMBER_CMP = $(call FN_SHELL,if [ $(if $(1),$(1),0) -eq $(if $(1),$(1),0) ] 2> /dev/null && [ $(if $(2),$(2),0) -eq $(if $(2),$(2),0) ] 2> /dev/null; then if [ $(if $(1),$(1),0) -eq $(if $(2),$(2),0) ]; then echo 0; elif [ $(if $(1),$(1),0) -gt $(if $(2),$(2),0) ]; then echo 1; else echo -1; fi else echo "?"; fi)
# ==============================================================================

# ==[Semantic version functions] ===============================================
# Checks if a semantic version string is valid (returns the string if valid,
# otherwise returns an empty string).
#
# Syntax: $(call FN_SEMVER_CHECK,semanticVersion)
$(call FN_CHECK_RESERVED,FN_SEMVER_CHECK)
$(call FN_CHECK_RESERVED,FN_SEMVER_val)
$(call FN_CHECK_RESERVED,FN_SEMVER_CHECK_comma)
FN_SEMVER_CHECK_comma :=,
FN_SEMVER_CHECK = $(call FN_SHELL,echo $(1) | grep -E '^[0-9]+(.[0-9]+){$(FN_SEMVER_CHECK_comma)2}$$')

# Returns the major component for given version.
#
# Syntax: $(call FN_SEMVER_MAJOR,semanticVersion)
$(call FN_CHECK_RESERVED,FN_SEMVER_MAJOR)
FN_SEMVER_MAJOR = $(eval FN_SEMVER_val=$(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,1))$(if $(FN_SEMVER_val),$(FN_SEMVER_val),0)

# Returns the minor component for given version.
#
# Syntax: $(call FN_SEMVER_MINOR,semanticVersion)
$(call FN_CHECK_RESERVED,FN_SEMVER_MINOR)
FN_SEMVER_MINOR = $(eval FN_SEMVER_val=$(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,2))$(if $(FN_SEMVER_val),$(FN_SEMVER_val),0)

# Returns the patch component for given version.
#
# Syntax: $(call FN_SEMVER_PATCH,semanticVersion)
$(call FN_CHECK_RESERVED,FN_SEMVER_PATCH)
FN_SEMVER_PATCH = $(eval FN_SEMVER_val=$(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,3))$(if $(FN_SEMVER_val),$(FN_SEMVER_val),0)

# Compares two semantic versions. If tested version is compatible with
# minimum one, echoes tested version. Otherwise echoes an empty string
#
# Syntax: $(call FN_SEMVER_CMP,testVer,MinVer)
$(call FN_CHECK_RESERVED,FN_SEMVER_CMP)
$(call FN_CHECK_RESERVED,FN_SEMVER_CMP_major)
$(call FN_CHECK_RESERVED,FN_SEMVER_CMP_minor)
$(call FN_CHECK_RESERVED,FN_SEMVER_CMP_patch)
FN_SEMVER_CMP = $(strip \
    $(eval FN_SEMVER_CMP_major := $(call FN_NUMBER_CMP,$(call FN_SEMVER_MAJOR,$(1)),$(call FN_SEMVER_MAJOR,$(2))))\
    $(eval FN_SEMVER_CMP_minor := $(call FN_NUMBER_CMP,$(call FN_SEMVER_MINOR,$(1)),$(call FN_SEMVER_MINOR,$(2))))\
    $(eval FN_SEMVER_CMP_patch := $(call FN_NUMBER_CMP,$(call FN_SEMVER_PATCH,$(1)),$(call FN_SEMVER_PATCH,$(2))))\
    $(if $(call FN_EQ,$(FN_SEMVER_CMP_major),-1),,\
        $(if $(call FN_EQ,$(FN_SEMVER_CMP_major),1),,\
            $(if $(call FN_EQ,$(FN_SEMVER_CMP_minor),-1),,\
                $(if $(call FN_EQ,$(FN_SEMVER_CMP_minor),1),$(1),\
                    $(if $(call FN_EQ,$(FN_SEMVER_CMP_patch),-1),,$(1))\
                )\
            )\
        )\
    )\
)
# ==============================================================================

# == [File system functions] ===================================================
# Lists files in a directory.
#
# Syntax: $(call FN_FIND_FILES,directory,findFlags)
$(call FN_CHECK_RESERVED,FN_FIND_FILES)
FN_FIND_FILES = $(call FN_SHELL,cd $(1) 2> /dev/null && find . -type f $(2) | sed 's:./::')

# Returns the relative path for going from 'fromDir' to 'toDir'.
#
# Syntax: $(call FN_REL_DIR,fromDir,toDir)
$(call FN_CHECK_RESERVED,FN_REL_DIR)
FN_REL_DIR = $(call FN_SHELL,realpath -m --relative-to=$(1) $(2))

# Checks if a path is inside a directory (on success, returns the path,
# otherwise returns an empty value).
#
# Syntax $(call FN_IS_INSIDE_DIR,dir,path)
$(call FN_CHECK_RESERVED,FN_IS_INSIDE_DIR)
FN_IS_INSIDE_DIR = $(filter $(abspath $(1)) $(abspath $(1)/%),$(abspath $(2)))
# ==============================================================================

# == [Makefile utils] ==========================================================
# Executes a shell command and returns execution output.
#
# Syntax $(call FN_SHELL,cmd,errorMessage?=)
$(call FN_CHECK_RESERVED,FN_SHELL)
FN_SHELL = $(shell $(1))$(if $(call FN_EQ,$(.SHELLSTATUS),0),,$(error $(if $(2),$(2),[FN_SHELL] Execution error)))

# Checks if the origin of a variable matches with an expected value. If matching
# fails, throws an error.
#
# Syntax $(call FN_CHECK_ORIGIN,varName,expectedOrigin,errorMessage?=)
$(call FN_CHECK_RESERVED,FN_CHECK_ORIGIN)
FN_CHECK_ORIGIN = $(if $(call FN_EQ,$(origin $(1)),$(2)),,$(error $(if $(3),$(3),[$(1)] Unexpected origin: "$(origin $(1))" (expected: "$(2)"))))

# Checks for an unexpected/invalid words. If an invalid word is found,
# throws an error.
#
# Syntax: $(call FN_CHECK_OPTIONS,varName,acceptedOptions,errorMessage?=)
$(call FN_CHECK_RESERVED,FN_CHECK_OPTIONS)
FN_CHECK_OPTIONS=$(if $(or $(word 2,$($(1))),$(filter-out $(2),$($(1)))),$(error $(if $(3),$(3),[$(1)] Invalid value: $($(1)))),)

# Checks for a non-empty variable. If the value of $(varName) is empty, throws
# an error.
#
# Syntax: $(call FN_CHECK_NON_EMPTY,varName,errorMessage?=)
$(call FN_CHECK_RESERVED,FN_CHECK_NON_EMPTY)
FN_CHECK_NON_EMPTY=$(if $(strip $($(1))),,$(error $(if $(2),$(2),[$(1)] Missing value)))

# Checks if whitespaces are found in an expected non-whitespace variable.
# If a whitespace is found in $(varName), throws an error.
#
# Syntax: $(call FN_CHECK_NO_WHITESPACE,varName,errorMessage?=)
$(call FN_CHECK_RESERVED,FN_CHECK_NO_WHITESPACE)
FN_CHECK_NO_WHITESPACE=$(if $(call FN_EQ,0,$(words $($(1)))),,$(if $(call FN_EQ,1,$(words $($(1)))),,$(error $(if $(2),$(2),[$(1)] Value cannot have whitespaces: "$($(1))"))))
# ==============================================================================

# == [Colored output] ==========================================================
$(call FN_CHECK_RESERVED,cpb_include_functions_mk_term_support_colors)
$(call FN_CHECK_RESERVED,FN_COLORED_TEXT)
$(call FN_CHECK_RESERVED,FN_LOG)
$(call FN_CHECK_RESERVED,FN_LOG_INFO)

cpb_include_functions_mk_term_support_colors := $(shell tput colors 2> /dev/null)
ifneq ($(cpb_include_functions_mk_term_support_colors),)
    ifneq ($(cpb_include_functions_mk_term_support_colors),0)
        cpb_include_functions_mk_term_support_colors := 1
    else
        cpb_include_functions_mk_term_support_colors :=
    endif
endif

# Generate a colored string.
#
# NOTE: Real color support relies on terminal support. If there is no support
#       colors are ignored.
#
# Syntax: $(call FN_COLORED_TEXT,ansiColor?=,msg)
FN_COLORED_TEXT = $(if $(and $(cpb_include_functions_mk_term_support_colors),$(1)),\033[$(1)m,)$(2)$(if $(and $(cpb_include_functions_mk_term_support_colors),$(1)),\033[0m,)


# Generates an echo command for a log message.
#
# NOTE: Real color support relies on terminal support. If there is no support
#       colors are ignored.
#
# Syntax: $(call FN_LOG,color?=,msg)
FN_LOG = @printf "$(if $(1),\n,)$(call FN_COLORED_TEXT,$(1),$(2))\n"

# Generates an echo command for INFO log message
#
# NOTE: Real color support relies on terminal support. If there is no support
#       colors are ignored.
#
# Syntax: $(call FN_LOG_INFO,verbose?=0,msg)
FN_LOG_INFO = $(call FN_LOG,$(if $(call FN_EQ,$(if $(1),$(1),0),0),,96),$(2))
# ==============================================================================

endif # ifndef cpb_include_functions_mk
