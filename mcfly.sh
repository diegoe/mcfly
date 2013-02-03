#!/bin/bash
# mcfly - an rsync based, snapshot backups script
#
# Author: Diego Escalante Urrelo <diegoe@gnome.org>
# URL: http://github.com/diegoe/mcfly
#
# Arguments: ./mcfly dir-to-backup destination-drive
#
# Inspired by
#   http://blog.interlinked.org/tutorials/rsync_time_machine.html
#   http://blog.interlinked.org/tutorials/rsync_addendum.yaml.html

# Uncomment for lots of debugging
# set -x

# Configurable vars
mcfly_dir_name="mcfly-osx"

# OSX Note: the system's rsync sucks. Get the one from homebrew-dupes.
rsync=/usr/local/bin/rsync

from=$1
to=$2

date=`date "+%Y-%m-%dT%H_%M_%S"`
host=`hostname -s`

# What to backup
drive_source=$from
dir_source=`basename $from`
exclude_file=$drive_source/.rsync-exclude

# Where and how to name it
path_dest=$to/$mcfly_dir_name
dir_dest=$dir_source-$date
tmp_dest=$path_dest/incomplete-$dir_dest
permanent_dest=$path_dest/$dir_dest

# This path is relative to $dir_dest
current_link=$dir_source-current
link_dest=../$current_link

# Don't touch anything if the dir exists
if [ -d $permanent_dest ]; then
    exit;
fi

# Check that there's a current symlink
if [ ! -h $path_dest/$current_link ]; then
    exit;
fi

# OSX note: some applications install files to ~/Library or similar.
# This sucks, because it forces us to pass --no-g (ignore group
# preservation) or run rsync as sudo. Both things suck.
#
# But --no-g should be more acceptable than sudo.

# OSX note: -X does not work with OSX's rsync.
# If you still insist on using it paleolithic rsync, replace -X with
# --extended-attributes.
#
# WARNING: ResourceForks in HFS+ behave stupidily with old rsync.

# OSX note: ResourceForks is something Apple invented to piss everyone.
# If you encounter files that keep being copied to your backups you can
# check if they have the com.apple.ResourceFork xattr with:
#  $ xattr file
# or
#  $ ls -l@ file
#
# If you find such an abomination, you can remove it with:
#  $ xattr -d com.apple.ResourceFork file
#
# WARNING: I have no clue if this attribute holds important information
# on certain filetypes. For me, it has not been a problem. Be careful.

# Linux note: when copying to a different FS, xattrs might not be
# preserved, and will make rsync "fail", preventing the later steps from
# happening.
#
# Remove the -X option to avoid this. This should be safe, unless you
# explicitely need xattr of some file.

# Linux note: rsync can copy symlinks that point to other filesystems,
# even if they are broken. This is a problem later when hard linking.
# The solution is to use --copy-links or --safe-links.

# Other useful options:
#  --extended-attributes \
#  --dry-run \

# A reference of the codes printed by --itemize
#   http://pagesofinterest.net/blog/2010/11/rsync-itemize-output-codes/

# A suggested list of excludes for OSX is inlined.

# IT DOES NOT WORK! OMG!
# That is because I intentionally leave the -n (dry-run) switch when
# committing to the repository. This is for everyone's safety.
#
# Just remove the line and mcfly will be execute your instructions.

$rsync \
  -rpto \
  -n \
  --modify-window=5 \
  --verbose --itemize-changes \
  --human-readable \
  --safe-links \
  --delete \
  --exclude=".Trash/" \
  --exclude="Documents/Final Cut Pro Documents/Render Files/" \
  --exclude="Documents/Final Cut Pro Documents/Waveform Cache Files/" \
  --exclude="Documents/Final Cut Pro Documents/Thumbnail Cache Files/" \
  --exclude="Documents/Final Cut Pro Documents/Audio Render Files/" \
  --exclude="Library/Application Support/" \
  --exclude="Library/Caches" \
  --exclude="Library/Preferences/Macromedia/" \
  --log-file=$tmp_dest.log \
  --link-dest=$link_dest \
  $drive_source $tmp_dest

# Move to final destination, if this fails then nothing else gets
# executed.
mv $tmp_dest $permanent_dest \
&& mv $tmp_dest.log $permanent_dest.log \
&& rm -f $path_dest/$current_link \
&& ln -s $dir_dest $path_dest/$current_link
