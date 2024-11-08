#!/usr/bin/env python

import os
import shutil
import subprocess

nFilesToKeepInDirectories = 5



def bash_command( szCommand ):
    print( f"about to execute: {szCommand}" )
    subprocess.call( szCommand, shell = True )
    



bash_command( f"rm -rf uncompressed_genome" )
bash_command( f"rm -rf fastawhole_split" )


aDirectoriesToMainlyEmpty = ["blastout", "logs", "fasta", "fugu_trf", "fugu", "fugu2", "mask_out", "selfblast", "trf", "global_align_flags", "data/step_8_mpi/defugu", "data/step_8_mpi/trim", "both_tmp","fastawholesplit" ]


for szDirectory in aDirectoriesToMainlyEmpty:
    print( "now working on " + szDirectory )

    nFilesSoFar = 0
    nFilesRemoved = 0
    nDirsRemoved = 0
    with os.scandir( szDirectory) as it:
        for entry in it:
            #if not entry.name.startswith('.') and entry.is_file():
            if not entry.name.startswith('.'):
                nFilesSoFar += 1
                if ( nFilesSoFar > nFilesToKeepInDirectories ):
                    #print( "about to delete: " + entry.name )
                    if entry.is_file():
                        os.remove( szDirectory + "/" + entry.name )
                        nFilesRemoved += 1
                    elif entry.is_symlink():
                        os.remove( szDirectory + "/" + entry.name )
                        nFilesRemoved += 1
                    elif entry.is_dir():
                        shutil.rmtree( szDirectory + "/" + entry.name )
                        nDirsRemoved += 1
                    else:
                        exit( szDirectory + "/" + entry.name + " is not a file or directory" )
                else:
                    print( "will keep: " + entry.name )

    print( f"nFilesRemoved = {nFilesRemoved} nDirsRemoved = {nDirsRemoved}" )

    #with os.scandir( szDirectory) as it:


# multiple level directories
aMultipleLevelDirectoriesToMainlyEmpty = [ "data/align_both", "data/align_both_data" ]
for szDirectory in aMultipleLevelDirectoriesToMainlyEmpty:
    print( "now working on " + szDirectory )

    nFilesSoFar = 0

    with os.scandir( szDirectory) as it:
        for entry in it:
            if not entry.name.startswith('.') and entry.is_dir():

                szSubDir = szDirectory + "/" + entry.name
                if ( nFilesSoFar > nFilesToKeepInDirectories ):
                    print( "about to delete subdirectory " + szSubDir )
                    shutil.rmtree( szSubDir )
                else:
                    with os.scandir( szSubDir ) as subdirEntry:
                        for ssubdirEntry in subdirEntry:

                            if not ssubdirEntry.name.startswith('.') and ssubdirEntry.is_file():
                                nFilesSoFar += 1
                                if ( nFilesSoFar > nFilesToKeepInDirectories ):
                                    #print( "about to delete " + szSubDir + "/" + ssubdirEntry.name )
                                    os.remove( szSubDir + "/" + ssubdirEntry.name )
                                else:
                                    print( "will keep: " + szSubDir + "/" + ssubdirEntry.name )


# delete logs.  This saves each subdirectory of logs and saves 5 logs
# from each subdirectory.
szDirectory = "logs"
with os.scandir( szDirectory ) as it:
    for entry in it:
        if not entry.name.startswith('.') and entry.is_dir():

            nFilesSoFar = 0

            szSubDir = szDirectory + "/" + entry.name
            with os.scandir( szSubDir ) as subdirEntry:
                for ssubdirEntry in subdirEntry:

                    if not ssubdirEntry.name.startswith('.') and ssubdirEntry.is_file():
                        nFilesSoFar += 1
                        if ( nFilesSoFar > nFilesToKeepInDirectories ):
                            #print( "about to delete " + szSubDir + "/" + ssubdirEntry.name )
                            os.remove( szSubDir + "/" + ssubdirEntry.name )
                        else:
                            print( "will keep: " + szSubDir + "/" + ssubdirEntry.name )


szDirectory = ".snakemake/metadata"
if ( os.path.isdir( szDirectory )):
     print( "will delete: " + szDirectory )
     shutil.rmtree( szDirectory )
else:
    print( szDirectory + " is already deleted" )

