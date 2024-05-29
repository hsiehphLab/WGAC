#!/usr/bin/env python


# module load miniconda/4.5.12

import gzip
from mimetypes import guess_type
from functools import partial
from Bio import SeqIO

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--szInputFile", required = True )
parser.add_argument("--szOutputFile", required = True )
args = parser.parse_args()


szInput = args.szInputFile
szOutput = args.szOutputFile


encoding = guess_type(szInput)[1]  # uses file extension
_open = partial(gzip.open, mode='rt') if encoding == 'gzip' else open

with _open( szInput ) as fInput, open( szOutput, "w" ) as fOutput:
    iterInput = SeqIO.parse( fInput, "fasta")
    iterOutput = ( record for record in iterInput )

    SeqIO.write( iterOutput, fOutput, "fasta")

