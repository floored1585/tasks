#!/usr/bin/env bash

find ~ec2-user/do-not-delete/ -atime +30 ! -name "*do-not-delete*" -delete

# Alternative using -exec
#find ~ec2-user/do-not-delete/ -atime +30 ! -name "*do-not-delete*" -exec rm '{}' \;

# Alternate using xargs
#find ~ec2-user/do-not-delete/ -atime +30 ! -name "*do-not-delete*" | xargs rm

