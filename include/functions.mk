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

ifdef cpb_include_functions_mk_token_prefix
    $(error [cpb_include_functions_mk_token_prefix] Reserved variable)
endif

cpb_include_functions_mk_token_prefix := __?__

# Text functions ---------------------------------------------------------------

# Splits a string into tokens.
#
# Since in makefiles empty tokens can be ignored, a token prefix can be
# used to force split of empty tokens (afterwards token prefix shall be
# removed).
#
# Syntax: $(call FN_SPLIT,baseString,delimiter,tokenPrefix?=$(cpb_include_functions_mk_token_prefix)
ifdef FN_SPLIT
    $(error [FN_SPLIT] Reserved variable)
endif
FN_SPLIT = $(subst $(2), $(if $(3),$(3),$(cpb_include_functions_mk_token_prefix)),$(if $(3),$(3),$(cpb_include_functions_mk_token_prefix))$(1))

# Returns a token on delimited string.
#
# Syntax: $(call FN_TOKEN,baseString,delimiter,index)
ifdef FN_TOKEN
    $(error [FN_TOKEN] Reserved variable)
endif
FN_TOKEN = $(subst $(cpb_include_functions_mk_token_prefix),,$(word $(3),$(call FN_SPLIT,$(1),$(2))))

# Removes duplicate words without sorting.
#
# Syntax: $(call FN_UNIQUE,list_of_words)
ifdef FN_UNIQUE
    $(error [FN_UNIQUE] Reserved variable)
endif
FN_UNIQUE = $(strip $(if $(1),$(firstword $(1)) $(call FN_UNIQUE,$(filter-out $(firstword $(1)),$(1)))))

# If str1 equals str2, returns str1. Otherwise, returns an empty value.
#
# Syntax: $(call FN_EQ,srt1,str2)
ifdef FN_EQ
    $(error [FN_EQ] Reserved variable)
endif
FN_EQ = $(and $(findstring $(1),$(2)),$(findstring $(2),$(1)))

# Reverses a list of words.
#
# Syntax: $(call FN_REVERSE,word1 word2 ...)
ifdef FN_REVERSE
    $(error [FN_REVERSE] Reserved variable)
endif
FN_REVERSE = $(strip $(if $(1),$(call FN_REVERSE,$(wordlist 2,$(words $(1)),$(1)))) $(firstword $(1)))

# Factorizes a host string (used to decompose host string into compatible layers).
#
# Syntax: $(call FN_HOST_FACTORIZE,factorized_string,delimiter?=-,replacements?=delimiter)
ifdef FN_HOST_FACTORIZE
    $(error [FN_HOST_FACTORIZE] Reserved variable)
endif
ifdef FN_HOST_FACTORIZE_previous
    $(error [FN_HOST_FACTORIZE_previous] Reserved variable)
endif
FN_HOST_FACTORIZE = $(foreach token,$(subst $(if $(2),$(2),-), ,$(1)),$(eval FN_HOST_FACTORIZE_previous=$(if $(FN_HOST_FACTORIZE_previous),$(FN_HOST_FACTORIZE_previous)$(if $(3),$(3),$(if $(2),$(2),-))$(token),$(token)))$(FN_HOST_FACTORIZE_previous))$(eval undefine FN_HOST_FACTORIZE_previous)

# Numeric comparison of two numbers. Echoes the following output:
#
#  0: first == second
#  1: first > second
# -1: first < second
#
# Syntax: $(call FN_NUMBER_CMP,first?=0,second?=0)
ifdef FN_NUMBER_CMP
    $(error [FN_NUMBER_CMP] Reserved variable)
endif
FN_NUMBER_CMP = $(if $(call FN_EQ,$(if $(1),$(1),0),$(if $(2),$(2),0)),0,$(shell if [ $(if $(1),$(1),0) -gt $(if $(2),$(2),0) ]; then echo 1; else echo -1; fi))
# ------------------------------------------------------------------------------

# Semantic version functions ---------------------------------------------------

# Checks if a semantic version string is valid (returns the string if valid,
# otherwise returns an empty string).
#
# Syntax: $(call FN_SEMVER_CHECK,semanticVersion)
ifdef FN_SEMVER_CHECK
    $(error [FN_SEMVER_CHECK] Reserved variable)
endif
FN_SEMVER_CHECK = $(if $(filter-out 1 2 3,$(words $(call FN_SPLIT,$(1),.))),,$(1))

# Returns the major component for given version.
#
# Syntax: $(call FN_SEMVER_MAJOR,semanticVersion)
ifdef FN_SEMVER_MAJOR
    $(error [FN_SEMVER_MAJOR] Reserved variable)
endif
FN_SEMVER_MAJOR = $(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,1)

# Returns the minor component for given version.
#
# Syntax: $(call FN_SEMVER_MINOR,semanticVersion)
ifdef FN_SEMVER_MINOR
    $(error [FN_SEMVER_MINOR] Reserved variable)
endif
FN_SEMVER_MINOR = $(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,2)

# Returns the patch component for given version.
#
# Syntax: $(call FN_SEMVER_PATCH,semanticVersion)
ifdef FN_SEMVER_PATCH
    $(error [FN_SEMVER_PATCH] Reserved variable)
endif
FN_SEMVER_PATCH = $(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,3)

