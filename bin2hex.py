#! /usr/bin/env python

# This converts a binary file into a text file written in hexadecimal with each
# byte on a single line.
# This is used to initialize memory.
#
# Usage: ./bin2hex.py <source> <dest>

import sys

infilename  = sys.argv[1]
outfilename = sys.argv[2]

infile  = open(infilename, 'rb')
outfile = open(outfilename, 'w')

for b in infile.read():
    t = format(ord(b), '02x')
    outfile.write(t+'\n')

infile.close()
outfile.close()

