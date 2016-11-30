# -*- coding: utf-8 -*-
#-------------------------------------------------------------------------#
#   Copyright (C) 2015 by Christoph Thelen                                #
#   doc_bacardi@users.sourceforge.net                                     #
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
#   This program is distributed in the hope that it will be useful,       #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#   GNU General Public License for more details.                          #
#                                                                         #
#   You should have received a copy of the GNU General Public License     #
#   along with this program; if not, write to the                         #
#   Free Software Foundation, Inc.,                                       #
#   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
#-------------------------------------------------------------------------#


#----------------------------------------------------------------------------
#
# Set up the Muhkuh Build System.
#

SConscript('mbs/SConscript')
Import('env_default')

import os.path


#----------------------------------------------------------------------------
#
# Build the artifacts.
#

strGroup = 'org.muhkuh.tools'
strModule = 'muhkuh_base_cli'

# Split the group by dots.
aGroup = strGroup.split('.')
# Build the path for all artifacts.
strModulePath = 'targets/jonchki/repository/%s/%s/%s' % ('/'.join(aGroup), strModule, PROJECT_VERSION)


# Set the name of the LUA5.1 artifact.
strArtifact51 = 'lua5.1-muhkuh_base_cli'

tArcList51 = env_default.ArchiveList('zip')

tArcList51.AddFiles('',
                   'installer/jonchki/lua5.1/install.lua')

tArcList51.AddFiles('lua/',
                   'lua/muhkuh.lua',
                   'lua/select_plugin_cli.lua',
                   'lua/serialnr.lua',
                   'lua/tester_cli.lua',
                   'lua/utils.lua')

tArcList51.AddFiles('system/',
                   'lua/muhkuh_cli_init.lua')

tArtifact51Zip = env_default.Archive(os.path.join(strModulePath, '%s-%s.zip' % (strArtifact51, PROJECT_VERSION)), None, ARCHIVE_CONTENTS = tArcList51)
tArtifact51Xml = env_default.Version(os.path.join(strModulePath, '%s-%s.xml' % (strArtifact51, PROJECT_VERSION)), 'installer/jonchki/lua5.1/%s.xml' % strModule)
tArtifact51Pom = env_default.ArtifactVersion(os.path.join(strModulePath, '%s-%s.pom' % (strArtifact51, PROJECT_VERSION)), 'installer/jonchki/lua5.1/pom.xml')


# Set the name of the LUA5.2 artifact.
strArtifact52 = 'lua5.2-muhkuh_base_cli'

tArcList52 = env_default.ArchiveList('zip')

tArcList52.AddFiles('',
                   'installer/jonchki/lua5.2/install.lua')

tArcList52.AddFiles('lua/',
                   'lua/muhkuh.lua',
                   'lua/select_plugin_cli.lua',
                   'lua/serialnr.lua',
                   'lua/tester_cli.lua',
                   'lua/utils.lua')

tArcList52.AddFiles('system/',
                   'lua/muhkuh_cli_init.lua')

tArtifact52Zip = env_default.Archive(os.path.join(strModulePath, '%s-%s.zip' % (strArtifact52, PROJECT_VERSION)), None, ARCHIVE_CONTENTS = tArcList52)
tArtifact52Xml = env_default.Version(os.path.join(strModulePath, '%s-%s.xml' % (strArtifact52, PROJECT_VERSION)), 'installer/jonchki/lua5.2/%s.xml' % strModule)
tArtifact52Pom = env_default.ArtifactVersion(os.path.join(strModulePath, '%s-%s.pom' % (strArtifact52, PROJECT_VERSION)), 'installer/jonchki/lua5.2/pom.xml')


# Set the name of the LUA5.3 artifact.
strArtifact53 = 'lua5.3-muhkuh_base_cli'

tArcList53 = env_default.ArchiveList('zip')

tArcList53.AddFiles('',
                   'installer/jonchki/lua5.3/install.lua')

tArcList53.AddFiles('lua/',
                   'lua/muhkuh.lua',
                   'lua/select_plugin_cli.lua',
                   'lua/serialnr.lua',
                   'lua/tester_cli.lua',
                   'lua/utils.lua')

tArcList53.AddFiles('system/',
                   'lua/muhkuh_cli_init.lua')

tArtifact53Zip = env_default.Archive(os.path.join(strModulePath, '%s-%s.zip' % (strArtifact53, PROJECT_VERSION)), None, ARCHIVE_CONTENTS = tArcList53)
tArtifact53Xml = env_default.Version(os.path.join(strModulePath, '%s-%s.xml' % (strArtifact53, PROJECT_VERSION)), 'installer/jonchki/lua5.3/%s.xml' % strModule)
tArtifact53Pom = env_default.ArtifactVersion(os.path.join(strModulePath, '%s-%s.pom' % (strArtifact53, PROJECT_VERSION)), 'installer/jonchki/lua5.3/pom.xml')
