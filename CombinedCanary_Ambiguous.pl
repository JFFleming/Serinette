use strict;
use warnings;
use 5.010;

# This is a Newick File containing the Base Tree
my $BaseTree = $ARGV[0];
# This is a list of Newick Files containing each SoI Tree
my $Treelist = $ARGV[1];
# This is a csv containing the clade definitions to examine monophyly (see ReadMe)
my $CompareClades = $ARGV[2];
# This is a list of names of sequences of interest in clade csv format (see ReadMe)
my $Seqlist = $ARGV[3];
# This is a list of outgroup taxa in text format
my $Outgroup = $ARGV[4];
#my $DropTips = "SoI/SequenceOfInterestNames.txt";

open (TREELIST,'<', $Treelist);

my @TreeArray;

while(<TREELIST>){
	my $Tree = $_;
	chomp($Tree);
	push (@TreeArray, $Tree);
}

open (SEQLIST,'<', $Seqlist);
my @SeqNames;
my @SeqDesc;
my $x=0;

while (<SEQLIST>){
	my $Desc = $_;
	chomp($Desc);
	push (@SeqDesc, $Desc);
	my @Splitter = split /,/, $Desc;
	push (@SeqNames, $Splitter[0]);
}

my @CanaryAssess;

foreach (@SeqNames){
	print ($_, "\n");
	system ("cp $CompareClades $_.$CompareClades");
	open (NEWCLADE, ">>$_.$CompareClades") or die "Could not open $_.$CompareClades";
	print ("$_.$CompareClades \n");
	say NEWCLADE "$SeqDesc[$x]";
#	system ("Rscript CombinedCanaryScript3.r $TreeArray[$x] $_.$CompareClades $_");
	print "Rscript CanaryAmbigScript.r $TreeArray[$x] $CompareClades $_ $Outgroup > $_.FinalDatasetAssessment.txt\n";
	system ("Rscript CanaryAmbigScript.r $TreeArray[$x] $CompareClades $_ $Outgroup > $_.FinalDatasetAssessment.txt");
	push (@CanaryAssess, "$_.FinalDatasetAssessment.txt");
	$x++;
}


####This Doesn't Work Yet ####
foreach (@CanaryAssess){
	my $InFile = $_;
	open (ASSESS, '<', $InFile);
#	print "$InFile\n";
	my @reader;
		while (<ASSESS>){
			#print "reading\n";
			my $line = $_;
			push (@reader, $line);
		}
#			print "@reader\n";
			if (grep (/"Non-Isomorphic"/, @reader)){
					print "$InFile \t Non-Isomorphic \t Reject Sequence\n";
					}
			elsif (grep (/"Isomorphic"/, @reader)){
				print "$InFile \t Isomorphic \t Accept Sequence\n";
				}			
#			print scalar @reader, "\n";
			undef @reader;
}