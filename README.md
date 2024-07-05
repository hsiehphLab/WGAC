# WGAC
see wiki.pdf

The fields (I think) are the following:
1 chromosome2 start pos
3 end pos
6 orientation _ (underscore) or - is reverse, + is forward
duplicated region:
7 chromosome
8 start pos
9 end pos
11 this is some ID for seg dups. if 2 different lines were the same except have 1,2,3 and 7,8,9 reversed, then
they had the same field #11.
(Please add to this table as you discover the meaning of columns.)
(going through the perl script I believe I have found the meaning for the last 13 columns but I am not positive, MV 08/23/2017)
17 The file containing the NW (global) base-level alignment of the 2 seg dups for the line.
18 length of alignment (includes gaps and Ns)
19 indel_N (not sure what the _N and _S are, I think they are indels that are Ns vs real bases)
20 indel_S (but even if I am right I do not know if this is the number of indels or the number of bases that are indels )
21 the number of aligned bases not including Ns and gaps. (i.e. matches + mismatches)
22 matched bases
23 mismatched bases
24 transitions
25 transversions
26 similarity (not including indels, perfect agreement is 1.0)
27 similarity (including indels)
28 K_jc (Jaccard score)
29 k_kimura (Kimura score)
