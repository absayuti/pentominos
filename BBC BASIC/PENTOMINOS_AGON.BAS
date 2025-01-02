   10 REM ------------------------------------------------------------------------------
   20 REM  Pentominos for AGON LIGHT (0.21)
   30 REM     A puzzle-solving program for the AGON LIGHT BBC BASIC
   40 REM
   50 REM  Originally:
   60 REM     Pentominos for commodore computers
   70 REM     by Jim Butterfield, Compute! May 1984
   80 REM
   90 REM     This version ported from 'Pentominos 64'
  100 REM     Which copied and pasted into CBM Prg Studio
  110 REM     On 5th September 2015
  120 REM     A.B.Sayuti H.M.Saman
  130 :
  140 REM ------------------------------------------------------------------------------
  150 REM   Initialization
  160 MODE 1
  170 CLS
  180 PRINT TAB(4,4);"P E N T O M I N O S"
  190 DIM x(63,4), y(63,4), p(64)
  200 DIM p$(13)         :REM names of the pieces
  210 DIM t(13)          :REM which rotation is currently being tried for piece X
  220 DIM s(13)          :REM starting rotation for piece X
  230 DIM b(6,20)        :REM board contents
  240 DIM x1(5),y1(5), u(12), ur(12)
  250 DIM x2(12), y2(12) :REM starting square where a piece has been placed
  260 x0 = 4: y0 = 4    :REM offste coord for the container
  270 v = 0
  280 READ pp$,n
  290 REPEAT
  300   t = t+1
  310   p$(t) = pp$
  320   s(t) = v+1
  330   FOR j = v+1 TO v+n
  340     p(j) = t
  350     FOR k=0 TO 3
  360       READ x(j,k), y(j,k)
  370     NEXT k
  380   NEXT j
  390   v = v+n
  400   REM PRINT pp$;n;
  410   READ pp$,n
  420 UNTIL n = 0
  430 :
  440 REM -----------------------------------------------------------------------------
  450 REM   Get user input
  460 PRINT TAB(0,10);"Choose:"
  470 FOR j=3 TO 6
  480   PRINT j;" x ";60/j
  490 NEXT j
  500 PRINT
  510 REPEAT
  520   SOUND 1,-15,100,3
  530   INPUT "Select 3 thru 6";w1
  540 UNTIL w1>2 AND w1<7
  550 w2=60/w1
  560 :
  570 PROC_setup_screen
  580 :
  590 REM-----------------------------------------------------------------------------
  600 REM   Main routine
  610 REM find new space to fill
  620 bc = 1 :REM background colour
  630 TIME = 0
  640 GOSUB 1570 :p = j  :REM get next unused piece
  650 GOSUB 1650         :REM get next empty spot
  660 IF x1>w2 GOTO 970 :REM if exceed container width, all filled up
  670 REM get a new piece
  680 t(p) = s(p)
  690 REM try fitting piece
  700 c$ = p$(p) :x1(0)=x1 :y1(0)=y1
  710 fit = 1
  720 FOR j = 1 TO 4
  730   x = x(t(p),j-1)+x1
  740   y = y(t(p),j-1)+y1
  750   x1(j) = x
  760   y1(j) = y
  770   IF x<1 OR y<1 OR x>w2 OR y>w1 THEN fit=0: j=4: GOTO 790
  780   IF b(y,x)<>0 THEN fit=0: j=4: GOTO 790
  790 NEXT j
  800 IF fit=0 GOTO 1450 :REM rotate the piece
  810 REM it fits - put piece in place
  820 b = p
  830 FOR j=0 TO 4
  840   x = x1(j)
  850   y = y1(j)
  860   GOSUB 1780     :REM place the piece
  870 NEXT j
  880 bc = bc+1
  890 IF bc=4 THEN bc=1
  900 x2(p) = x1
  910 y2(p) = y1
  920 p1 = p1+1
  930 u(p1) = p
  940 GOTO 640
  950 REM-----------------------------------------------------------------------------
  960 REM board filled
  970 tt = TIME
  980 COLOUR 3        :REM white foreground
  990 COLOUR 128      :REM black background
 1000 PRINT TAB(0,18);"Solved in ";tt/100;" sec"
 1010 PRINT
 1020 FOR i=1 TO 12
 1030   IF u(i)=ur(i) THEN COLOUR 3 ELSE COLOUR 1
 1080   PRINT " ";p$(u(i));
 1090 NEXT
 1100 COLOUR 3
 1110 REM END
 1120 PRINT TAB(0,22);
 1130 INPUT "Try next combination (Y/N)", ch$
 1140 IF ch$="n" OR ch$="N" OR ch$="no" OR ch$="NO" THEN END
 1150 REM reset some paramaters
 1160 PRINT TAB(0,18);"                                "
 1170 PRINT TAB(0,20);"                                "
 1180 PRINT TAB(0,22);"                                "
 1190 FOR i=1 TO 12
 1200   ur(i) = u(i)
 1210 NEXT
 1220 TIME = 0
 1230 :
 1240 REM-----------------------------------------------------------------------------
 1250 REM undraw last one
 1260 p = u(p1)
 1270 u(p1) = 0
 1280 p1 = p1-1
 1290 IF p1<0 THEN PRINT TAB(0,20);"That's all" :END
 1300 b = 0
 1310 x = x2(p)
 1320 y = y2(p)
 1330 c$ = " "
 1340 GOSUB 1780         :REM place the piece
 1350 x1 = x
 1360 y1 = y
 1370 FOR j=1 TO 4
 1380   x = x(t(p),j-1)+x1
 1390   y = y(t(p),j-1)+y1
 1400   x1(j) = x
 1410   y1(j) = y
 1420   GOSUB 1780     :REM place the piece
 1430 NEXT j
 1440 REM rotate the piece
 1450 t(p) = t(p)+1
 1460 IF p(t(p)) = p GOTO 700
 1470 REM give up on piece
 1480 t(p) = 0
 1490 REM look for new piece
 1500 p = p+1
 1510 IF p>12 GOTO 1260
 1520 IF t(p)<>0 GOTO 1500
 1530 GOTO 680
 1540 :
 1550 REM-----------------------------------------------------------------------------
 1560 REM   Find next unused piece
 1570 j = 0
 1580 REPEAT
 1590   j = j+1
 1600 UNTIL j>12 OR t(j)=0
 1610 RETURN
 1620 :
 1630 REM-----------------------------------------------------------------------------
 1640 REM   Find next empty spot
 1650 x1=1
 1670 y1=1
 1690 IF b(y1,x1)=0 THEN 1740
 1710 y1=y1+1
 1715 IF y1<=w1 THEN 1690
 1720 x1=x1+1
 1730 IF x1<=w2 THEN 1670
 1740 RETURN
 1750 :
 1760 REM-----------------------------------------------------------------------------
 1770 REM   Place the piece
 1780 PRINT TAB(x+x0,y+y0);c$
 1790 b(y,x)=b
 1800 RETURN
 1810
 1820 REM-----------------------------------------------------------------------------
 1830 DEF PROC_setup_screen
 1840
 1850 COLOUR 3        :REM white foreground
 1860 COLOUR 128      :REM black background
 1870 CLS
 1880 PRINT TAB(4,2);"P E N T O M I N O S"
 1890 REM   Place container
 1900 COLOUR 0        :REM black foreground
 1910 COLOUR 130      :REM white background
 1920 FOR i = 0 TO w2+1
 1930   PRINT TAB(x0+i,y0);" ";
 1940   PRINT TAB(x0+i,y0+w1+1);" ";
 1950 NEXT
 1960 FOR i = 1 TO w1
 1970   PRINT TAB(x0,y0+i);" ";
 1980   PRINT TAB(x0+w2+1,y0+i);" "
 1990 NEXT
 2000 COLOUR 3        :REM white foreground
 2010 COLOUR 128      :REM black background
 2020
 2030 ENDPROC
 2040
 2050 REM-----------------------------------------------------------------------------
 2060 REM The pentomino pieces
 2070 REM
 2080 REM Piece I      0OOOO   0
 2090 REM                      O
 2100 REM                      O
 2110 REM                      O
 2120 REM                      O
 2130 DATA I,2
 2140 DATA 0,1,0,2,0,3,0,4
 2150 DATA 1,0,2,0,3,0,4,0
 2160 REM
 2170 REM Piece X       0
 2180 REM              OOO
 2190 REM               O
 2200 DATA X,1
 2210 DATA 1,-1,1,0,2,0,1,1
 2220 REM
 2230 REM Piece V      0OO     0
 2240 REM              O       O
 2250 REM              O       OOO
 2260 DATA V,4
 2270 DATA 0,1,0,2,1,0,2,0
 2280 DATA 0,1,0,2,1,2,2,2
 2290 DATA 1,0,2,0,2,1,2,2
 2300 DATA 1,0,2,0,2,-1,2,-2
 2310 REM
 2320 REM Piece T      0       0OO      O
 2330 REM              OOO      O       O
 2340 REM              O        O      0OO
 2350 DATA T,4
 2360 DATA 0,1,0,2,1,1,2,1
 2370 DATA 1,0,1,1,2,0,1,2
 2380 DATA 1,0,2,0,1,-1,1,-2
 2390 DATA 2,-1,2,0,2,1,1,0
 2400 DATA W,4
 2410 DATA 0,1,1,1,1,2,2,2
 2420 DATA 1,0,1,1,2,1,2,2
 2430 DATA 0,1,1,-1,1,0,2,-1
 2440 DATA 1,-1,1,0,2,-2,2,-1
 2450 DATA U,4
 2460 DATA 0,2,1,0,1,1,1,2
 2470 DATA 2,0,0,1,1,1,2,1
 2480 DATA 0,1,1,0,2,0,2,1
 2490 DATA 1,0,0,1,0,2,1,2
 2500 DATA F,8
 2510 DATA 0,1,1,-1,1,0,2,0
 2520 DATA 1,-1,2,-1,1,0,1,1
 2530 DATA 1,-1,1,0,1,1,2,1
 2540 DATA 1,-1,1,0,2,0,2,1
 2550 DATA 0,1,1,1,1,2,2,1
 2560 DATA 1,0,1,1,2,1,1,2
 2570 DATA 1,0,1,1,2,-1,2,0
 2580 DATA 1,-2,1,-1,2,-1,1,0
 2590 DATA L,8
 2600 DATA 1,0,2,0,3,0,3,1
 2610 DATA 0,1,0,2,0,3,1,3
 2620 DATA 1,-3,1,-2,1,-1,1,0
 2630 DATA 1,0,2,0,3,0,3,-1
 2640 DATA 1,0,2,0,3,0,0,1
 2650 DATA 0,1,0,2,0,3,1,0
 2660 DATA 0,1,1,1,2,1,3,1
 2670 DATA 1,0,1,1,1,2,1,3
 2680 DATA Y,8
 2690 DATA 0,1,0,2,0,3,1,1
 2700 DATA 1,0,2,0,3,0,1,1
 2710 DATA 1,-1,1,0,1,1,1,2
 2720 DATA 1,-1,1,0,2,0,3,0
 2730 DATA 0,1,0,2,0,3,1,2
 2740 DATA 1,0,2,0,3,0,2,1
 2750 DATA 1,-2,1,-1,1,0,1,1
 2760 DATA 1,0,2,0,3,0,2,-1
 2770 DATA Z,4
 2780 DATA 0,1,1,1,2,1,2,2
 2790 DATA 1,0,1,1,1,2,2,2
 2800 DATA 1,-2,1,-1,1,0,2,-2
 2810 DATA 2,-1,1,0,2,0,0,1
 2820 DATA P,8
 2830 DATA 0,1,1,0,1,1,2,0
 2840 DATA 1,0,0,1,1,1,0,2
 2850 DATA 0,1,1,0,1,1,1,2
 2860 DATA 1,0,0,1,1,1,2,1
 2870 DATA 1,-1,1,0,2,-1,2,0
 2880 DATA 1,-1,1,0,0,1,1,1
 2890 DATA 0,1,0,2,1,1,1,2
 2900 DATA 1,0,2,0,1,1,2,1
 2910 DATA R,8
 2920 DATA 0,1,0,2,1,2,1,3
 2930 DATA 1,0,2,0,2,1,3,1
 2940 DATA 1,-1,1,0,2,-1,3,-1
 2950 DATA 1,-1,1,0,0,1,0,2
 2960 DATA 0,1,1,1,1,2,1,3
 2970 DATA 1,0,1,1,2,1,3,1
 2980 DATA 1,0,2,-1,2,0,3,-1
 2990 DATA 1,-2,1,-1,1,0,0,1
 3000 DATA A,0
