# Copyright (c) 2022 Leandro José Britto de Oliveira
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

ifndef __functions_mk__
__functions_mk__ := 1

# Text functions ---------------------------------------------------------------

# Returns a token on delimited string.
# Syntax: $(call FN_TOKEN,baseString,delimiter,index)
ifdef FN_TOKEN
    $(error [FN_TOKEN] Reserved variable)
endif
FN_TOKEN = $(word $(3),$(subst $(2), ,$(1)))

# Removes duplicate words without sorting.
# Syntax: $(call FN_UNIQUE,list_of_words)
ifdef FN_UNIQUE
    $(error [FN_UNIQUE] Reserved variable)
endif
FN_UNIQUE = $(strip $(if $(1),$(firstword $(1)) $(call FN_UNIQUE,$(filter-out $(firstword $(1)),$(1)))))

# If str1 equals str2, returns str1. Otherwise, returns an empty value.
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
# Syntax: $(call FN_SEMVER_MAJOR,semanticVersion)
ifdef FN_SEMVER_MAJOR
    $(error [FN_SEMVER_MAJOR] Reserved variable)
endif
FN_SEMVER_MAJOR = $(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,1)

# Returns the minor component for given version.
# Syntax: $(call FN_SEMVER_MINOR,semanticVersion)
ifdef FN_SEMVER_MINOR
    $(error [FN_SEMVER_MINOR] Reserved variable)
endif
FN_SEMVER_MINOR = $(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,2)

# Returns the patch component for given version.
# Syntax: $(call FN_SEMVER_PATCH,semanticVersion)
ifdef FN_SEMVER_PATCH
    $(error [FN_SEMVER_PATCH] Reserved variable)
endif
FN_SEMVER_PATCH = $(call FN_TOKEN,$(call FN_SEMVER_CHECK,$(1)),.,3)
# ------------------------------------------------------------------------------

# File system functions --------------------------------------------------------

# Lists files in a directory.
# Syntax: $(call FN_FIND_FILES,directory,findFlags)
ifdef FN_FIND_FILES
    $(error [FN_FIND_FILES] Reserved variable)
endif
FN_FIND_FILES = $(shell cd $(1); find . -type f $(2) | sed 's:./::')
# ------------------------------------------------------------------------------

endif # ifndef __functions_mk__
