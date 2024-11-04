#!/usr/bin/env python

import argparse
import subprocess
import os
import re


parser = argparse.ArgumentParser()
parser.add_argument("--szfastawholefofn", required = True )
parser.add_argument("--szfastawhole_uncompressedfofn", required = True )
args = parser.parse_args()

def bash_command( szCommand ):
    print( f"about to execute: {szCommand}" )
    subprocess.call( szCommand, shell = True )
    

szUncompressedGenome = "uncompressed_genome"
szCompressedGenome   =   "compressed_genome"
    
bash_command( f"mkdir -p {szUncompressedGenome}" )
bash_command( f"mkdir -p {szCompressedGenome}" )

with open( args.szfastawholefofn, "r" ) as fFastaWhole, open( args.szfastawhole_uncompressedfofn, "w" ) as fFastaWholeUncompressed:
    while True:
        szLine = fFastaWhole.readline()
        if ( szLine == "" ):
            break
        szLine = szLine.rstrip()
        if ( szLine == "" ):
            # skip blank lines
            continue
        if ( szLine.startswith( "#" ) ):
            continue

        szBase = os.path.basename( szLine )
        if ( szBase.endswith( ".gz" ) ):
            szBase = re.sub( r".gz", "", szBase )
            bCompressed = True
        else:
            bCompressed = False


        if ( bCompressed ):
            bash_command( f"cp {szLine} {szCompressedGenome}" )
            bash_command( f"gunzip -c {szLine} >{szUncompressedGenome}/{szBase}" )
        else:
            bash_command( f"cp {szLine} {szUncompressedGenome}" )
            bash_command( f"gzip -c {szLine} >{szCompressedGenome}/{szBase}.gz" )


        szUncompressedCopy = f"{szUncompressedGenome}/{szBase}"
        fFastaWholeUncompressed.write( f"{szUncompressedCopy}\n" )