# Compares two semantic versions. Possible echoed values are:
#
# NOTE: patch component is ignored!
#
#  0: first == second
# -2: Incompatible versions (firstVer.major < secondVer.major)
#  2: Incompatible versions (firstVer.major > secondVer.major)
# -1: firstVer.major == secondVer.major AND firstVer.minor < secondVer.minor
#  1: firstVer.major == secondVer.major AND firstVer.minor > secondVer.minor
#
# Syntax: $(call FN_SEMVER_CMP,firstVer,secondVer)
ifdef FN_SEMVER_CMP
    $(error [FN_SEMVER_CMP] Reserved variable)
endif
ifdef FN_SEMVER_CMP_MAJOR
    $(error [FN_SEMVER_CMP_MAJOR] Reserved variable)
endif
ifdef FN_SEMVER_CMP_MINOR
    $(error [FN_SEMVER_CMP_MINOR] Reserved variable)
endif
FN_SEMVER_CMP = $(strip \
$(eval FN_SEMVER_CMP_MAJOR := $(call FN_NUMBER_CMP,$(call FN_SEMVER_MAJOR,$(1)),$(call FN_SEMVER_MAJOR,$(2))))\
$(eval FN_SEMVER_CMP_MINOR := $(call FN_NUMBER_CMP,$(call FN_SEMVER_MINOR,$(1)),$(call FN_SEMVER_MINOR,$(2))))\
$(if $(call FN_EQ,$(FN_SEMVER_CMP_MAJOR),-1),-2,$(if $(call FN_EQ,$(FN_SEMVER_CMP_MAJOR),1),2,$(FN_SEMVER_CMP_MINOR)))\
$(eval undefine FN_SEMVER_CMP_MAJOR)\
$(eval undefine FN_SEMVER_CMP_MINOR)\
)
# ------------------------------------------------------------------------------

# File system functions --------------------------------------------------------

# Lists files in a directory.
#
# Syntax: $(call FN_FIND_FILES,directory,findFlags)
ifdef FN_FIND_FILES
    $(error [FN_FIND_FILES] Reserved variable)
endif
FN_FIND_FILES = $(shell cd $(1) 2> /dev/null && find . -type f $(2) | sed 's:./::')

# Returns the relative path for going from 'fromDir' to 'toDir'.
# Syntax: $(call FN_REL_DIR,fromDir,toDir)
ifdef FN_REL_DIR
    $(error [FN_REL_DIR] Reserved variable)
endif
FN_REL_DIR = $(shell realpath -m --relative-to=$(1) $(2))

# Checks if a path is inside a directory (on success, returns the path,
# otherwise returns an empty value).
#
# Syntax $(call FN_IS_INSIDE_DIR,dir,path)
ifdef FN_IS_INSIDE_DIR
    $(error [FN_IS_INSIDE_DIR] Reserved variable)
endif
FN_IS_INSIDE_DIR = $(filter $(abspath $(1)) $(abspath $(1)/%),$(abspath $(2)))
# ------------------------------------------------------------------------------

# Makefile utils ---------------------------------------------------------------
# Checks if the origin of a variable matches with an expected value. If matching
# fails, throws an error.
#
# Syntax $(call FN_CHECK_ORIGIN,varName,expectedOrigin,errorMessage?=)
ifdef FN_CHECK_ORIGIN
    $(error [FN_CHECK_ORIGIN] Reserved variable)
endif
FN_CHECK_ORIGIN = $(if $(call FN_EQ,$(origin $(1)),$(2)),,$(error $(if $(3),$(3),[$(1)] Unexpected origin: "$(origin $(1))" (expected: "$(2)"))))

# Checks for an unexpected/invalid words. If an invalid word is found,
# throws an error.
#
# Syntax: $(call FN_CHECK_WORDS,varName,accepted_words,errorMessage?=)
ifdef FN_CHECK_WORDS
    $(error [FN_CHECK_WORDS] Reserved variable)
endif
FN_CHECK_WORDS=$(if $(or $(word 2,$($(1))),$(filter-out $(2),$($(1)))),$(error $(if $(3),$(3),[$(1)] Invalid value: $($(1)))),)

# Checks for a non-empty variable. If the value of $(varName) is empty, throws
# an error.
#
# Syntax: $(call FN_CHECK_NON_EMPTY,varName,errorMessage?=)
ifdef FN_CHECK_NON_EMPTY
    $(error [FN_CHECK_NON_EMPTY] Reserved variable)
endif
FN_CHECK_NON_EMPTY=$(if $(strip $($(1))),,$(error $(if $(2),$(2),[$(1)] Missing value)))

# Checks if whitespaces are found in an expected non-whitespace variable.
# If a whitespace is found in $(varName), throws an error.
#
# Syntax: $(call FN_CHECK_NO_WHITESPACE,varName,errorMessage?=)
ifdef FN_CHECK_NO_WHITESPACE
    $(error [FN_CHECK_NO_WHITESPACE] Reserved variable)
endif
FN_CHECK_NO_WHITESPACE=$(if $(call FN_EQ,0,$(words $($(1)))),,$(if $(call FN_EQ,1,$(words $($(1)))),,$(error $(if $(2),$(2),[$(1)] Value cannot have whitespaces: "$($(1))"))))
# ------------------------------------------------------------------------------

endif # ifndef cpb_include_functions_mk
