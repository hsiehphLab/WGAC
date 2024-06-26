#!/usr/bin/env perl

###################################MODIFICATIONS######
#10.02.05 print 'NA' for k_jc, k_kimura, k_tn if log(0), divide by zero, sqrt(-1), etc. (Tin Louie & Saba Sajjadian)
#09.11.20 print 0 or 'NA' for columns 11 and up, if $base_spaces is zero or undefined (Tin Louie)
#02.12.02 converted
#02.08.14 converted to new format for distribution
#00.08.06 modified to avoid division and log with zero

$align=$ARGV[0];

# DG modified June 10, 2024
$szOutput=$ARGV[1];

$begin="";
$end="";
# end modification



use vars qw($program $pversion $pdescription $pusage $pgenerate);
$program = $0;
$program =~ s/^.*\///;
### program stats ###
$pversion='2.011011';
$pdescription = "$program (ver:$pversion) calculates a multitude of summary statistics from a pairwise global alignment generated by align";
$pgenerate= 'total: labmates: genetics: public:';
$pusage="$program [alignment file] [begin position] [end position]";
### program stats end ###
# total: labmates: genetics: public:
# n=null output d=description line from file u=usage line from file h=html formated pod documentation c=show code

if ($ARGV[0] eq '-h' || $ARGV[0] eq '-help') {
	system "perldoc $0";
	exit;
}

$output=$align.".table";

$true = 1; $false =0;

if (!defined $ARGV[0]) {
print "USAGE
$pusage
DESCRIPTION
$pdescription
ARGUMENTS
*begin and end are in terms of position in first sequence
  (default is entire alignment)
*alignment file may be in align format from Pearson's fasta2 package
   or http://genome.cs.mtu.edu/align/align.html output
   or two fasta records in a fasta file with dashes (-) for gaps
*Make sure the alignment file is saved as a unix text
OUTPUT FILES ARE:
*.mismatch   contains all indel positions
*.indel      contains all indel positions
align_scorer.summary  table with each alignment as one row
  (each run appends a new row to table)
";
exit;
}


