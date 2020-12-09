# qrv

![alt text](https://github.com/jimiwills/qrv/blob/master/qrv.png?raw=true)

Get ready (enough) for CW.

## project name

QRV is the Q-CODE for "ready".  This project aims to get you (actually me)
ready to go on the air, without necessarily being super amazing.

## motivation

Most methods I've come across for learning morse code either focus on 
character recognition (Koch, etc) or teach you the code itself rather
than teaching how to use it.

If you're unlucky, like me, you've learnt the code first, and now you
have a lookup table in your head that slows you down.  By the time you've
processed a character, two more have gone by.  The Koch method and friends
are painful, and at 25 wpm you're struggling to keep up.  Meanwhile,
on 7023 they're tapping it out at 40 wpm, and after listening to a CQ for
several minutes, you still can't make out the callsign!

But it's not your fault.  You didn't know when you started out that
"learning the code" would make it super difficult to actually use the code.

Fear not.  Help is at hand.

## approach

Forget the code.

The majority of code on the air is made up of a very small vocabulary,
with the exception of callsigns and serial numbers.  So why focus on 
learning random 5-character strings?  Learn a handful of 
common words and get on the air quickly!

About those callsigns?  Don't worry so much!  People usually give them
more than once, and once you've figured it out, you know what to expect.
And numbers are easy to drill in sequences of 3, the usual serial length. 
And you can avoid them altogether by avoiding contests! (if you want)

The point is that you'll be familiar with most of what you're hearing and able to spare the brain capacity to figure out the calls and serials.

## inspiration

okay, so I'm not the first person to have this idea, and for all I know
there might already be software out there that does this... but it's for
windows, so I'm not testing it.

For me, the idea came when reading about FT8.  In FT8, there is redundancy
in the message and there's very strict timing to aid in decoding.

What I found very cool, is that a reply to your message has not only an
expected structure and timing, but expected data too!  Your callsign is 
in there, and that information can be used to further help fish messages
out of the noise.  Very cool!

But your brain does this too.  In conversation on SSB, you may experience
QRM, QRN, QSB, but a lot of the time you are able to piece together the
conversation from the context.

When you're reading badly printed or very old material, some words might
be illegible or mistaken on their own, but in context it's fine.

The same is true of CW QSOs on multiple levels.

1. Your callsign should be recognisable to you
2. DE is very easy to learn (along with ES, and a bunch of prosigns)
3. The format of the QSO is likely to be predictable (especially in contest)
4. The emergent sentence will lead to expectation of the next word
5. The vocabulary is, by and large, limited and predictable

## strategy

Listen to common words, q-codes, prosigns first.  Listen to some very
similar-sounding codes and distinguish them.  Learn them as units, not
as strings of characters.

What helps with listening to the whole word at once?  Speed!

I personally cannot listen to code at 25 wpm and not hear individual
characters... so I need to speed it up.  Initial experimentation leads
me to the conclusion that I can distinguish "QRL?" and "QRZ?" at 40wpm.
Not 100% of the time, and not easily, but I can do it.

Spot the difference:

<pre>
     --.- .-. .-.. ..--..

     --.- .-. --.. ..--..
</pre>

The difference is intentionally buried in the pattern so you have to 
learn the difference listening to the whole thing, and not cheating
by just listening to the last character.  

I actually am no longer hearing the characters. It feels great. You should
try it!

I actually didn't know the code for ? (question mark) before playing with
this idea, and I can tell you that learning the sound first is VERY
POWERFUL!   For me at least.


## method


At present, I'm writing a perl script that uses:

- use Text::Morse;
- use Text::Levenshtein qw(distance);
- use Term::ReadKey;

and externally

- unixcw-3.5.1 

cw built from source on my machine as this solves several issues with 
connecting to the correct resources and playing from a pipe. 



The DATA section of the script contains a list of words to learn.  
Each word (or phrase, I suppose) is converted to morse code, and the 
Levenshtein edit distance is calculated between all pairs.  For each word,
the closest other words are listed against it.

The main loop is entered...

A word is selected at random, then its list of most closely related words
is used to generate a list of options.  In fact, to increase variation of
experience, one of these words (including the original random selection)
is then selected at random as the actual word to play.

The word is played via unixcw.

The options are printed on the screen underneath the keys, asdf.

(actually the number of options can be modified, as can the keys)

You then have four options, maybe like this:

<pre>
a       s       d       f       
QRZ?    QRZ     CQ      QRL     
?
</pre>

you have your fingers on the keys, and select the only you think was
played.


At present, it tells you if you were right or wrong and moves on to the
next.


## future direction

wants:

- scoring
- automatic addition of words to your vocab in a useful order
- add your callsign, callsigns of your friends/club members to learn
- random tone variation
- random pitch variation
- monitor response time
- log results and plot progress

later

- make it self contained
- platform independent?
- on the web
- phone app?


## Conclusion

This program focuses on getting ready for CW QSOs on HF at high speed, 
not perfect at copying random 5-character strings.  The actual aim is 
for me to get on the air as soon as practicable, never mind the buzzcocks.


## Licence

GNU GPL v3 - see 
[LICENCE](https://github.com/[username]/[reponame]/blob/[branch]/LICENCE?raw=true)

## Author/contact

Jimi MM0JTX

Fully licenced amateur in UK
and hacker for fun and profit

<github.com/jimiwills>
