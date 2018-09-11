!------------------------------------------------------------------------------
!- Pentominos 0.21 (for Commodore 64)
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
1000 print chr$(142) "{clear}{right*5}pentominos{down}"
1010 poke 53280,0: poke 53281,0
1020 v$ = "{home}{down*13}"
1030 h$ = "{right*23}"
1040 c$ = "{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}{cyan}{purple}{green}{blue}{yellow}{white}{pink}"
1050 dim pc$(13)
1060 for i=0 to 12
1070     pc$(i) = mid$(c$,i+1,1)
1080 next i
1090 dim x(63,4), y(63,4), p(64)
1100 dim p$(13)         :rem names of the pieces
1110 dim t(13)          :rem which rotation is currently being tried for piece X
1120 dim s(13)          :rem starting rotation for piece X
1130 dim b(6,20)        :rem board contents
1140 dim x1(5),y1(5), u(12)
1150 dim x2(12), y2(12) :rem starting square where a piece has been placed
1160 read p$,n
1170     if n=0 goto 1300
1180     t = t+1
1190     p$(t) = p$
1200     s(t) = v+1
1210     for j = v+1 to v+n
1220         p(j) = t
1230         for k=0 to 3
1240             read x(j,k), y(j,k)
1250         next k
1260     next j
1270     v = v+n
1280     print p$;
1290 goto 1160
!------------------------------------------------------------------------------
!-   Get user input
1300 printleft$(v$,5);: print"choose: {down}"
1310 for j=3 to 6:print j;"by";60/j;"{down}": next j
1320 input "select 3 thru 6";w1
1330 if w1<3 or w1>6 or w1<>int(w1) goto 1300
1340 w2=60/w1
!------------------------------------------------------------------------------
!-   Place container
1350 print "{clear}{gray}"
1360 print "{cm a}";
1362 for i=1 to w2 :print"{sh asterisk}"; :next
1364 print "{cm s}"
1370 for i=1 to w1
1375     print "B";
1380     for j=1 to w2 :print" "; :next
1382     print "B"
1390 next
1392 print "{cm z}";
1395 for i=1 to w2 :print"{sh asterisk}"; :next
1400 print "{cm x}"
!------------------------------------------------------------------------------
!-   Main routine
1410 rem find new space to fill
1420 gosub 2020 :p = j  :rem get next unused piece
1430 gosub 2050         :rem get next empty spot
1440 if x1>w2 goto 1710 :rem if exceed container width, all filled up
1450 rem get a new piece
1460 t(p) = s(p)
1470 print "{home}";p$(p);"{down*11}"
1480 rem try fitting piece
1490 c$ = "Q" :x1(0)=x1 :y1(0)=y1
1500 for j = 1 to 4
1510     x = x(t(p),j-1)+x1
1520     y = y(t(p),j-1)+y1
1530     x1(j) = x
1540     y1(j) = y
1550     if x<1 or y<1 or x>w2 or y>w1 goto 1930 :rem rotate the piece
1560     if b(y,x)<>0 goto 1930
1570 next j
1580 rem it fits - put piece in place
1590 b=p
1600 for j=0 to 4
1610     x = x1(j)
1620     y = y1(j)
1630     gosub 2110     :rem place the piece
1640 next j
1650 x2(p) = x1
1660 y2(p)=y1
1670 p1=p1+1
1680 u(p1)=p
1690 goto 1420
!------------------------------------------------------------------------------
1700 rem board filled
1710 print "{home}{white}solution{down*10}" ;
1720 end
!------------------------------------------------------------------------------
1730 rem undraw last one
1740 p=u(p1)
1750 u(p1)=0
1760 p1 = p1-1
1770 if p1<0 then print"that's all" :end
1780 b=0
1790 x=x2(p)
1800 y=y2(p)
1810 c$=" "
1820 gosub 2110         :rem place the piece
1830 x1=x
1840 y1=y
1850 for j=1 to 4
1860     x=x(t(p),j-1)+x1
1870     y=y(t(p),j-1)+y1
1880     x1(j)=x
1890     y1(j)=y
1900     gosub 2110     :rem place the piece
1910 next j
1920 rem rotate the piece
1930 t(p)=t(p)+1
1940 if p(t(p))=p goto 1490
1950 rem give up on piece
1960 t(p)=0
1970 rem look for new piece
1980 p=p+1
1990 if p>12 goto 1740
2000 if t(p)<>0 goto 1980
2010 goto 1460
!------------------------------------------------------------------------------
!-   Find next unused piece
2020 for j=1 to 12
2030     if t(j)<>0 then next j
2040 return
!------------------------------------------------------------------------------
!-   Find next empty spot
2050 for x1=1 to w2
2060     for y1=1 to w1
2070          if b(y1,x1)=0 goto 2100
2080     next y1
2090 next x1
2100 return
!------------------------------------------------------------------------------
!-   Place the piece
2110 print left$(v$,y+2);left$(h$,x);pc$(p1);c$
2120 b(y,x)=b
2130 return
!------------------------------------------------------------------------------
!- The pentomino pieces
!-
!- Piece I      0OOOO   0
!-                      O
!-                      O
!-                      O
!-                      O
2140 data I,2
2150 data 0,1,0,2,0,3,0,4
2160 data 1,0,2,0,3,0,4,0
!-
!- Piece X       0
!-              OOO
!-               O
2170 data X,1
2180 data 1,-1,1,0,2,0,1,1
!-
!- Piece V      0OO     0
!-              O       O
!-              O       OOO
2190 data V,4
2200 data 0,1,0,2,1,0,2,0
2210 data 0,1,0,2,1,2,2,2
2220 data 1,0,2,0,2,1,2,2
2230 data 1,0,2,0,2,-1,2,-2
!-
!- Piece T      0       0OO      O
!-              OOO      O       O
!-              O        O      0OO
2240 data T,4
2250 data 0,1,0,2,1,1,2,1
2260 data 1,0,1,1,2,0,1,2
2270 data 1,0,2,0,1,-1,1,-2
2280 data 2,-1,2,0,2,1,1,0
2290 data W,4
2300 data 0,1,1,1,1,2,2,2
2310 data 1,0,1,1,2,1,2,2
2320 data 0,1,1,-1,1,0,2,-1
2330 data 1,-1,1,0,2,-2,2,-1
2340 data U,4
2350 data 0,2,1,0,1,1,1,2
2360 data 2,0,0,1,1,1,2,1
2370 data 0,1,1,0,2,0,2,1
2380 data 1,0,0,1,0,2,1,2
2390 data F,8
2400 data 0,1,1,-1,1,0,2,0
2410 data 1,-1,2,-1,1,0,1,1
2420 data 1,-1,1,0,1,1,2,1
2430 data 1,-1,1,0,2,0,2,1
2440 data 0,1,1,1,1,2,2,1
2450 data 1,0,1,1,2,1,1,2
2460 data 1,0,1,1,2,-1,2,0
2470 data 1,-2,1,-1,2,-1,1,0
2480 data L,8
2490 data 1,0,2,0,3,0,3,1
2500 data 0,1,0,2,0,3,1,3
2510 data 1,-3,1,-2,1,-1,1,0
2520 data 1,0,2,0,3,0,3,-1
2530 data 1,0,2,0,3,0,0,1
2540 data 0,1,0,2,0,3,1,0
2550 data 0,1,1,1,2,1,3,1
2560 data 1,0,1,1,1,2,1,3
2570 data Y,8
2580 data 0,1,0,2,0,3,1,1
2590 data 1,0,2,0,3,0,1,1
2600 data 1,-1,1,0,1,1,1,2
2610 data 1,-1,1,0,2,0,3,0
2620 data 0,1,0,2,0,3,1,2
2630 data 1,0,2,0,3,0,2,1
2640 data 1,-2,1,-1,1,0,1,1
2650 data 1,0,2,0,3,0,2,-1
2660 data Z,4
2670 data 0,1,1,1,2,1,2,2
2680 data 1,0,1,1,1,2,2,2
2690 data 1,-2,1,-1,1,0,2,-2
2700 data 2,-1,1,0,2,0,0,1
2710 data P,8
2720 data 0,1,1,0,1,1,2,0
2730 data 1,0,0,1,1,1,0,2
2740 data 0,1,1,0,1,1,1,2
2750 data 1,0,0,1,1,1,2,1
2760 data 1,-1,1,0,2,-1,2,0
2770 data 1,-1,1,0,0,1,1,1
2780 data 0,1,0,2,1,1,1,2
2790 data 1,0,2,0,1,1,2,1
2800 data R,8
2810 data 0,1,0,2,1,2,1,3
2820 data 1,0,2,0,2,1,3,1
2830 data 1,-1,1,0,2,-1,3,-1
2840 data 1,-1,1,0,0,1,0,2
2850 data 0,1,1,1,1,2,1,3
2860 data 1,0,1,1,2,1,3,1
2870 data 1,0,2,-1,2,0,3,-1
2880 data 1,-2,1,-1,1,0,0,1
2890 data A,0