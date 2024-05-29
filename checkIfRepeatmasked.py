#!/usr/bin/env python

import subprocess

szTempAssembly = "temp_assembly.fa"

szCommand = f"rm -f {szTempAssembly}"
print( f"about to execute: {szCommand}")
subprocess.call( szCommand, shell = True )


with open( "fastawhole.fofn", "r" ) as fFastaWhole:
    while True:
        szLine = fFastaWhole.readline()
        if ( szLine == "" ):
            break
        szLine = szLine.rstrip()
        if ( szLine == "" ):
            continue

        if ( szLine.endswith( ".gz" ) ):
            szCommand = f"zcat {szLine} >>{szTempAssembly}"
            print( f"about to execute: {szCommand}")
            subprocess.call( szCommand, shell = True )
        else:
            szCommand = f"cat {szLine} >>{szTempAssembly}"
            print( f"about to execute: {szCommand}")
            subprocess.call( szCommand, shell = True )

szCommand = f"cat {szTempAssembly} | ./countBasesACGT >countBasesACGT.txt"
print( f"about to execute: {szCommand}")
subprocess.call( szCommand, shell = True )


with open( "countBasesACGT.txt", "r" ) as fCountBases:

    bFound = False
    for szLine in fCountBases.readlines():
        if ( "lowercase bases" in szLine ):
            bFound = True
            aWords = szLine.split()
            assert len( aWords ) >= 8, f"not enough words in line {szLine}"
            # looks like: lowercase bases all sequences: 212 212 ( 100.00 % )
            #               0         1     2    3        4    5 6   7

            fPerCent = float( aWords[7] )
            if ( fPerCent < 2.0 ):
                exit( "sequence does not appear to be repeatmasked" )
            else:
                szCommand = f"touch is_repeatmasked_flag; rm {szTempAssembly}"
                print( f"about to execute: {szCommand}")
                subprocess.call( szCommand, shell = True )
                break
            
    assert bFound, "couldn't find \"lowercase bases\" in countBasesACGT.txt"


    
            
            
