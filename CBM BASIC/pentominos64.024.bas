!------------------------------------------------------------------------------
!- Pentominos 64
!-      A puzzle-solving program for the Commodore 64
!- V 0.24  17-10-2015
!-      Incorporating the 'headliner' routines for big char set headline
!- V 0.23
!-      Try squares instead of cicles
!- V 0.22
!-      Adding backgound 'graphic'
!-      Adding a timer. Repostioning the container/box
!- V 0.21
!-      Let's print in colours instead of plain letters
!-      Reformatted for easier modification & viewing
!-
!- Originally:
!-      Pentominos for commodore computers
!-      by Jim Butterfield, Compute! May 1984
!-
!-      Copied and pasted into CBM Prg Studio
!-      On 5th September 2015
!-      A.B.Sayuti H.M.Saman
!------------------------------------------------------------------------------
!-   Initialization
100 poke 52,128 : poke 56,128: clr :rem set basic FRETOP & MEMSIZ at $8000
110 print chr$(142) :rem switch to uppercase
120 gosub 1550      :rem setup big custom charset
130 rem print "{clear}{down*4}{right*10}p e n t o m i n o s"
135 x$="pentominos" :gosub 1760
140 print "{down}{right*14}";
150 poke 53280,0: poke 53281,0
160 hm$ = "{home}{right*4}{down*4}"
170 v$ = "{down*13}"
180 h$ = "{right*23}"
190 c$ = "{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}"
200 dim pc$(13)
210 for i=0 to 12
220     pc$(i) = mid$(c$,i+1,1)
230 next i
240 dim x(63,4), y(63,4), p(64)
250 dim p$(13)         :rem names of the pieces
260 dim t(13)          :rem which rotation is currently being tried for piece X
270 dim s(13)          :rem starting rotation for piece X
280 dim b(6,20)        :rem board contents
290 dim x1(5),y1(5), u(12)
300 dim x2(12), y2(12) :rem starting square where a piece has been placed
310 read p$,n
320     if n=0 goto 450
330     t = t+1
340     p$(t) = p$
350     s(t) = v+1
360     for j = v+1 to v+n
370         p(j) = t
380         for k=0 to 3
390             read x(j,k), y(j,k)
400         next k
410     next j
420     v = v+n
430     print p$;
440 goto 310
!------------------------------------------------------------------------------
!-   Get user input
450 print "{home}";left$(v$,10); :print"choose: {down}"
460 for j=3 to 6:print j;"by";60/j;"{down}": next j
470 input "select 3 thru 6";w1
480 if w1<3 or w1>6 or w1<>int(w1) goto 450
490 w2=60/w1
!------------------------------------------------------------------------------
!-   Clear screen, print background
500 print "{clear}{dark gray}"
510 rem goto 1450
520 for j = 1 to 20
530     if j/2<>int(j/2) then ch$ = "{cm z}{cm s}" :goto 550
540     ch$ = "{cm s}{cm z}"
550     for i = 1 to 19
560         print ch$;
570     next i
580     print
590 next j
600 print "{home}{down*12}
610 PRINT "{right}{cm a}{096}{105}{cm a}{096}{cm s}{cm a}{096}{105}{096}{cm r}{096}{117}{096}{105}{cm a}{105} {117}{cm s}{cm r}{cm a}{096}{105}{117}{096}{105}{117}{096}{105} {117}{096}{105}{098}  "
620 PRINT "{right}{098} {098}{098}  {098} {098} {098} {098} {098}{098}{098} {098}{098}{098}{098} {098}{098} {098}{098}   {098} {098}{098} {098}"
630 PRINT "{right}{098} {098}{098}  {098} {098} {098} {098} {098}{098}{106}{cm r}{107}{098}{098}{098} {098}{098} {098}{098}   {098}  {098} {098}"
640 PRINT "{right}{cm q}{096}{107}{cm q}{096} {098} {098} {098} {098} {098}{098} {098} {098}{098}{098} {098}{098} {098}{106}{096}{105} {cm q}{096}{105}{106}{096}{123}"
650 PRINT "{right}{098}  {098}  {098} {098} {098} {098} {098}{098} {098} {098}{098}{098} {098}{098} {098}  {098} {098} {098}  {098}"
660 PRINT "{right}{098}  {098}  {098} {098} {098} {098} {098}{098}   {098}{098}{098} {098}{098} {098}  {098} {098} {098}  {098}"
670 PRINT "{right}{cm e}  {cm z}{096}{cm x}{cm e} {cm e} {cm e} {106}{096}{107}{cm e}   {cm e}{cm e}{cm e} {cm e}{106}{096}{107}{106}{096}{107} {106}{096}{107}  {098}"
!-   Place container
680 print "{home}{down*4}{right*4}{cm a}";
690 for i=1 to w2 :print"{sh asterisk}"; :next
700 print "{cm s}"
710 for i=1 to w1
720     print "{right*4}B";
730     for j=1 to w2 :print" "; :next
740     print "B"
750 next i
760 print "{right*4}{cm z}";
770 for i=1 to w2 :print"{sh asterisk}"; :next
780 print "{cm x}"
!------------------------------------------------------------------------------
!-   Main routine
790 rem find new space to fill
800 time$ = "000000"
810 gosub 1430 :p = j  :rem get next unused piece
820 gosub 1460         :rem get next empty spot
830 if x1>w2 goto 1100 :rem if exceed container width, all filled up
840 rem get a new piece
850 t(p) = s(p)
860 print "{home}";p$(p);"{down*11}"
870 rem try fitting piece
880 c$ = "{reverse on}{sh @}{reverse off}" :x1(0)=x1 :y1(0)=y1
890 for j = 1 to 4
900     x = x(t(p),j-1)+x1
910     y = y(t(p),j-1)+y1
920     x1(j) = x
930     y1(j) = y
940     if x<1 or y<1 or x>w2 or y>w1 goto 1340 :rem rotate the piece
950     if b(y,x)<>0 goto 1340
960 next j
970 rem it fits - put piece in place
980 b=p
990 for j=0 to 4
1000     x = x1(j)
1010     y = y1(j)
1020     gosub 1520     :rem place the piece
1030 next j
1040 x2(p) = x1
1050 y2(p)=y1
1060 p1=p1+1
1070 u(p1)=p
1080 goto 810
!------------------------------------------------------------------------------
1090 rem board filled
1100 t$ = time$
1110 print "{home}{white}solved in ";
1120 print left$(t$,2);":";mid$(t$,3,2);":";right$(t$,2);"{down*20}" ;
1130 end
!------------------------------------------------------------------------------
1140 rem undraw last one
1150 p=u(p1)
1160 u(p1)=0
1170 p1 = p1-1
1180 if p1<0 then print"that's all" :end
1190 b=0
1200 x=x2(p)
1210 y=y2(p)
1220 c$=" "
1230 gosub 1520         :rem place the piece
1240 x1=x
1250 y1=y
1260 for j=1 to 4
1270     x=x(t(p),j-1)+x1
1280     y=y(t(p),j-1)+y1
1290     x1(j)=x
1300     y1(j)=y
1310     gosub 1520     :rem place the piece
1320 next j
1330 rem rotate the piece
1340 t(p)=t(p)+1
1350 if p(t(p))=p goto 880
1360 rem give up on piece
1370 t(p)=0
1380 rem look for new piece
1390 p=p+1
1400 if p>12 goto 1150
1410 if t(p)<>0 goto 1390
1420 goto 850
!------------------------------------------------------------------------------
!-   Find next unused piece
1430 for j=1 to 12
1440     if t(j)<>0 then next j
1450 return
!------------------------------------------------------------------------------
!-   Find next empty spot
1460 for x1=1 to w2
1470     for y1=1 to w1
1480          if b(y1,x1)=0 goto 1510
1490     next y1
1500 next x1
1510 return
!------------------------------------------------------------------------------
!-   Place the piece
1520 print hm$;left$(v$,y);left$(h$,x);pc$(p1);c$
1530 b(y,x)=b
1540 return
!------------------------------------------------------------------------------
!-   Setup the big char
1550 dim te(15) :poke53281,0 :poke53280,0 :print chr$(8) :g=54272
1560 poke 646,1 :for j=0 to 15 :read te(j) :next
1570 data 0,3,12,15,48,51,60,63,192,195,204,207,240,243,252,255
1580 poke 56578,peek(56578)or3 :rem set bits 0,1 as output
1590 poke 56576,(peek(56576)and 252)or 1  :rem point VIC2 to Bank1 ($8000)
1600 poke 53272,12   :rem screen=$8000, charset=$9000
1610 poke 648,128   :rem point kernal to new screen $8000
1620 print chr$(147)tab(125)"downloading the character set" :g=53248 :gn=45056
1630 poke 56333,127 :poke 1,51 :for q=0 to 1023 :poke gn+q,peek(g+q) :next
1640 poke 1,55 :poke 56333,129 :poke 53272,12  :rem charset->$B000 
1650 print chr$(147)tab(125)"forming the large characters" :poke 46080,0
1660 for r=0 to 212 step 8 :b1=12288+r :b2=46080+4*r
1670 for i=0 to 4 step 4 :for k=0 to 3 :j=peek(b1+k+i) :n=b2+2*(k+i)+1
1680 x1=te((j and 240)/16) :x2=te(j and 15)
1690 poke n,x1 :poke n+1,x1 :poke n+16,x2 :poke n+17,x2 :next k,i,r
1700 return
1710 rem ==============================================================
1720 rem The headliner printing subroutine
1730 rem     set x$ (text), sl (position) and cc (color) before calling
1740 rem     sl = 1024 is top left location of screen
1750 rem
1760 for p=1 to len(x$) :l=(asc(mid$(x$,p,1))-64)*4+128 :if l=0 then 1790
1770 poke sl+g,cc :poke sl+1+g,cc :poke sl+40+g,cc :poke sl+41+g,cc
1780 poke sl,l :poke sl+1,l+2 :poke sl+40,l+1 :poke sl+41,l+3
1790 sl=sl+2 :next
1800 return
!------------------------------------------------------------------------------
!- The pentomino pieces
!-
!- Piece I      0OOOO   0
!-                      O
!-                      O
!-                      O
!-                      O
1810 data I,2
1820 data 0,1,0,2,0,3,0,4
1830 data 1,0,2,0,3,0,4,0
!-
!- Piece X       0
!-              OOO
!-               O
1840 data X,1
1850 data 1,-1,1,0,2,0,1,1
!-
!- Piece V      0OO     0
!-              O       O
!-              O       OOO
1860 data V,4
1870 data 0,1,0,2,1,0,2,0
1880 data 0,1,0,2,1,2,2,2
1890 data 1,0,2,0,2,1,2,2
1900 data 1,0,2,0,2,-1,2,-2
!-
!- Piece T      0       0OO      O
!-              OOO      O       O
!-              O        O      0OO
1910 data T,4
1920 data 0,1,0,2,1,1,2,1
1930 data 1,0,1,1,2,0,1,2
1940 data 1,0,2,0,1,-1,1,-2
1950 data 2,-1,2,0,2,1,1,0
1960 data W,4
1970 data 0,1,1,1,1,2,2,2
1980 data 1,0,1,1,2,1,2,2
1990 data 0,1,1,-1,1,0,2,-1
2000 data 1,-1,1,0,2,-2,2,-1
2010 data U,4
2020 data 0,2,1,0,1,1,1,2
2030 data 2,0,0,1,1,1,2,1
2040 data 0,1,1,0,2,0,2,1
2050 data 1,0,0,1,0,2,1,2
2060 data F,8
2070 data 0,1,1,-1,1,0,2,0
2080 data 1,-1,2,-1,1,0,1,1
2090 data 1,-1,1,0,1,1,2,1
2100 data 1,-1,1,0,2,0,2,1
2110 data 0,1,1,1,1,2,2,1
2120 data 1,0,1,1,2,1,1,2
2130 data 1,0,1,1,2,-1,2,0
2140 data 1,-2,1,-1,2,-1,1,0
2150 data L,8
2160 data 1,0,2,0,3,0,3,1
2170 data 0,1,0,2,0,3,1,3
2180 data 1,-3,1,-2,1,-1,1,0
2190 data 1,0,2,0,3,0,3,-1
2200 data 1,0,2,0,3,0,0,1
2210 data 0,1,0,2,0,3,1,0
2220 data 0,1,1,1,2,1,3,1
2230 data 1,0,1,1,1,2,1,3
2240 data Y,8
2250 data 0,1,0,2,0,3,1,1
2260 data 1,0,2,0,3,0,1,1
2270 data 1,-1,1,0,1,1,1,2
2280 data 1,-1,1,0,2,0,3,0
2290 data 0,1,0,2,0,3,1,2
2300 data 1,0,2,0,3,0,2,1
2310 data 1,-2,1,-1,1,0,1,1
2320 data 1,0,2,0,3,0,2,-1
2330 data Z,4
2340 data 0,1,1,1,2,1,2,2
2350 data 1,0,1,1,1,2,2,2
2360 data 1,-2,1,-1,1,0,2,-2
2370 data 2,-1,1,0,2,0,0,1
2380 data P,8
2390 data 0,1,1,0,1,1,2,0
2400 data 1,0,0,1,1,1,0,2
2410 data 0,1,1,0,1,1,1,2
2420 data 1,0,0,1,1,1,2,1
2430 data 1,-1,1,0,2,-1,2,0
2440 data 1,-1,1,0,0,1,1,1
2450 data 0,1,0,2,1,1,1,2
2460 data 1,0,2,0,1,1,2,1
2470 data R,8
2480 data 0,1,0,2,1,2,1,3
2490 data 1,0,2,0,2,1,3,1
2500 data 1,-1,1,0,2,-1,3,-1
2510 data 1,-1,1,0,0,1,0,2
2520 data 0,1,1,1,1,2,1,3
2530 data 1,0,1,1,2,1,3,1
2540 data 1,0,2,-1,2,0,3,-1
2550 data 1,-2,1,-1,1,0,0,1
2560 data A,0