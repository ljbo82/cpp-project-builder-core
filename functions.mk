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

fn_version_valid = $(shell sh -c "echo $(1) | grep -oP '^[0-9]+\.[0-9]+\.[0-9]+.*$$' > /dev/null && echo 1 || echo 0")
fn_version_major = $(shell sh -c "echo $(1) | cut -d'.' -f1")
fn_version_minor = $(shell sh -c "echo $(1) | cut -d'.' -f2")
fn_version_patch = $(shell sh -c "echo $(1) | cut -d'.' -f3-")

fn_host_valid = $(shell sh -c "echo $(1) | grep -oP '^[a-zA-Z0-9]+\-[a-zA-Z0-9]+.*$$' > /dev/null && echo 1 || echo 0")
fn_host_os    = $(shell sh -c "echo $(1) | cut -d'-' -f1")
fn_host_arch  = $(shell sh -c "echo $(1) | cut -d'-' -f2-")

fn_subdir = $(shell sh -c "echo $(abspath $(1)) | grep -oP '^$(abspath $(2))[/]*' > /dev/null && echo $(1)")

fn_eq = $(shell sh -c "[ '$(1)' = '$(2)' ] && echo '$(1)'")

# $(call fn_cut,base_string,delimiter,index)
fn_cut = $(shell sh -c "echo $(1) | cut -d'$(2)' -f$(3)")

# $(call fn_word,base_string,index)
fn_word = $(call fn_cut,$(1), ,$(2))

endif # _include_functions_mk
