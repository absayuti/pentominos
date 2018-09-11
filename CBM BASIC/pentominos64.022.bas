!------------------------------------------------------------------------------
!- Pentominos 0.22 (for Commodore 64)
!-      Adding backgound 'graphic'
!-      Adding a timer. Repostioning the container/box
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
1000 print chr$(142) "{clear}{down*4}{right*10}p e n t o m i n o s"
1010 print "{down}{right*14}";
1020 poke 53280,0: poke 53281,0
1030 hm$ = "{home}{right*4}{down*4}"
1040 v$ = "{down*13}"
1050 h$ = "{right*23}"
1060 c$ = "{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}"
1070 dim pc$(13)
1080 for i=0 to 12
1090     pc$(i) = mid$(c$,i+1,1)
1100 next i
1110 dim x(63,4), y(63,4), p(64)
1120 dim p$(13)         :rem names of the pieces
1130 dim t(13)          :rem which rotation is currently being tried for piece X
1140 dim s(13)          :rem starting rotation for piece X
1150 dim b(6,20)        :rem board contents
1160 dim x1(5),y1(5), u(12)
1170 dim x2(12), y2(12) :rem starting square where a piece has been placed
1180 read p$,n
1190     if n=0 goto 1320
1200     t = t+1
1210     p$(t) = p$
1220     s(t) = v+1
1230     for j = v+1 to v+n
1240         p(j) = t
1250         for k=0 to 3
1260             read x(j,k), y(j,k)
1270         next k
1280     next j
1290     v = v+n
1300     print p$;
1310 goto 1180
!------------------------------------------------------------------------------
!-   Get user input
1320 print "{home}";left$(v$,10); :print"choose: {down}"
1330 for j=3 to 6:print j;"by";60/j;"{down}": next j
1340 input "select 3 thru 6";w1
1350 if w1<3 or w1>6 or w1<>int(w1) goto 1320
1360 w2=60/w1
!------------------------------------------------------------------------------
!-   Clear screen, print background
1370 print "{clear}{dark gray}"
1380 rem goto 1450
1390 for j = 1 to 20
1400     if j/2<>int(j/2) then ch$ = "{cm z}{cm s}" :goto 1420
1410     ch$ = "{cm s}{cm z}"
1420     for i = 1 to 19
1430         print ch$;
1440     next i
1450     print
1460 next j
1465 print "{home}{down*12}
1470 PRINT "{right}{cm a}{096}{105}{cm a}{096}{cm s}{cm a}{096}{105}{096}{cm r}{096}{117}{096}{105}{cm a}{105} {117}{cm s}{cm r}{cm a}{096}{105}{117}{096}{105}{117}{096}{105} {117}{096}{105}{098}  "
1480 PRINT "{right}{098} {098}{098}  {098} {098} {098} {098} {098}{098}{098} {098}{098}{098}{098} {098}{098} {098}{098}   {098} {098}{098} {098}"
1490 PRINT "{right}{098} {098}{098}  {098} {098} {098} {098} {098}{098}{106}{cm r}{107}{098}{098}{098} {098}{098} {098}{098}   {098}  {098} {098}"
1500 PRINT "{right}{cm q}{096}{107}{cm q}{096} {098} {098} {098} {098} {098}{098} {098} {098}{098}{098} {098}{098} {098}{106}{096}{105} {cm q}{096}{105}{106}{096}{123}"
1510 PRINT "{right}{098}  {098}  {098} {098} {098} {098} {098}{098} {098} {098}{098}{098} {098}{098} {098}  {098} {098} {098}  {098}"
1520 PRINT "{right}{098}  {098}  {098} {098} {098} {098} {098}{098}   {098}{098}{098} {098}{098} {098}  {098} {098} {098}  {098}"
1530 PRINT "{right}{cm e}  {cm z}{096}{cm x}{cm e} {cm e} {cm e} {106}{096}{107}{cm e}   {cm e}{cm e}{cm e} {cm e}{106}{096}{107}{106}{096}{107} {106}{096}{107}  {098}"
!-   Place container
1560 print "{home}{down*4}{right*4}{cm a}";
1570 for i=1 to w2 :print"{sh asterisk}"; :next
1580 print "{cm s}"
1590 for i=1 to w1
1600     print "{right*4}B";
1610     for j=1 to w2 :print" "; :next
1620     print "B"
1630 next i
1640 print "{right*4}{cm z}";
1650 for i=1 to w2 :print"{sh asterisk}"; :next
1660 print "{cm x}"
!------------------------------------------------------------------------------
!-   Main routine
1670 rem find new space to fill
1680 time$ = "000000"
1690 gosub 2310 :p = j  :rem get next unused piece
1700 gosub 2340         :rem get next empty spot
1710 if x1>w2 goto 1980 :rem if exceed container width, all filled up
1720 rem get a new piece
1730 t(p) = s(p)
1740 print "{home}";p$(p);"{down*11}"
1750 rem try fitting piece
1760 c$ = "Q" :x1(0)=x1 :y1(0)=y1
1770 for j = 1 to 4
1780     x = x(t(p),j-1)+x1
1790     y = y(t(p),j-1)+y1
1800     x1(j) = x
1810     y1(j) = y
1820     if x<1 or y<1 or x>w2 or y>w1 goto 2220 :rem rotate the piece
1830     if b(y,x)<>0 goto 2220
1840 next j
1850 rem it fits - put piece in place
1860 b=p
1870 for j=0 to 4
1880     x = x1(j)
1890     y = y1(j)
1900     gosub 2400     :rem place the piece
1910 next j
1920 x2(p) = x1
1930 y2(p)=y1
1940 p1=p1+1
1950 u(p1)=p
1960 goto 1690
!------------------------------------------------------------------------------
1970 rem board filled
1980 t$ = time$
1990 print "{home}{white}solved in ";
2000 print left$(t$,2);":";mid$(t$,3,2);":";right$(t$,2);"{down*20}" ;
2010 end
!------------------------------------------------------------------------------
2020 rem undraw last one
2030 p=u(p1)
2040 u(p1)=0
2050 p1 = p1-1
2060 if p1<0 then print"that's all" :end
2070 b=0
2080 x=x2(p)
2090 y=y2(p)
2100 c$=" "
2110 gosub 2400         :rem place the piece
2120 x1=x
2130 y1=y
2140 for j=1 to 4
2150     x=x(t(p),j-1)+x1
2160     y=y(t(p),j-1)+y1
2170     x1(j)=x
2180     y1(j)=y
2190     gosub 2400     :rem place the piece
2200 next j
2210 rem rotate the piece
2220 t(p)=t(p)+1
2230 if p(t(p))=p goto 1760
2240 rem give up on piece
2250 t(p)=0
2260 rem look for new piece
2270 p=p+1
2280 if p>12 goto 2030
2290 if t(p)<>0 goto 2270
2300 goto 1730
!------------------------------------------------------------------------------
!-   Find next unused piece
2310 for j=1 to 12
2320     if t(j)<>0 then next j
2330 return
!------------------------------------------------------------------------------
!-   Find next empty spot
2340 for x1=1 to w2
2350     for y1=1 to w1
2360          if b(y1,x1)=0 goto 2390
2370     next y1
2380 next x1
2390 return
!------------------------------------------------------------------------------
!-   Place the piece
2400 print hm$;left$(v$,y);left$(h$,x);pc$(p1);c$
2410 b(y,x)=b
2420 return
!------------------------------------------------------------------------------
!- The pentomino pieces
!-
!- Piece I      0OOOO   0
!-                      O
!-                      O
!-                      O
!-                      O
2430 data I,2
2440 data 0,1,0,2,0,3,0,4
2450 data 1,0,2,0,3,0,4,0
!-
!- Piece X       0
!-              OOO
!-               O
2460 data X,1
2470 data 1,-1,1,0,2,0,1,1
!-
!- Piece V      0OO     0
!-              O       O
!-              O       OOO
2480 data V,4
2490 data 0,1,0,2,1,0,2,0
2500 data 0,1,0,2,1,2,2,2
2510 data 1,0,2,0,2,1,2,2
2520 data 1,0,2,0,2,-1,2,-2
!-
!- Piece T      0       0OO      O
!-              OOO      O       O
!-              O        O      0OO
2530 data T,4
2540 data 0,1,0,2,1,1,2,1
2550 data 1,0,1,1,2,0,1,2
2560 data 1,0,2,0,1,-1,1,-2
2570 data 2,-1,2,0,2,1,1,0
2580 data W,4
2590 data 0,1,1,1,1,2,2,2
2600 data 1,0,1,1,2,1,2,2
2610 data 0,1,1,-1,1,0,2,-1
2620 data 1,-1,1,0,2,-2,2,-1
2630 data U,4
2640 data 0,2,1,0,1,1,1,2
2650 data 2,0,0,1,1,1,2,1
2660 data 0,1,1,0,2,0,2,1
2670 data 1,0,0,1,0,2,1,2
2680 data F,8
2690 data 0,1,1,-1,1,0,2,0
2700 data 1,-1,2,-1,1,0,1,1
2710 data 1,-1,1,0,1,1,2,1
2720 data 1,-1,1,0,2,0,2,1
2730 data 0,1,1,1,1,2,2,1
2740 data 1,0,1,1,2,1,1,2
2750 data 1,0,1,1,2,-1,2,0
2760 data 1,-2,1,-1,2,-1,1,0
2770 data L,8
2780 data 1,0,2,0,3,0,3,1
2790 data 0,1,0,2,0,3,1,3
2800 data 1,-3,1,-2,1,-1,1,0
2810 data 1,0,2,0,3,0,3,-1
2820 data 1,0,2,0,3,0,0,1
2830 data 0,1,0,2,0,3,1,0
2840 data 0,1,1,1,2,1,3,1
2850 data 1,0,1,1,1,2,1,3
2860 data Y,8
2870 data 0,1,0,2,0,3,1,1
2880 data 1,0,2,0,3,0,1,1
2890 data 1,-1,1,0,1,1,1,2
2900 data 1,-1,1,0,2,0,3,0
2910 data 0,1,0,2,0,3,1,2
2920 data 1,0,2,0,3,0,2,1
2930 data 1,-2,1,-1,1,0,1,1
2940 data 1,0,2,0,3,0,2,-1
2950 data Z,4
2960 data 0,1,1,1,2,1,2,2
2970 data 1,0,1,1,1,2,2,2
2980 data 1,-2,1,-1,1,0,2,-2
2990 data 2,-1,1,0,2,0,0,1
3000 data P,8
3010 data 0,1,1,0,1,1,2,0
3020 data 1,0,0,1,1,1,0,2
3030 data 0,1,1,0,1,1,1,2
3040 data 1,0,0,1,1,1,2,1
3050 data 1,-1,1,0,2,-1,2,0
3060 data 1,-1,1,0,0,1,1,1
3070 data 0,1,0,2,1,1,1,2
3080 data 1,0,2,0,1,1,2,1
3090 data R,8
3100 data 0,1,0,2,1,2,1,3
3110 data 1,0,2,0,2,1,3,1
3120 data 1,-1,1,0,2,-1,3,-1
3130 data 1,-1,1,0,0,1,0,2
3140 data 0,1,1,1,1,2,1,3
3150 data 1,0,1,1,2,1,3,1
3160 data 1,0,2,-1,2,0,3,-1
3170 data 1,-2,1,-1,1,0,0,1
3180 data A,0