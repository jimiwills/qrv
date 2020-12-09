#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
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


my %thecode = qw{
	A .-	B -...	C -.-.	D -..	E .	F ..-.	G --.	H ....
	I ..	J .---	K -.-	L .-..	M --	N -.	O ---	P .--.
	Q --.-	R .-.	S ...	T -	U ..-	V ...-	W .--	X -..-
	Y -.--	Z --..	0 -----	1 .----	2 ..---	3 ...--	4 ....-	5 .....
	6 -....	7 --...	8 ---..	9 ----.	@ .--.-.	! ---. - -....-
	, --..--	. .-.-.- / -..-.	? ..--..	( -.--.-	"  .-..-.
	' .----.	[wait] .-...	[pause] -...-	[end] .-.-.	[final] ...-.-
	[break] -...-.-	[nobrkr] -.--.	[attn] -.-.-	[clear] -.-..-..	
	[verify] ...-.	; -.-.-. [error] ........
};


my @calls_i_know = qw{
	MM0JTX
	M6OGI
	SF1Z
	MM0DXC
	GM2T
	GM4UYZ
	MM0INE
};

my @prosigns = grep /^\[/, keys %thecode;

my @qcodes = qw/
	QRL	QRL?	QRV QRV?	QTH QTH?	QRT QRT?	QRM QRM?
	QRN QRN?	QRO QRO?	QRP QRP?	QRQ QRQ?	QSL QSL?
	QSO QSO?	QST	QRS QRS?	QRG QRG?	QRH QRH?
	QRI QRI?	QRJ QRJ?	QRK QRK?	QRX QRX?	QRZ QRZ?
	QSA QSA?	QSB QSB?	QSP QSP?	QSV QSV?	QSX QSX?
	QSZ QSZ?	QSR QSR?
/;

my @abbrs = qw/
	abt adr agn ant b4 c cfm cul es fb ga gb ge gg gm gn gnd
	hi hihi hr hv hw hw? lid msg n nil nr nw ob om op ot pse
	pwr rig rpt rx rcvr sed sez sri tmw tnx tt tu tvi tx ur 
	urs wkd wkg wl wud wx xcvr xmtr xyl yl 73
/;


sub encode {
	my ($text) = @_;
	my @words = split /\s+/, uc $text;
	my @codes = ();
	foreach my $word(@words){
		if($word =~ /^\[.*\]$/){
			$word = lc $word;
			# it's a prosign... look up the whole thing
			die "prosign '$word' not defined"
				unless exists $thecode{$word};
			push @codes, $thecode{$word};
		}
		else {
			my @wordcodes = ();
			foreach my $letter(split //, $word){
				die "character '$letter' not defined"
				unless exists $thecode{$letter};
				push @wordcodes, $thecode{$letter};
			}
			push @codes, join(' ', @wordcodes);
		}
	}
	return join(' / ', @codes);
}

sub cw {
	my ($text,$wpm,$freq) = @_;
	`echo "$text" | $cw -t $freq -w $wpm`;
}

sub hint {
	return unless $hints;
	print encode($_[0]),"\n";
}

sub quit {
	ReadMode(0);
	print "\n73\n";
}

cw('qrv', $wpm, $freq);

my @data = <DATA>;
chomp(@data);

# add stuff??
#push @data, @prosigns;


my $longest = 0;
foreach(@data){
	$longest = length($_) if length($_) > $longest;
}

if(@data < $choosebetween){
	$choosebetween = @data;
}


### figure out the closest relatives of each text
### so the user needs to work harder to distinguish them!
#my %codes = map {$_ => $morse->Encode($_)} @data;
my %codes = map {$_ => encode($_)} @data;

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