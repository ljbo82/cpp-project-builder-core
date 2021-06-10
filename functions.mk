# This file is part of gcc-project-builder.
# Copyright (C) 2021 Leandro José Britto de Oliveira
#
# gcc-project-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# gcc-project-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gcc-project-builder.  If not, see <https://www.gnu.org/licenses/>

ifndef _include_functions_mk
_include_functions_mk := 1

# Returns 1 if version is a valid semantic version. Otherwise, returns 0
# Syntax: $(call fn_version_valid,semanticVersion)
fn_version_valid = $(shell sh -c "echo $(1) | grep -oP '^[0-9]+\.[0-9]+\.[0-9]+.*$$' > /dev/null && echo 1 || echo 0")

# Returns the major component for given version
# Syntax: $(call fn_version_major,semanticVersion)
fn_version_major = $(shell sh -c "echo $(1) | cut -d'.' -f1")

# Returns the minor component for given version
# Syntax: $(call fn_version_minor,semanticVersion)
fn_version_minor = $(shell sh -c "echo $(1) | cut -d'.' -f2")

# Returns the patch component for given version
# Syntax: $(call fn_version_patch,semanticVersion)
fn_version_patch = $(shell sh -c "echo $(1) | cut -d'.' -f3-")

# Returns 1 if host is a valid host string. Otherwise, returns 0
# Syntax: $(call fn_host_valid,host)
fn_host_valid = $(shell sh -c "echo $(1) | grep -oP '^[a-zA-Z0-9]+\-[a-zA-Z0-9]+.*$$' > /dev/null && echo 1 || echo 0")

# Returns the OS component for given host
# Syntax: $(call fn_host_os,host)
fn_host_os    = $(shell sh -c "echo $(1) | cut -d'-' -f1")

# Returns the ARCH component for given host
# Syntax: $(call fn_host_arch,host)
fn_host_arch  = $(shell sh -c "echo $(1) | cut -d'-' -f2-")

# If childDir is a subdirectory inside parentDir, returns childDir. Otherwise, returns an empty value
# Syntax: $(call fn_subdir,childDir,parentDir)
fn_subdir = $(shell sh -c "echo $(abspath $(1)) | grep -oP '^$(abspath $(2))[/]*' > /dev/null && echo $(1)")

# If str1 equals str2, returns str1. Otherwise, returns an empty value
# Syntax: $(call fn_str_eq,srt1,str2)
fn_eq = $(shell sh -c "[ '$(1)' = '$(2)' ] && echo '$(1)'")

# Cuts a string based on given delimiter
# Syntax: $(call fn_cut,base_string,delimiter,index)
fn_cut = $(shell sh -c "echo $(1) | cut -d'$(2)' -f$(3)")

# Returns the n-th word in a string
# Syntax: $(call fn_word,base_string,index)
fn_word = $(call fn_cut,$(1), ,$(2))

endif # _include_functions_mk
