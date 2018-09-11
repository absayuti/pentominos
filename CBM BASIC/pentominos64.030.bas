!------------------------------------------------------------------------------
!- Pentominos 64
!-      A puzzle-solving program for the Commodore 64
!-
!- 0.30 18 oct 015
!-      Trying the use of "doubleprint64"
!-      The headliner64 was very hard to integrate into current program
!- 0.23
!-      Try squares instead of cicles
!- 0.22
!-      Adding backgound 'graphic'
!-      Adding a timer. Repostioning the container/box
!- 0.21
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
100 gosub 1530 :rem setup big charset MC routine
110 print "{clear}{down*4}{right*4}p e n t o m i n o s"
120 print "{down}{right*14}";
130 poke 53280,0: poke 53281,0
140 hm$ = "{home}{right*2}{down*4}"
150 v$ = "{down*13}"
160 h$ = "{right*23}"
170 c$ = "{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}"
180 dim pc$(13)
190 for i=0 to 12
200     pc$(i) = mid$(c$,i+1,1)
210 next i
220 dim x(63,4), y(63,4), p(64)
230 dim p$(13)         :rem names of the pieces
240 dim t(13)          :rem which rotation is currently being tried for piece X
250 dim s(13)          :rem starting rotation for piece X
260 dim b(6,20)        :rem board contents
270 dim x1(5),y1(5), u(12)
280 dim x2(12), y2(12) :rem starting square where a piece has been placed
290 read p$,n
300     if n=0 goto 430
310     t = t+1
320     p$(t) = p$
330     s(t) = v+1
340     for j = v+1 to v+n
350         p(j) = t
360         for k=0 to 3
370             read x(j,k), y(j,k)
380         next k
390     next j
400     v = v+n
410     print p$;
420 goto 290
!------------------------------------------------------------------------------
!-   Get user input
430 print "{home}";left$(v$,10); :print"choose: {down}"
440 for j=3 to 6:print j;"by";60/j;"{down}": next j
450 input "select 3 thru 6";w1
460 if w1<3 or w1>6 or w1<>int(w1) goto 430
470 w2=60/w1
!------------------------------------------------------------------------------
!-   Clear screen, print background
480 print "{clear}{dark gray}"
490 goto 660 :rem skip the decorations for now...
500 for j = 1 to 20
510     if j/2<>int(j/2) then ch$ = "{cm z}{cm s}" :goto 530
520     ch$ = "{cm s}{cm z}"
530     for i = 1 to 19
540         print ch$;
550     next i
560     print
570 next j
580 print "{home}{down*12}
590 PRINT "{right}{cm a}{096}{105}{cm a}{096}{cm s}{cm a}{096}{105}{096}{cm r}{096}{117}{096}{105}{cm a}{105} {117}{cm s}{cm r}{cm a}{096}{105}{117}{096}{105}{117}{096}{105} {117}{096}{105}{098}  "
600 PRINT "{right}{098} {098}{098}  {098} {098} {098} {098} {098}{098}{098} {098}{098}{098}{098} {098}{098} {098}{098}   {098} {098}{098} {098}"
610 PRINT "{right}{098} {098}{098}  {098} {098} {098} {098} {098}{098}{106}{cm r}{107}{098}{098}{098} {098}{098} {098}{098}   {098}  {098} {098}"
620 PRINT "{right}{cm q}{096}{107}{cm q}{096} {098} {098} {098} {098} {098}{098} {098} {098}{098}{098} {098}{098} {098}{106}{096}{105} {cm q}{096}{105}{106}{096}{123}"
630 PRINT "{right}{098}  {098}  {098} {098} {098} {098} {098}{098} {098} {098}{098}{098} {098}{098} {098}  {098} {098} {098}  {098}"
640 PRINT "{right}{098}  {098}  {098} {098} {098} {098} {098}{098}   {098}{098}{098} {098}{098} {098}  {098} {098} {098}  {098}"
650 PRINT "{right}{cm e}  {cm z}{096}{cm x}{cm e} {cm e} {cm e} {106}{096}{107}{cm e}   {cm e}{cm e}{cm e} {cm e}{106}{096}{107}{106}{096}{107} {106}{096}{107}  {098}"
!-   Place container
660 print "{home}{down*4}{right*2}{cm a}";
670 for i=1 to w2 :print"{sh asterisk}"; :next
680 print "{cm s}"
690 for i=1 to w1
700     print "{right*2}B";
710     for j=1 to w2 :print"  "; :next
720     print "B"
730 next i
740 print "{right*2}{cm z}";
750 for i=1 to w2 :print"{sh asterisk}"; :next
760 print "{cm x}"
!------------------------------------------------------------------------------
!-   Main routine
770 rem find new space to fill
780 time$ = "000000"
790 gosub 1410 :p = j  :rem get next unused piece
800 gosub 1440         :rem get next empty spot
810 if x1>w2 goto 1080 :rem if exceed container width, all filled up
820 rem get a new piece
830 t(p) = s(p)
840 print "{home}";p$(p);"{down*11}"
850 rem try fitting piece
860 c$ = "Q{reverse on}Q{reverse off}" :x1(0)=x1 :y1(0)=y1
870 for j = 1 to 4
880     x = x(t(p),j-1)+x1
890     y = y(t(p),j-1)+y1
900     x1(j) = x
910     y1(j) = y
920     if x<1 or y<1 or x>w2 or y>w1 goto 1320 :rem rotate the piece
930     if b(y,x)<>0 goto 1320
940 next j
950 rem it fits - put piece in place
960 b=p
970 for j=0 to 4
980     x = x1(j)*2
990     y = y1(j)
1000     gosub 1500     :rem place the piece
1010 next j
1020 x2(p) = x1
1030 y2(p)=y1
1040 p1=p1+1
1050 u(p1)=p
1060 goto 790
!------------------------------------------------------------------------------
1070 rem board filled
1080 t$ = time$
1090 print "{home}{white}solved in ";
1100 print left$(t$,2);":";mid$(t$,3,2);":";right$(t$,2);"{down*20}" ;
1110 end
!------------------------------------------------------------------------------
1120 rem undraw last one
1130 p=u(p1)
1140 u(p1)=0
1150 p1 = p1-1
1160 if p1<0 then print"that's all" :end
1170 b=0
1180 x=x2(p)
1190 y=y2(p)
1200 c$="  "
1210 gosub 1500         :rem place the piece
1220 x1=x
1230 y1=y
1240 for j=1 to 4
1250     x=x(t(p),j-1)+x1
1260     y=y(t(p),j-1)+y1
1270     x1(j)=x
1280     y1(j)=y
1290     gosub 1500     :rem place the piece
1300 next j
1310 rem rotate the piece
1320 t(p)=t(p)+1
1330 if p(t(p))=p goto 860
1340 rem give up on piece
1350 t(p)=0
1360 rem look for new piece
1370 p=p+1
1380 if p>12 goto 1130
1390 if t(p)<>0 goto 1370
1400 goto 830
!------------------------------------------------------------------------------
!-   Find next unused piece
1410 for j=1 to 12
1420     if t(j)<>0 then next j
1430 return
!------------------------------------------------------------------------------
!-   Find next empty spot
1440 for x1=1 to w2
1450     for y1=1 to w1
1460          if b(y1,x1)=0 goto 1490
1470     next y1
1480 next x1
1490 return
!------------------------------------------------------------------------------
!-   Place the piece
1500 print hm$;left$(v$,y);left$(h$,x*2);pc$(p1);c$
1510 b(y,x)=b
1520 return
!--------------------------------------------------
!- Sunday, 18 October, 2015 10:12:31 AM
!- Import of : DBPRINT64.PRG
!- From Disk : d:\!stuff\programming\cbmprgstudio\doubleprint64.d64
!- Commodore 64
!--------------------------------------------------
!-   COPYRIGHT 1987 COMPUTE! PUBLICATIONS INC. - ALL RIGHTS RESERVED
1530 PRINT"{clear}{space*2}copyright 1987 compute! pub., inc."
1540 PRINTTAB(9)"all rights reserved"
1550 PRINT"{down*2}working.";:POKE53280,0:POKE53281,0
1560 FORX=0TO254:READA:POKEX+49152,A:C=C+A:PRINT".";:NEXT
1570 IFC-32355THENPRINT:PRINT"error in data":END
1580 SYS49152:PRINT"{clear}{blue}sys49152 {yellow}to activate":PRINT"{down}{purple}{space*2}- - - - - - - - - - -"
1590 PRINT"{down}{green}sys49391 {red}to shut off"
1600 return
1610 DATA173,14,220,41,254,141,14,220,165,1
1620 DATA41,251,133,1,169,208,133,252,169,56
1630 DATA133,254,160,0,132,251,132,253,169,0
1640 DATA145,253,177,251,41,128,240,2,169,192
1650 DATA32,159,192,41,64,240,2,169,48,32
1660 DATA159,192,41,32,240,2,169,12,32,159
1670 DATA192,41,16,240,5,169,3,32,159,192
1680 DATA165,254,24,105,4,133,254,169,0,145
1690 DATA253,177,251,41,8,240,2,169,192,32
1700 DATA159,192,41,4,240,2,169,48,32,159
1710 DATA192,41,2,240,2,169,12,32,159,192
1720 DATA41,1,240,5,169,3,32,159,192,165
1730 DATA254,56,233,4,133,254,165,253,24,105
1740 DATA1,133,253,165,254,105,0,133,254,165
1750 DATA251,24,105,1,133,251,165,252,105,0
1760 DATA133,252,201,212,240,10,76,28,192,17
1770 DATA253,145,253,177,251,96,165,1,9,4
1780 DATA133,1,173,14,220,9,1,141,14,220
1790 DATA169,208,141,38,3,169,192,141,39,3
1800 DATA169,30,141,24,208,162,0,169,255,157
1810 DATA0,61,232,224,8,208,246,96,141,238
1820 DATA192,32,202,241,173,238,192,201,33,144
1830 DATA16,169,18,32,202,241,173,238,192,32
1840 DATA202,241,169,146,32,202,241,96,0,169
1850 DATA241,141,39,3,169,202,141,38,3,169
1860 DATA21,141,24,208,96
!------------------------------------------------------------------------------
!- The pentomino pieces
!-
!- Piece I      0OOOO   0
!-                      O
!-                      O
!-                      O
!-                      O
1870 data I,2
1880 data 0,1,0,2,0,3,0,4
1890 data 1,0,2,0,3,0,4,0
!-
!- Piece X       0
!-              OOO
!-               O
1900 data X,1
1910 data 1,-1,1,0,2,0,1,1
!-
!- Piece V      0OO     0
!-              O       O
!-              O       OOO
1920 data V,4
1930 data 0,1,0,2,1,0,2,0
1940 data 0,1,0,2,1,2,2,2
1950 data 1,0,2,0,2,1,2,2
1960 data 1,0,2,0,2,-1,2,-2
!-
!- Piece T      0       0OO      O
!-              OOO      O       O
!-              O        O      0OO
1970 data T,4
1980 data 0,1,0,2,1,1,2,1
1990 data 1,0,1,1,2,0,1,2
2000 data 1,0,2,0,1,-1,1,-2
2010 data 2,-1,2,0,2,1,1,0
2020 data W,4
2030 data 0,1,1,1,1,2,2,2
2040 data 1,0,1,1,2,1,2,2
2050 data 0,1,1,-1,1,0,2,-1
2060 data 1,-1,1,0,2,-2,2,-1
2070 data U,4
2080 data 0,2,1,0,1,1,1,2
2090 data 2,0,0,1,1,1,2,1
2100 data 0,1,1,0,2,0,2,1
2110 data 1,0,0,1,0,2,1,2
2120 data F,8
2130 data 0,1,1,-1,1,0,2,0
2140 data 1,-1,2,-1,1,0,1,1
2150 data 1,-1,1,0,1,1,2,1
2160 data 1,-1,1,0,2,0,2,1
2170 data 0,1,1,1,1,2,2,1
2180 data 1,0,1,1,2,1,1,2
2190 data 1,0,1,1,2,-1,2,0
2200 data 1,-2,1,-1,2,-1,1,0
2210 data L,8
2220 data 1,0,2,0,3,0,3,1
2230 data 0,1,0,2,0,3,1,3
2240 data 1,-3,1,-2,1,-1,1,0
2250 data 1,0,2,0,3,0,3,-1
2260 data 1,0,2,0,3,0,0,1
2270 data 0,1,0,2,0,3,1,0
2280 data 0,1,1,1,2,1,3,1
2290 data 1,0,1,1,1,2,1,3
2300 data Y,8
2310 data 0,1,0,2,0,3,1,1
2320 data 1,0,2,0,3,0,1,1
2330 data 1,-1,1,0,1,1,1,2
2340 data 1,-1,1,0,2,0,3,0
2350 data 0,1,0,2,0,3,1,2
2360 data 1,0,2,0,3,0,2,1
2370 data 1,-2,1,-1,1,0,1,1
2380 data 1,0,2,0,3,0,2,-1
2390 data Z,4
2400 data 0,1,1,1,2,1,2,2
2410 data 1,0,1,1,1,2,2,2
2420 data 1,-2,1,-1,1,0,2,-2
2430 data 2,-1,1,0,2,0,0,1
2440 data P,8
2450 data 0,1,1,0,1,1,2,0
2460 data 1,0,0,1,1,1,0,2
2470 data 0,1,1,0,1,1,1,2
2480 data 1,0,0,1,1,1,2,1
2490 data 1,-1,1,0,2,-1,2,0
2500 data 1,-1,1,0,0,1,1,1
2510 data 0,1,0,2,1,1,1,2
2520 data 1,0,2,0,1,1,2,1
2530 data R,8
2540 data 0,1,0,2,1,2,1,3
2550 data 1,0,2,0,2,1,3,1
2560 data 1,-1,1,0,2,-1,3,-1
2570 data 1,-1,1,0,0,1,0,2
2580 data 0,1,1,1,1,2,1,3
2590 data 1,0,1,1,2,1,3,1
2600 data 1,0,2,-1,2,0,3,-1
2610 data 1,-2,1,-1,1,0,0,1
2620 data A,0