#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Text::Morse;
use Text::Levenshtein qw(distance);
use Term::ReadKey;

print "QRV - get ready for cw on the air\n";
print "by Jimi Wills MM0JTX\n";

ReadMode(3);
END{ReadMode(0);}

my $cw = '~/unixcw-3.5.1/src/cw/cw';

my $wpm = 40;
my $freq = 700;
my $choosebetween = 4;
my $hints = 0;

my @choicekeys = qw/a s d f j k l ;/;
my %choicekeys = map {$choicekeys[$_]=>$_} (0..$#choicekeys);


my $morse = new Text::Morse;

sub cw {
	my ($text,$wpm,$freq) = @_;
	`echo "$text" | $cw -t $freq -w $wpm`;
}

sub hint {
	return unless $hints;
	print scalar($morse->Encode($_[0])),"\n";
}

sub quit {
	ReadMode(0);
	print "\n73\n";
}

cw('qrv', $wpm, $freq);

my @data = <DATA>;
chomp(@data);
my $longest = 0;
foreach(@data){
	$longest = length($_) if length($_) > $longest;
}

if(@data < $choosebetween){
	$choosebetween = @data;
}


### figure out the closest relatives of each text
### so the user needs to work harder to distinguish them!
my %codes = map {$_ => $morse->Encode($_)} @data;

my %nearest = ();
my $maxchoiceindex = $choosebetween-1;
foreach my $text1(@data){
	my $code1 = $codes{$text1};
	my %sims = ();
	foreach my $text2(@data){
		my $code2 = $codes{$text2};
		my $sim = distance($code1, $code2);
		$sims{$text2} = $sim;
	}
	my @sims = (sort {$sims{$a} <=> $sims{$b}} keys %sims)[0..$maxchoiceindex];
	#print "===\n$text1\n";
	#print map {$_."\t".$codes{$_}."\n"} @sims;
	$nearest{$text1} = [@sims];

}


while(1){
	my $n = 1;
	my $seed = $data[int(rand()*@data)];
	my @choices = sort {rand() <=> rand()} @{$nearest{$seed}};
	my $play = int(rand()*$choosebetween);
	hint($choices[$play]);
	cw($choices[$play],$wpm,$freq);
	print map {sprintf("\%-${longest}s  ", $choicekeys[$_-1])} 1..$choosebetween;
	print "\n";
	print map {sprintf("\%-${longest}s  ", $choices[$_-1])} 1..$choosebetween;
	print "\n? ";
	my $ans = ReadKey();

	if($ans eq 'q'){ quit(); }

	if(exists $choicekeys{$ans}){
		$ans = $choicekeys{$ans};
		if($ans == $play){
			print "Well done.  Another!\n";
		}
		else {
			print "Nope... it was: $choices[$play]\nTry another...\n\n";
			sleep 1;
		}
	}
	else {
		print "\nunrecognised key: $ans\ntry another...\n";
	}
}


=cut

QRL
CQ
DE
ES
?
C
/

=cut

__DATA__
QRL?
QRZ?
QRL
QRZ
CQ
DE
ES
?
C
/
M6OGI
MM0JTX