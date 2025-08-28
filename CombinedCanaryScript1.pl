use strict;
use warnings;
### This is a text file containing a list of fasta files that contain only the sequence of interest ###
my $SoIList = $ARGV[0];
### This is a fasta file containing the Base Dataset ###
my $BaseFile = $ARGV[1];
### This is a signal notifying the program of whether you are using dna or protein data ###
my $datatype = $ARGV[2];
### This is a signal notifying the program of what prefix you would like for your FullDataset Output File ###
my $fullfile = $ARGV[3];

open (SILIST, '<', $SoIList);
system ("mkdir SoI");
system ("mkdir SoI/nRCFV_Failed");
open (OUT, '>', "SoI/SoI.nRCFV_Test_Results.txt");
open (SEQLIST, '>', "SoI/SequenceOfInterestNames.txt");

my @LongList;
my @PassList;
while(<SILIST>){
	my @ntRCFV_List;
	my $SoI=$_;
	my $sum;
	my $var;
	chomp($SoI);
	push (@LongList, $SoI);
	system ("muscle -profile -in1 $BaseFile -in2 $SoI -out SoI/SoI.$SoI");
	system ("perl RCFVReader_v1.pl $datatype SoI/SoI.$SoI SoI/SoI.$SoI");
	open (NTRCFV, '<', "SoI/SoI.$SoI.ntRCFV.txt");
		while(<NTRCFV>){
			next if /^\s*$/;
			next if /^ntRCFV values\:/;
			my $ntRCFV = $_;
			my @ntRCFV_Splitter = split /\s/, $ntRCFV;
			my $ntRCFV_Value = $ntRCFV_Splitter[1];
			push(@ntRCFV_List, $ntRCFV_Value);
			}
	foreach (@ntRCFV_List){
		$sum += $_;
		}
	my $ntRCFV_Size = @ntRCFV_List;
	my $RCFV = $sum/$ntRCFV_Size;
	print ("nRCFV\t", $RCFV, "\n");
	foreach(@ntRCFV_List){
		$var += ($_-$RCFV)**2;
#		print ($var, "\n");
		}
	my $Std_Dev = sqrt($var/($ntRCFV_Size-1));
	print ("Std Dev\t", $Std_Dev, "\n");
	print ("Check \t",$RCFV+($Std_Dev*2), "\n");
	if ($ntRCFV_List[@ntRCFV_List-1] >= $RCFV+($Std_Dev*2)){
		print ($SoI, "\t nRCFV Test Failed \n");
		system ("mv SoI/SoI.$SoI SoI/nRCFV_Failed");
		}
	else {
		push (@PassList, "$SoI");
		print OUT ($SoI, "\t nRCFV Test Passed \n");
		}
	}
system ("cat $BaseFile @LongList > Unaligned.FullDataset.fa");
system ("muscle -in Unaligned.FullDataset.fa -out $fullfile.fa");
my @FastaList;
foreach (@PassList){
	open (PASSLIST, '<', $_);
	while(<PASSLIST>){
		if ($_=~m/^>/){
		my $JustName = substr $_, 1;
		push (@FastaList, $JustName);
	}
	}
}
print SEQLIST (@FastaList, "\n");


