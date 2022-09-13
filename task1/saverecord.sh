#!/usr/bin/env bash

# dig +short will return only the value of a record, which
# is then redirected to the desired file. tee would also work
# and let you display the output and execute the dig regardless
# of the writability of the output file.
dig +short challenging.rocketmiles.net TXT > ~ec2-user/dns.txt
