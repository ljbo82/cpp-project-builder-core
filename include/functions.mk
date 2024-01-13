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

# General purpose functions

ifndef include_functions_mk
include_functions_mk := 1

# Text functions ---------------------------------------------------------------

# Returns a token on delimited string.
#
# Syntax: $(call FN_TOKEN,baseString,delimiter,index)
ifdef FN_TOKEN
    $(error [FN_TOKEN] Reserved variable)
endif
FN_TOKEN = $(word $(3),$(subst $(2), ,$(1)))

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
# ------------------------------------------------------------------------------

# Semantic version functions ---------------------------------------------------

# Checks if a semantic version string is valid (returns the string if valid, otherwise returns an empty value).
# Syntax: $(call FN_SEMVER_CHECK,semanticVersion)
ifdef FN_SEMVER_CHECK
    $(error [FN_SEMVER_CHECK] Reserved variable)
endif
FN_SEMVER_CHECK = $(if $(filter-out 1 2 3,$(words $(subst ., ,$(1)))),,$(1))

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
# Syntax $(call FN_CHECK_ORIGIN,varName,expectedOrigin)
ifdef FN_CHECK_ORIGIN
    $(error [FN_CHECK_ORIGIN] Reserved variable)
endif
FN_CHECK_ORIGIN = $(if $(call FN_EQ,$(origin $(1)),$(2)),,$(error [$(1)] Unexpected origin: "$(origin $(1))" (expected: "$(2)")))

# Checks for an unexpected/invalid words.
#
# Syntax: $(call FN_CHECK_WORDS,varName,accepted_words[,errorMessage])
ifdef FN_CHECK_WORDS
    $(error [FN_CHECK_WORDS] Reserved variable)
endif
FN_CHECK_WORDS=$(if $(or $(word 2,$($(1))),$(filter-out $(2),$($(1)))),$(error [$(1)] $(if $(3),$(3),Invalid value: $($(1)))),)

# Checks for a non-empty variable.
#
# Syntax: $(call FN_CHECK_NON_EMPTY,varName[,errorMessage])
ifdef FN_CHECK_NON_EMPTY
    $(error [FN_CHECK_NON_EMPTY] Reserved variable)
endif
FN_CHECK_NON_EMPTY=$(if $(strip $($(1))),,$(error [$(1)] $(if $(2),$(2),Missing value)))

# Checks for a no whitespaces in a variable's value.
#
# Syntax: $(call FN_CHECK_NO_WHITESPACE,varName[,errorMessage])
ifdef FN_CHECK_NO_WHITESPACE
    $(error [FN_CHECK_NO_WHITESPACE] Reserved variable)
endif
FN_CHECK_NO_WHITESPACE=$(if $(call FN_EQ,0,$(words $($(1)))),,$(if $(call FN_EQ,1,$(words $($(1)))),,$(error [$(1)] $(if $(2),$(2),Value cannot have whitespaces: "$($(1))"))))
# ------------------------------------------------------------------------------

endif # ifndef include_functions_mk
