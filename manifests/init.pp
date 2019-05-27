# Class: storm
# ===========================
#
# StoRM official puppet module
#
# Parameters
# ----------
#
# * `storm_user_name`
# Specify StoRM Unix user as a string.
# * `storm_storage_root_directory`
# Specify Storage Areas root directory path as a string.
#
# Examples
# --------
#
# @example
#    class { 'storm':
#      storm_user_name => 'storm',
#      storm_storage_root_directory => '/storage',
#    }
#
# Authors
# -------
#
# Enrico Vianello <enrico.vianello@cnaf.infn.it>
#
# Copyright
# ---------
#
# Copyright (c) Istituto Nazionale di Fisica Nucleare (INFN). 2006-2010.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
#
class storm {

  contain storm::install
  contain storm::config

  Class['::storm::install']
  -> Class['::storm::config']
}