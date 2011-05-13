#! /usr/bin/perl -w

#use strict;
use warnings;

my $mark;
my $mark1; #we found a DAO for <c>
my $cote;
my $mediaNum;
my $count;
my $errCount;
my $daoCount;
my $totCount;
my $mark2; #we found the first DAO for <c>
my $InitMult;
my $DAOInconsistency;

$okCount=0;
$errCount=0;
$daoCount=0;
$totCount=0;
$mark=0;
$mark1=0;
$mark2=0;
$DAOInconsistency=0;

#open(INADXV,"FRAD015_30_FI.utf8.xml"); #le nom de fichier est mis en dur, à changer.
open(INADXV, $ARGV[0]);

print "##################################\n";
print "Check cote on $ARGV[0].\n";
print "##################################\n";

while($toto=<INADXV>){
    if($toto=~ /^<c id=/){
	$mark=1;
	$totCount++;
    	}
    if(($toto=~ /^<unitid/) and ($mark==1)){ #pour choper la cote dans un <c>
	@splitUnitid = split(/\W/, $toto); #On espère que ça soit toujours construit pareil. En même temps, si je vérifie que la cote est bien toujours la même entre unitid et le dao, le prend le dao.
	$cote = $splitUnitid[11]; #est-ce que ca marche toujours (is it always the right position)?
#	print $cote;
    	}
    if(($toto=~ /^<dao href/) and ($mark==1)){ #est-ce qu'il y a un média associé ?
    	if($mark1==0){
		@Multiple=();
		$daoCount++;
	} #On compte le nombre de <c> avec au moins un media (pas besoin de compter avec multiplicité.
#	else{
#		$mark2=1;
#		push(@Multiple, $mediaNum); #The var already refers to an DAO id (the first in the <c>)
#		print "BOUHA @Multiple";
#		} #We probably want to check smth with <c> having multiple <dao>'s.
    	$mark1=1;
	@splitDAO=split(/_/, $toto);
	$media=$splitDAO[scalar(@splitDAO)-1];
#	print $media;
	@splitMediaMult=split(/-/, $media);
	if(scalar(@splitMediaMult)==1){ #ça veut dire qu'on n'a rien eu à splitter, donc qu'il n'y a pas de -
		@splitMedia=split(/\./, $media); #protect yr meta-var. By any means necessary!
		$mediaNum = $splitMedia[0];
#		print "Heya\n";
		}
	else{
		$mediaNum = $splitMediaMult[0];
#		print "Splitted\n";
		}
#	print " b : $mediaNum\n";
	push(@Multiple, $mediaNum); # an array is always created. Whether there are several <dao> for the same <c> or not.
#	print "Hello";
#	print $splitMedia[0];

	}
    if($toto=~ /^<\/c\>/){
#    	print "Hello";
	$mark=0;
	
	##Checking DAO consistency within the <c>
#	print "BOUH: @Multiple\n";
	$InitMult=@Multiple[0];
	foreach (@Multiple){
	  if($InitMult!=$_){$DAOInconsistency++;}
	}
		
	##Checking consistency between DAO and cote
	if($mark1==1){ #s'il y a un média associé
#		print "$cote $mediaNum";
		if($cote=$mediaNum){
			$okCount++;
#			print "ok";
			}
		else{
#			print "BUG";
			$errCount++;
			}
#		print "\n";
		}
		
	$mark1=0;
	$mark2=0;
	}
}

print "\n#################### Results ################\n";
print "Total <c> records: $totCount \nNb of <c> records with at least one <dao> (media): $daoCount\n";
print "Match: $okCount \nMismatch: $errCount \n";
print "DAO inconsistency: $DAOInconsistency \n";
close(INADXV);
