#!/bin/bash
# McFly - an rsync based, snapshot backups script
#
# Author: Diego Escalante Urrelo <diegoe@gnome.org>
# URL: http://github.com/diegoe/mcfly
#
# Arguments: ./mcfly.sh dir-to-backup destination-drive
#
# Inspired by
#   http://blog.interlinked.org/tutorials/rsync_time_machine.html
#   http://blog.interlinked.org/tutorials/rsync_addendum.yaml.html

# Uncomment for lots of debugging
#set -x

# Configurable vars
mcfly_dir_name="McFly"
exclude_file=$drive_source/.rsync-exclude

# OSX Note: the system's rsync sucks. Get the one from homebrew-dupes.
rsync=/usr/local/bin/rsync

from=$1
to=$2

date=`date "+%Y-%m-%dT%H_%M_%S"`
host=`hostname -s`

# What to backup
drive_source=$from
dir_source=`basename $from`

# Where and how to name it
path_dest=$to/$mcfly_dir_name/$host-$dir_source
dir_dest=$date
tmp_dest=$path_dest/incomplete-$dir_dest
permanent_dest=$path_dest/$dir_dest

# This path is relative to $dir_dest
link_dest=../current


# Don't touch anything is the dir exists
if [ -d $permanent_dest ]; then
    exit;
fi

mkdir -p $path_dest

# Check that there's a current symlink
if [ ! -h $path_dest/current ]; then
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

# Other useful options:
#  --exclude-from=$exclude_file \
#  --extended-attributes \
#  --dry-run \

# A reference of the codes printed by --itemize
#   http://pagesofinterest.net/blog/2010/11/rsync-itemize-output-codes/

$rsync \
  --archive \
  --no-g \
  -X \
  --modify-window=5 \
  --verbose --itemize-changes \
  --human-readable \
  --delete-after \
  --delete-excluded \
  --log-file=$tmp_dest.log \
  --link-dest=$link_dest \
  $drive_source $tmp_dest \
&& mv $tmp_dest $permanent_dest \
&& mv $tmp_dest.log $permanent_dest.log \
&& rm -f $path_dest/current \
&& ln -s $path_dest/$dir_dest $path_dest/current
