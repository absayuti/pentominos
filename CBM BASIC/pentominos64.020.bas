!------------------------------------------------------------------------------
!- Pentominos 0.20
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
1010 v$ = "{home}{down*13}"
1020 h$ = "{right*23}"
1030 dim x(63,4), y(63,4), p(64)
1040 dim p$(13)         :rem names of the pieces
1050 dim t(13)          :rem which rotation is currently being tried for piece X
1060 dim s(13)          :rem starting rotation for piece X
1070 dim b(6,20)        :rem board contents
1080 dim x1(5),y1(5), u(12)
1090 dim x2(12), y2(12) :rem starting square where a piece has been placed
1100 read p$,n
1110     if n=0 goto 1240
1120     t = t+1
1130     p$(t) = p$
1140     s(t) = v+1
1150     for j = v+1 to v+n
1160         p(j) = t
1170         for k=0 to 3
1180             read x(j,k), y(j,k)
1190         next k
1200     next j
1210     v = v+n
1220     print p$;
1230 goto 1100
!------------------------------------------------------------------------------
!-   Get user input
1240 printleft$(v$,5);: print"choose: {down}"
1250 for j=3 to 6:print j;"by";60/j;"{down}": next j
1260 input "select 3 thru 6";w1
1270 if w1<3 or w1>6 or w1<>int(w1) goto 1240
1280 w2=60/w1
1290 print "{clear}"
!------------------------------------------------------------------------------
!-   Main routine
1300 rem find new space to fill
1310 gosub 1900 :p = j  :rem get next unused piece 
1320 gosub 1930         :rem get next empty spot
1322 if x1>w2 goto 1590 :rem if exceed container width, all filled up
1330 rem get a new piece
1340 t(p) = s(p)
1350 print "{home}";p$(p);"{down*11}"
1360 rem try fitting piece
1370 c$ = p$(p): x1(0)=x1: y1(0)=y1
1380 for j = 1 to 4
1390     x = x(t(p),j-1)+x1
1400     y = y(t(p),j-1)+y1
1410     x1(j) = x
1420     y1(j) = y
1430     if x<1 or y<1 or x>w2 or y>w1 goto 1810 :rem rotate the piece
1440     if b(y,x)<>0 goto 1810
1450 next j
1460 rem it fits - put piece in place
1470 b=p
1480 for j=0 to 4
1490     x = x1(j)
1500     y = y1(j)
1510     gosub 1990     :rem place the piece
1520 next j
1530 x2(p) = x1
1540 y2(p)=y1
1550 p1=p1+1
1560 u(p1)=p
1570 goto 1310
!------------------------------------------------------------------------------
1580 rem board filled
1590 print "{home}  solution" ;
1600 end
!------------------------------------------------------------------------------
1610 rem undraw last one
1620 p=u(p1)
1630 u(p1)=0
1640 p1 = p1-1
1650 if p1<0 then print"that's all" :end
1660 b=0
1670 x=x2(p)
1680 y=y2(p)
1690 c$=" "
1700 gosub 1990         :rem place the piece
1710 x1=x
1720 y1=y
1730 for j=1 to 4
1740     x=x(t(p),j-1)+x1
1750     y=y(t(p),j-1)+y1
1760     x1(j)=x
1770     y1(j)=y
1780     gosub 1990     :rem place the piece
1790 next j
1800 rem rotate the piece
1810 t(p)=t(p)+1
1820 if p(t(p))=p goto 1370
1830 rem give up on piece
1840 t(p)=0
1850 rem look for new piece
1860 p=p+1
1870 if p>12 goto 1620
1880 if t(p)<>0 goto 1860
1890 goto 1340
!------------------------------------------------------------------------------
!-   Find next unused piece
1900 for j=1 to 12
1910     if t(j)<>0 then next j
1920 return
!------------------------------------------------------------------------------
!-   Find next empty spot
1930 for x1=1 to w2
1940     for y1=1 to w1
1950          if b(y1,x1)=0 goto 1980
1960     next y1
1970 next x1
1980 return
!------------------------------------------------------------------------------
!-   Place the piece
1990 print left$(v$,y+2);left$(h$,x);c$
2000 b(y,x)=b
2010 return
!------------------------------------------------------------------------------
!- The pentomino pieces
!-
!- Piece I      0OOOO   0
!-                      O
!-                      O
!-                      O
!-                      O
2020 data I,2
2030 data 0,1,0,2,0,3,0,4
2040 data 1,0,2,0,3,0,4,0
!-
!- Piece X       0
!-              OOO
!-               O
2050 data X,1
2060 data 1,-1,1,0,2,0,1,1
!-
!- Piece V      0OO     0
!-              O       O
!-              O       OOO
2070 data V,4
2080 data 0,1,0,2,1,0,2,0
2090 data 0,1,0,2,1,2,2,2
2100 data 1,0,2,0,2,1,2,2
2110 data 1,0,2,0,2,-1,2,-2
!-
!- Piece T      0       0OO      O
!-              OOO      O       O
!-              O        O      0OO
2120 data T,4
2130 data 0,1,0,2,1,1,2,1
2140 data 1,0,1,1,2,0,1,2
2150 data 1,0,2,0,1,-1,1,-2
2160 data 2,-1,2,0,2,1,1,0
2170 data W,4
2180 data 0,1,1,1,1,2,2,2
2190 data 1,0,1,1,2,1,2,2
2200 data 0,1,1,-1,1,0,2,-1
2210 data 1,-1,1,0,2,-2,2,-1
2220 data U,4
2230 data 0,2,1,0,1,1,1,2
2240 data 2,0,0,1,1,1,2,1
2250 data 0,1,1,0,2,0,2,1
2260 data 1,0,0,1,0,2,1,2
2270 data F,8
2280 data 0,1,1,-1,1,0,2,0
2290 data 1,-1,2,-1,1,0,1,1
2300 data 1,-1,1,0,1,1,2,1
2310 data 1,-1,1,0,2,0,2,1
2320 data 0,1,1,1,1,2,2,1
2330 data 1,0,1,1,2,1,1,2
2340 data 1,0,1,1,2,-1,2,0
2350 data 1,-2,1,-1,2,-1,1,0
2360 data L,8
2370 data 1,0,2,0,3,0,3,1
2380 data 0,1,0,2,0,3,1,3
2390 data 1,-3,1,-2,1,-1,1,0
2400 data 1,0,2,0,3,0,3,-1
2410 data 1,0,2,0,3,0,0,1
2420 data 0,1,0,2,0,3,1,0
2430 data 0,1,1,1,2,1,3,1
2440 data 1,0,1,1,1,2,1,3
2450 data Y,8
2460 data 0,1,0,2,0,3,1,1
2470 data 1,0,2,0,3,0,1,1
2480 data 1,-1,1,0,1,1,1,2
2490 data 1,-1,1,0,2,0,3,0
2500 data 0,1,0,2,0,3,1,2
2510 data 1,0,2,0,3,0,2,1
2520 data 1,-2,1,-1,1,0,1,1
2530 data 1,0,2,0,3,0,2,-1
2540 data Z,4
2550 data 0,1,1,1,2,1,2,2
2560 data 1,0,1,1,1,2,2,2
2570 data 1,-2,1,-1,1,0,2,-2
2580 data 2,-1,1,0,2,0,0,1
2590 data P,8
2600 data 0,1,1,0,1,1,2,0
2610 data 1,0,0,1,1,1,0,2
2620 data 0,1,1,0,1,1,1,2
2630 data 1,0,0,1,1,1,2,1
2640 data 1,-1,1,0,2,-1,2,0
2650 data 1,-1,1,0,0,1,1,1
2660 data 0,1,0,2,1,1,1,2
2670 data 1,0,2,0,1,1,2,1
2680 data R,8
2690 data 0,1,0,2,1,2,1,3
2700 data 1,0,2,0,2,1,3,1
2710 data 1,-1,1,0,2,-1,3,-1
2720 data 1,-1,1,0,0,1,0,2
2730 data 0,1,1,1,1,2,1,3
2740 data 1,0,1,1,2,1,3,1
2750 data 1,0,2,-1,2,0,3,-1
2760 data 1,-2,1,-1,1,0,0,1
2770 data A,0