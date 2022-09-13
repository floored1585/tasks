#!/usr/bin/env bash

# The find command lets you specify (and negate) a pattern to match, as well
# as allow filtering based on accessed/modified/created times. Most systems
# don't keep track of last access time by default, though. find also contains
# a -delete flag useful for this task, which will delete the matching files.
find ~ec2-user/do-not-delete/ -atime +30 ! -name "*do-not-delete*" -delete

# Alternative using -exec
#find ~ec2-user/do-not-delete/ -atime +30 ! -name "*do-not-delete*" -exec rm '{}' \;

# Alternate using xargs
#find ~ec2-user/do-not-delete/ -atime +30 ! -name "*do-not-delete*" | xargs rm

