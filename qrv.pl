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
	6 -....	7 --...	8 ---..	9 ----.		

	/ -..-.	? ..--..	, --..--	. .-.-.- 

[error] ........
[end] .-.-.	[final] ...-.-	[pause] -...-
[clear] -.-..-..  [break] -...-.-	[nobrkr] -.--.	
[wait] .-...

	' .----.	
	! ---. - -....-
	; -.-.-. 
	( -.--.-	"  .-..-.
	
	@ .--.-.
				
	[attn] -.-.-		
	[verify] ...-.	
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

my @numbers = (0..9);
foreach my $i(0..9){
	foreach my $j(0..9){
		push @numbers, $i.$j;
	}
}
foreach my $i(0..9){
	foreach my $j(0..9){
		foreach my $k(0..9){
			push @numbers, $i.$j.$k;
		}
	}
}

my @prosigns = grep /^\W/, keys %thecode;

my @qcodes = qw/
	QRL	QRL?	QRZ QRZ?	QRV QRV?	QTH QTH?	QRT QRT?
	QRM QRM?	QRN QRN?	QRO QRO?	QRP QRP?	QRQ QRQ?
	QSL QSL?	QSO QSO?	QST	QRS QRS?	QRG QRG?	QRH QRH?
	QRI QRI?	QRJ QRJ?	QRK QRK?	QRX QRX?	
	QSA QSA?	QSB QSB?	QSP QSP?	QSV QSV?	QSX QSX?
	QSZ QSZ?	QSR QSR?
/;

my @abbrs = qw/
	c cq   de dx   hw? hw   cpy? es   fb ga   gb ge   gm gn 
	sri rpt   pse tnx   ur 73   ant gnd   tx rx 
	rcvr xmtr    xcvr rig    pwr w
	n	urs    wx
	agn abt adr b4 cfm cul gg
	hi hihi hr hv lid msg nil nr nw ob om op ot 
	  sed sez tmw tt tu tvi  
	wkd wkg wl wud   xyl yl 
/;

my @wordbank = (
	\@qcodes,
	\@prosigns,
	\@abbrs,
	\@calls_i_know,
#	\@numbers,
);



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









my @data = <DATA>; # if you want to start with something else?
chomp(@data);


#######################
# add the lists, 4 at a time...

while(1){
	my $empties = 0;
	foreach my $list(@wordbank){
		my $c = 0;
		while(@$list){
			push @data, shift @$list;
			$c++;
			last if $c >= 4;
		}
		$empties++ if $c == 0;
	}
	last if $empties == @wordbank;
}




# add stuff??
#push @data, @prosigns;


my $longest = 0;
foreach(@data){
	$longest = length($_) if length($_) > $longest;
}

if(@data < $choosebetween){
	$choosebetween = @data;
}


sub make_data_relations {
	my @data = @_; # not the same as the data from outside!
	### figure out the closest relatives of each text
	### so the user needs to work harder to distinguish them!
	#my %codes = map {$_ => $morse->Encode($_)} @data;
	my %codes = map {$_ => encode($_)} @data;

	my %nearest = ();
	my $maxchoiceindex = $choosebetween-1;
	foreach my $text1(@data){
		#print "calculating $text1\n";
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
	return %nearest;
}


my $level = 3;
my %nearest = make_data_relations(@data[0..$level]);

my @last10 = ();
my $score = 0;

while(1){
	my $n = 1;
	$level = @data if $level > @data;
	my $seed = $data[int(rand()*($level+1))];
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
		my $correct = 0;
		if($ans == $play){
			$correct = 1;
			print "Well done.  Another!";
		}
		else {
			push @last10, 0;
			print "Nope... it was: $choices[$play]\nTry another.";
			sleep 1;
		}
		$score += $correct;
		push @last10, $correct;
		if(@last10 > 10){
			$score -=  shift @last10;
		}
		if($score >= 9){
			print "\nscore >= 9, adding another...";
			$level++;
			%nearest = make_data_relations(@data[0..$level]);
			$score = 0;
			@last10 = ();
		}

		print "  (level: $level; score: $score)\n";
	}
	else {
		print "\nunrecognised key: $ans\ntry another...\n";
	}
}


=cut


=cut

__DATA__