open (IN,"$align") || die "INPUT ERROR: no alignment file!\n";
print "ALIGNMENT FILE: $align\n";
$line =<IN> until $line=~/(Global)/ || $line=~/(terminal) gaps/ || $line =~ /^(>)/ || eof (IN);
if ($1 eq "Global") {
	###load pearson's align###
	$line=<IN>; $line=<IN>; $line=<IN>;
	while (!eof(IN) ) {
		chomp $line;
		$line=uc($line);
		$line=~/ ([MBDHVRYKSWACTGN-]+)$/;
		$s1.=$1;
		$line=<IN>; $line=<IN>;
		$line=~/ ([MBDHVRYKSWACTGN-]+)$/;
		$s2.=$1;
		$line=<IN>; $line=<IN>; $line=<IN>;	 $line=<IN>;
	}
} elsif ($1 eq "terminal") {
	####http://genome.cs.mtu.edu/align/align.html output
	$line=<IN>; $line=<IN>; $line=<IN>;
	while (!eof(IN)) {
		$line= substr($line,6,50);
		$line=uc($line);
		$s1.=$line;
		$line=<IN>;	$line=<IN>;
		$line= substr($line,6,50);
		$s2.=$line;
		$line=<IN>; $line=<IN>; $line=<IN>;
	}
	while ($s1=~/ $/ && $s2=~/ $/) {
		chop $s1;
		chop $s2;
	}


} elsif ($1 eq '>') {
	###load fasta format###
	print "LOADING FASTA FILE FORMAT\n";
	print "$line";
	$line=<IN>;
	until ( $line=~/^>/ ) {
		$line =~ s/\r\n/\n/;
		chomp $line;
		$line =~s/\s+//mg;
		$s1.=uc($line);
		$line=<IN>;
	}
	print "$line";
	while (<IN>) {
		s/\r\n/\n/;
		s/\s+//mg;
		chomp;
		$s2.=uc($_);
	}
#	print "after s2\n";

################################
###### extra code for masking simple well-defined 
###### sequence patterns with reg expressions
###############################

#$s1=~ s/(C-*G)/next$1.last/mg;
#$s2=~ s/(C-*G)/next$1.last/mg;
#print $s1;
#$s1=~ s/next./N/mg;
#$s2=~ s/next./N/mg;
#$s1=~ s/.\.last/N/mg;
#$s2=~ s/.\.last/N/mg;

	die "INPUT FILE ERROR: Length of sequence 1 (",length($s1),") is different then sequence 2 (",length($s2),")!\n" if length($s1) != length($s2);
} else {
	###test data to check statistics###
	#$s1='GTCTGTTCCAAGGGCCTTTGCGTCAGG-TGGGCTC-AGGGTT---------------CCAGGGTGGCTGG';
                           # # #                 #                    # ## #           # #                   ##                     #   
	#$s2='GTCTGTTCCAAGGGCCTTCGAGCCAGTCTGGGCCCCAGGGCTGCCCCACTCGGGGTTCCAGAGCAGTTGG';
	#$s1.='ACCCCAGGCCCCAGCTCTGCAGCAGGGAGGACGTGGCTGGGCTCGTGAAGCATGTGGGGGTGAGCCCAGGGGCCCCAAGGCAGGGCACCTGGCCTTCAGCCTGCCTCAGCCCTGCCTGTCTCCCAG';
                                                           #                   #   #                       #          
	#$s2.='ACCCCAGGTCTCAGC---------GGGAGGGTGTGGCTGGGCTC-TGAAGCATTT--GGGTGAGCCCAGGGGCTC-AGGGCAGGGCACCTG-CCTTCAGC-GGCCTCAGCC-TGCCTGTCTCCCAG';
	#$s1='ATGCATGCATGCATGCATGCATGC';
	#$s2='ATGCATGCATGCATGCATGCATGC';
	#print "$s1\n";
	#print "$s2\n";
	die ("\nINPUT FILE ERROR: Unknown alignment format (align output or fasta is your best bet)!\n");
}
$s1=~ tr/MBDHVRYKSW/NNNNNNNNNN/;
$s2=~ tr/MBDHVRYKSW/NNNNNNNNNN/;



close (IN);
open (MISMATCH, ">$align.mismatch");
print MISMATCH "BS pos\talign pos\tseq1 post\tseq2 pos\tbase1\tbase2\n";
open (INDEL, ">$align.indel");
print INDEL "a begin\ta end\tdel seq\tlength\ts1 begin\ts1 end\ts2 begin\ts2 end\n";

$begin=1 if $begin eq "";
$end=length($s1)if $end eq "";

$p=0;  $indel_number=0; $indel_spaces=0; $base_spaces=0;
while ($p<length($s1) ) {
	$b1=substr($s1,$p,1);
	$b2=substr($s2,$p,1);
	$l1++ if $b1 ne "-";
	$l2++ if $b2 ne "-";
	####SCOREING IFS ###########
	if ($l1 >= $begin && $l1 <= $end) {
		if ($b1 eq "-" || $b2 eq "-") {
			$indel_spaces++;
			#print "$b1:$b2";
			if ($b1 eq "-") {
				$del_strand=1;
				$next_base=substr($s1,$p+1,1);
			} else {
				$del_strand=2;
				$next_base=substr($s2,$p+1,1);
			}
			#print "  $del_strand  $next_base   ";
			if ($indel==$false) {
				#print "F \n";
				$indel=$true;
				$indel_start=$p;
				$indel_start1=$l1;
				$indel_start2=$l2;
				$indel_number++;
			}
			if ($indel==$true && $next_base ne "-") {
				#print "END\n";
				$indel=$false;
				$indel_stop=$p;
				$indel_stop1=$l1;
				$indel_stop1++ if $del_strand==1;
				$indel_stop2=$l2;
				$indel_stop2++ if $del_strand==2;
				print INDEL "$indel_start\t$indel_stop\t$del_strand\t";
				print INDEL $indel_stop-$indel_start+1;
				print INDEL "\t$indel_start1\t$indel_stop1\t$indel_start2\t$indel_stop2\n";
			}
		} else {
			#print "$b1 $b2";
			$m{$b1}{$b2}++;
			#print " $p: $b1 $b2\n" if $b1 eq "N" || $b2 eq "N";
			if ($b1 ne "N" && $b2 ne "N") {
				$base_spaces++; 
				print MISMATCH "$base_spaces\t$p\t$l1\t$l2\t$b1\t$b2\n" if $b1 ne $b2; 
			}
		}
	}
	$p++;
}
close (INDEL);
close (MISMATCH);

