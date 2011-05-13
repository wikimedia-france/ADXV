#! /usr/bin/perl -w

#use strict;
use warnings;

open(INADXV, $ARGV[0]);

#my $count;
my $file; 
my $mark;
my $mark1;
#my $cote;
my $ctag_before;
my $ctag_after;
my $i;


$mark=0;
#$count=0;
$mark1=0;
$ctag_before="";
$ctag_after="";
$i=0;

print "######################################################\n";
print "ADXV (file splitting) on $ARGV[0].\n";
print "######################################################\n";


while($toto=<INADXV>){

    if($toto=~ /^<c id/){
	#$count++; #bon y'aura probablement un problème avec les <c> sans <dao>. Et aussi un pb avec les décalages, p.ex AD015_30_FI_373 qui n'existe pas dans <c>.
	$mark=1;
	$ctag_before="";
	$ctag_after="";
	}

    if(($toto=~ /^<dao href/) and ($mark==1)){ #est-ce qu'il y a un média associé et quel est son nom ?
	if($mark1==0){ #On crée un tableau avec tous les identifiants de médias (dans <dao>). Là c'est l'init.
	  @Multiple=();
	  @Lines=();
	}
	$mark1=1;
	@splitDAO=split(/_/, $toto); #split
	$media=$splitDAO[scalar(@splitDAO)-1];
#	print $media;
#	@splitMediaMult=split(/-/, $media); #ben finalement non : on appelle le fichier du nom du média
#	if(scalar(@splitMediaMult)==1){ #ça veut dire qu'on n'a rien eu à splitter, donc qu'il n'y a pas de -
	@splitMedia=split(/\./, $media); #protect yr meta-var, by any means necessary!
	$mediaNum = $splitMedia[0];
#	print "Heya\n";
#	}
#	else{
#	  $mediaNum = $splitMediaMult[0];
#	  print "Splitted\n";
#	}
#	print " b : $mediaNum\n";
	push(@Multiple, $mediaNum); # an array is always created. Whether there are several <dao> for the same <c> or not.
	push(@Lines, $toto);
#	print "Hello";
#	print $splitMedia[0];
	}
    if(($mark==1) and ($toto!~ /^<dao href/)){
	if($mark1==0){$ctag_before.=$toto;}
	else{$ctag_after.=$toto;} #mark1==1 after the <dao>
	}
    if($toto=~ /^<\/c>/){
	if($mark1==1){ #s'il y a un média associé
		@BaseName=split(/\./, $ARGV[0]);
		$i=0;
#		print "pouet : $ctag_after";
		foreach (@Multiple){
		  $file="$BaseName[0]_$_.data"; #fichiers data basename du XML.numdumedia.data
		  open(OUTADXV, '>', "Tests/$file");
		  print OUTADXV "$ctag_before$Lines[$i]$ctag_after";
		  $i++;
#		  print "$_ : $i\n";
#		  print "Filename: $file\n";
		}
		
	}
	$mark1=0;
	$mark=0;
#	close(OUTADXV);
    }
}

close(INADXV);
