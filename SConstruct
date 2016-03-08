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

aArtifactServer = ('nexus@netx01', 'muhkuh', 'muhkuh_snapshots')
strArtifactGroup = 'tools.muhkuh.org'
strArtifactId = 'muhkuh_base_cli'


tArcList0 = env_default.ArchiveList('zip')

tArcList0.AddFiles('',
	'ivy/org.muhkuh.tools.muhkuh_base_cli/install.xml')

tArcList0.AddFiles('lua/',
	'lua/muhkuh.lua',
	'lua/select_plugin_cli.lua',
	'lua/serialnr.lua',
	'lua/tester_cli.lua',
	'lua/utils.lua')

tArcList0.AddFiles('system/',
	'lua/muhkuh_cli_init.lua')


aArtifactGroupReverse = strArtifactGroup.split('.')
aArtifactGroupReverse.reverse()

strArtifactPath = 'targets/ivy/repository/%s/%s/%s' % ('/'.join(aArtifactGroupReverse),strArtifactId,PROJECT_VERSION)
tArc = env_default.Archive(os.path.join(strArtifactPath, '%s-%s.zip' % (strArtifactId,PROJECT_VERSION)), None, ARCHIVE_CONTENTS=tArcList0)
tIvy = env_default.Version(os.path.join(strArtifactPath, 'ivy-%s.xml' % PROJECT_VERSION), 'ivy/%s.%s/ivy.xml' % ('.'.join(aArtifactGroupReverse),strArtifactId))

env_default.AddArtifact(tArc, aArtifactServer, strArtifactGroup, strArtifactId, PROJECT_VERSION, 'zip')
env_default.AddArtifact(tIvy, aArtifactServer, strArtifactGroup, strArtifactId, PROJECT_VERSION, 'ivy')

tArtifacts = env_default.Artifact('targets/artifacts.xml', None)

# Copy the artifacts to a fixed filename to allow a deploy to github.
Command('targets/ivy/%s.zip' % strArtifactId,  tArc,  Copy("$TARGET", "$SOURCE"))
Command('targets/ivy/ivy.xml', tIvy,  Copy("$TARGET", "$SOURCE"))