########### SCORE OUTPUT

if (-e "$szOutput") {
    print "debug opening $szOutput for append $align\n";
	open (SUM, ">>$szOutput" );
} else {
    print "debug opening $szOutput for write $align\n";
	open (SUM, ">$szOutput");
	print SUM "FILE\tBEGIN\tEND\tindel_N\tindel_S\tbase_S\tbase_Match\tbase_Mis\ttransversions\ttransitions\t";
	print SUM "per_sim\tSE_sim\tper_sim_indel\tSE_sim_indel\t";
	
	print SUM "K_jc\tSE_jc\tk_kimura\tSE_kimura\tK_tn\tSE_tn\td_lake\t";
	
	foreach $b1 ('A','T','C','G','N') {
		foreach $b2 ('A','T','C','G','N') {
			print SUM "$b1$b2\t";
		}
	}
	print SUM "\n";
}

print SUM "$align\t$begin\t$end\t";

print "INDEL NUMBER:   $indel_number\n";
print SUM "$indel_number\t";
print "INDEL ALIGNMENT SPACES:  $indel_spaces\n";
print SUM "$indel_spaces\t";
print "BASE ALIGNMENT SPACES:   $base_spaces    (positions with an N not included)\n";
print SUM "$base_spaces\t";
$samebases= $m{A}{A}+$m{C}{C}+$m{G}{G}+$m{T}{T};
print "  BASE MATCHES:      $samebases\n";
print SUM "$samebases\t";
$transversions=$m{A}{T}+$m{T}{A}+$m{A}{C}+$m{C}{A}+$m{G}{C}+$m{C}{G}
			+$m{G}{T}+$m{T}{G};
$transitions=$m{C}{T}+$m{T}{C}+$m{A}{G}+$m{G}{A};
$base_mismatches=$transversions+$transitions;
print "  BASE MISMATCHES:   ", $base_mismatches, "\n";
print SUM "$base_mismatches\t";
print "     TRANSVERSIONS:  $transversions\n";
print SUM "$transversions\t";
print "     TRANSITIONS:    $transitions\n";
print SUM "$transitions\t";

#09.11.20 print 0 or 'NA' for columns 11 and up, if $base_spaces is zero or undefined (Tin Louie)
unless ($base_spaces) {
	for (11..14) { print SUM "0\t"; }
	for (15..21) { print SUM "NA\t"; }
	for (22..46) { print SUM "0\t"; }
	print SUM "\n";
	exit;
}

$percent_sim=$samebases/$base_spaces;
print "% SIMILAR BASE MATCHES:    ",$percent_sim, "        [$samebases/$base_spaces]\n";
print SUM "$percent_sim\t";
$SE_percent_sim=(($samebases/$base_spaces)*(1-$samebases/$base_spaces)/$base_spaces)**0.5;
print "                            SE:  ",$SE_percent_sim , "   [binomial]\n";
print SUM "$SE_percent_sim\t";
$percent_sim_windel=$samebases/($base_spaces + $indel_number);
print "% SIMILAR WITH INDEL:      ",$percent_sim_windel, "     [$samebases/($base_spaces + $indel_number)]\n";
print SUM "$percent_sim_windel\t";
$SE_percent_sim_windel=($percent_sim_windel*(1-$percent_sim_windel)/($base_spaces + $indel_number))**0.5;
print "                            SE:  ",$SE_percent_sim_windel , "   [binomial]\n";
print SUM "$SE_percent_sim_windel\t";


