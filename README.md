mcfly
=====

A really simple rsync script to make backups based on any system with
support for hard links, works like Time Machine.

How it works
=====

McFly uses rsync to create snapshot backups that do not duplicate
unmodified files, instead these files are just hard-linked to the
already existing data in the backups directory.

It runs on any system with bash and rsync.

Example
=====

I want to backup my home directory on Debian, my user is diego and my
hostname is bellota, because I like the word.

```
diego@bellota:~$ ./mcfly.sh /home/diego/ /media/diego/backup-drive/
```
This will create the directory:
/media/diego/backup-drive/McFly/bellota-diego/

With these files:
```
2013_01_21T05_10_21.log
current -> 2013_01_21T05_10_21/
2013_01_21T05_10_21/
```

My next call to mcfly.sh would create something like this:
```
2013_01_21T05_10_21.log
2013_01_21T05_10_21/
2013_01_22T15_42_10.log
2013_01_22T15_42_10/
current -> 2013_01_22T15_42_10/
```

Both backups are fully browsable and restorable. But they are sharing
any data that has not been modified.

Extra credit
=====

I humbly suggest that you install brew, and then brew install rsync.
 * Get homebrew: http://mxcl.github.com/homebrew/
 * Add the rsync recipe: https://github.com/Homebrew/homebrew-dupes/


I'm considering porting this to Python, just because I like Python.
Please tell me about any problem, bug, or idea.

- Diego