#10.02.05 print 'NA' for k_jc, k_kimura, k_tn if log(0), divide by zero, sqrt(-1), etc. (Tin Louie & Saba Sajjadian)
my $k_jukes_cantor;
my $SE_jukes_cantor;
eval { 
	$p=$base_mismatches/$base_spaces;
	$k_jukes_cantor = -0.75*log(1-4/3*$p);
	$SE_jukes_cantor= ((1-$p)*$p/($base_spaces*(1-4*$p/3)**2))**0.5;
};
if ($@) {
	$k_jukes_cantor = 'NA';
	$SE_jukes_cantor = 'NA';
}
print "Jukes and Cantor's    K = $k_jukes_cantor    SE = $SE_jukes_cantor\n";
print SUM "$k_jukes_cantor\t$SE_jukes_cantor\t";

#10.02.05 print 'NA' for k_jc, k_kimura, k_tn if log(0), divide by zero, sqrt(-1), etc. (Tin Louie & Saba Sajjadian)
my $k_kimura;
my $SE_kimura;
eval {
	$p=$transitions/$base_spaces;
	$q=$transversions/$base_spaces;
	$a=1/(1-2*$p-$q);
	$b=1/(1-2*$q);
	$k_kimura= 0.5 * (log $a) + 0.25*( log $b);
	$SE_kimura= ( ($a**2*$p+ (($a+$b)/2)**2*$q - ($a*$p + ($a+$b)/2*$q )**2)/$base_spaces )**0.5;
};
if ($@) {
	$k_kimura = 'NA';
	$SE_kimura = 'NA';
}
print "Kimura's              K = $k_kimura    SE = $SE_kimura\n";
print SUM "$k_kimura\t$SE_kimura\t";



$s1_a=0;
foreach $b ('A','T','C','G') {$s1_a+=$m{A}{$b}; }
$s1_t=0;
foreach $b ('A','T','C','G') {$s1_t+=$m{T}{$b}; }
$s1_c=0;
foreach $b ('A','T','C','G') {$s1_c+=$m{C}{$b}; }
$s1_g=0;
foreach $b ('A','T','C','G') {$s1_g+=$m{G}{$b}; }
$s2_a=0;
foreach $b ('A','T','C','G') {$s2_a+=$m{$b}{A}; }
$s2_t=0;
foreach $b ('A','T','C','G') {$s2_t+=$m{$b}{T}; }
$s2_c=0;
foreach $b ('A','T','C','G') {$s2_c+=$m{$b}{C}; }
$s2_g=0;
foreach $b ('A','T','C','G') {$s2_g+=$m{$b}{G}; }
@q=();
$q[1]=($s1_a + $s2_a ) / (2*$base_spaces);
$q[2]=($s1_g + $s2_g ) / (2*$base_spaces);
$q[3]=($s1_t + $s2_t ) / (2*$base_spaces);
$q[4]=($s1_c + $s2_c ) / (2*$base_spaces);

#print "$s1_a\t$s1_t\t$s1_c\t$s1_g\n";
#print "$s2_a\t$s2_t\t$s2_c\t$s2_g\n";
#print "$q[1]\t$q[2]\t$q[3]\t$q[4]\n";
$b1= 1 -$q[1]**2 -$q[2]**2 -$q[3]**2 -$q[4]**2;
#print "B1: $b1\n";
@bases=('A','G','T','C');
$h=0;
ILOOP:for ($i=1; $i<=3;$i++) {
	for ($j=$i+1; $j<=4; $j++) {
		if ($q[$i]==0 || $q[$j]==0) {
			$h=0;
			last ILOOP;
		}
	  $h+=  ( (($m{$bases[$i]}{$bases[$j]}+$m{$bases[$j]}{$bases[$i]}) / $base_spaces)**2 )/( 2*$q[$i]*$q[$j] );
	}
}
#print "$h \n";

#10.02.05 print 'NA' for k_jc, k_kimura, k_tn if log(0), divide by zero, sqrt(-1), etc. (Tin Louie & Saba Sajjadian)
my $k_tajima_nei;
my $SE_tajima_nei;
eval {
	$p=$base_mismatches/$base_spaces;
	$b=($b1+($p**2/$h))/2;
	#print "$b1\t$h\t$p\t$b\n";
	$k_tajima_nei= -$b * log ( 1 - $p / $b);
	$SE_tajima_nei= ($b**2*$p*(1-$p)/(  $base_spaces*($b-$p)**2 )  )**0.5;
};
if ($@) {
	$k_tajima_nei = 'NA';
	$SE_tajima_nei = 'NA';
}
print "Tajima and Nei's      K = $k_tajima_nei    SE = $SE_tajima_nei\n";
print SUM "$k_tajima_nei\t$SE_tajima_nei\t";


$s1_a=0;
foreach $b ('A','T','C','G') {$s1_a+=$m{A}{$b}; }
$s1_t=0;
foreach $b ('A','T','C','G') {$s1_t+=$m{T}{$b}; }
$s1_c=0;
foreach $b ('A','T','C','G') {$s1_c+=$m{C}{$b}; }
$s1_g=0;
foreach $b ('A','T','C','G') {$s1_g+=$m{G}{$b}; }
#print "$s1_a $s1_t $s1_c $s1_g\n";
$f1=$s1_a*$s1_t*$s1_c*$s1_g;
$s2_a=0;
foreach $b ('A','T','C','G') {$s2_a+=$m{$b}{A}; }
$s2_t=0;
foreach $b ('A','T','C','G') {$s2_t+=$m{$b}{T}; }
$s2_c=0;
foreach $b ('A','T','C','G') {$s2_c+=$m{$b}{C}; }
$s2_g=0;
foreach $b ('A','T','C','G') {$s2_g+=$m{$b}{G}; }
$f2=$s2_a*$s2_t*$s2_c*$s2_g;

$j=
+$m{A}{A}*( $m{T}{T}*($m{C}{C}*$m{G}{G}-$m{G}{C}*$m{C}{G}) - $m{T}{C}*($m{C}{T}*$m{G}{G}-$m{G}{T}*$m{C}{G}) + $m{T}{G}*($m{C}{T}*$m{G}{C}-$m{G}{T}*$m{C}{C}) )
-$m{A}{T}*( $m{T}{A}*($m{C}{C}*$m{G}{G}-$m{G}{C}*$m{C}{G}) - $m{T}{C}*($m{C}{A}*$m{G}{G}-$m{G}{A}*$m{C}{G}) + $m{T}{G}*($m{C}{A}*$m{G}{C}-$m{G}{A}*$m{C}{C}) )
+$m{A}{C}*( $m{T}{A}*($m{C}{T}*$m{G}{G}-$m{G}{T}*$m{C}{G}) - $m{T}{T}*($m{C}{A}*$m{G}{G}-$m{G}{A}*$m{C}{G}) + $m{T}{G}*($m{C}{A}*$m{G}{T}-$m{G}{A}*$m{C}{T}) )
-$m{A}{G}*( $m{T}{A}*($m{C}{T}*$m{G}{C}-$m{G}{T}*$m{C}{C}) - $m{T}{T}*($m{C}{A}*$m{G}{C}-$m{G}{A}*$m{C}{C}) + $m{T}{C}*($m{C}{A}*$m{G}{T}-$m{G}{A}*$m{C}{T}) )
;
if (($f1*$f2 <= 0) or ($j <= 0)){ 
	$d_lake = 'NA';
} else {
	$d_lake=-0.25*( log($j) - 0.5* log ($f1*$f2) );
}
$SE_lake="NA";
print "Lake's distance       d = $d_lake\n";
#print "Lake F1: $f1 F2: $f2 J: $j\n";
print SUM "$d_lake\t";
print "\n";
print "BASE SPACE MATRIX___________________________________\n";
print "\tS2\tA\tT\tC\tG\tN\n";
foreach $b1 ('A','T','C','G','N') {
	print "S1\t$b1\t";
	foreach $b2 ('A','T','C','G','N') {
		$m{$b1}{$b2}=0 if $m{$b1}{$b2} eq ""; 
		print $m{$b1}{$b2},"\t";
		print SUM $m{$b1}{$b2}, "\t";
	}
	print "\n";
}
print "----------------------------------------------------\n";
print SUM "\n";



#GTCTGTTCCAAGGGCCTTTGCGTCAGGTGGGCTCAGGGTTCCAGGGTGGCTGGACCCCAGGCCCCAGCTCTGCAGCAGGGAGGACGTGGCTGGGCTCGTGAAGCATGTGGGGGTGAGCCCAGGGGCCCCAAGGCAGGGCACCTGGCCTTCAGCCTGCCTCAGCCCTGCCTGTCTCCCAG
#GTCTGTTCCAAGGGCCTTTGCGTCAGGTGGGCTCAGGGTTCCAGGGTGGCTGGACCCCAGGCCCCAGCTCTGCAGCAGGGAGGACGTGGCTGGGCTCGTGAAGCATGTGGGGGTGAGCCCAGGGGCCCCAAGGCAGGGCACCTGGCCTTCAGCCTGCCTCAGCCCTGCCTGTCTCCCAG

#GTCTGTTCCAAGGGCCTTCGAGCCAGTCTGGGCCCCAGGGCTGCCCCACTCGGGGTTCCAGAGCAGTTGGACCCCAGGTCTCAGCGGGAGGGTGTGGCTGGGCTCTGAAGCATTTGGGTGAGCCCAGGGGCTCAGGGCAGGGCACCTGCCTTCAGCGGCCTCAGCCTGCCTGTCTCCCAG
#GTCTGTTCCAAGGGCCTTCGAGCCAGTCTGGGCCCCAGGGCTGCCCCACTCGGGGTTCCAGAGCAGTTGGACCCCAGGTCTCAGCGGGAGGGTGTGGCTGGGCTCTGAAGCATTTGGGTGAGCCCAGGGGCTCAGGGCAGGGCACCTGCCTTCAGCGGCCTCAGCCTGCCTGTCTCCCAG

=head1 NAME

B<align_scorer>

=head1 SYNOPSIS

 align_scorer alignmentfile

=over 5

This simply calculates the statistics for the aligment stored in the F<alignmentfile>. The positions of indels, mismatches, and a line of summary statistics are found in F<alignmentfile.indel>, F<alignmentfile.mismatch> and F<align_scorer.summary>.

=back

 align_scorer alignmentfile 100 500

=over 5

This limits the calculation of the statistics to positions 100 to 500 within the FIRST (top) sequence.

=back

=head1 DESCRIPTION

A simple program to capture alignment statistics from pairwise alignment(s).

=head1 INPUT

Three types of pairwise alignments are acceptable:

=over 5

=item * Standard output from the align program (Myers and Miller) found distributed with Pearson's fasta2 package

=item * Web text output from http://genome.cs.mtu.edu/align/align.html .  This option has been used little in the past couple years although the web site is still available.

=item * A file containing two fasta records representing the two sequences of the pairwise alignments with dashes representing the gaps.  This is the latest input represents a simple intermediate output to parse from other programs.

=back

=head1 OUTPUT

There is a multitude of output.  The majority of which should be self-explanatory.  The number of alignment positions that contained bases in both sequences was referred to as base spaces.  Thus, the number of base spaces is the sum of matches and mismatches.  Four values of genetic distance correcting for multiple substitutions are calculated (Jukes Cantor, Kimura's 2 parameter, Tajemi-Nei's and Lake's). It is left to the user to choose their favorite.  


=head1 AUTHOR

Jeff Bailey (jab@cwru.edu)

=head1 ACKNOWLEDGEMENTS

This software was developed in the laboratory of Evan Eichler, Department of Genetics,Case Western Reserve University and University Hospitals, Cleveland.

=head1 COPYRIGHT

Copyright (C) 2000 Jeff Bailey. Distribute and modify freely as defined in the GNU General Public License.  

=head1 DISCLAIMER

This software is provided `as is' without warranty of any kind.
