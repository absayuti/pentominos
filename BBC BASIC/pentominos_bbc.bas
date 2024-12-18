      REM ------------------------------------------------------------------------------
      REM  Pentominos for BBC BASIC SDL (Windows)
      REM     A puzzle-solving program for the SDL version of BBC BASIC. 
      REM     Should be compatible with AGON LIGHT's BBC BASIC; but is yet tested.
      REM
      REM  Originally:
      REM     Pentominos for commodore computers
      REM     by Jim Butterfield, Compute! May 1984
      REM
      REM     This version ported from 'Pentominos 64'
      REM     Which copied and pasted into CBM Prg Studio
      REM     On 5th September 2015
      REM     A.B.Sayuti H.M.Saman
      :
      REM ------------------------------------------------------------------------------
      REM   Initialization
      MODE 1
      CLS
      PRINT TAB(4,4);"P E N T O M I N O S"
 1110 DIM x(63,4), y(63,4), p(64)
      DIM p$(13)         :REM names of the pieces
      DIM t(13)          :REM which rotation is currently being tried for piece X
      DIM s(13)          :REM starting rotation for piece X
      DIM b(6,20)        :REM board contents
      DIM x1(5),y1(5), u(12), ur(12)
      DIM x2(12), y2(12) :REM starting square where a piece has been placed
      x0 = 4: y0 = 4    :REM offste coord for the container
      v = 0
 1180 READ pp$,n
      REPEAT
        t = t+1
        p$(t) = pp$
        s(t) = v+1
        FOR j = v+1 TO v+n
          p(j) = t
          FOR k=0 TO 3
            READ x(j,k), y(j,k)
          NEXT k
        NEXT j
        v = v+n
        REM PRINT pp$;n;
        READ pp$,n
      UNTIL n = 0
      :
      REM -----------------------------------------------------------------------------
      REM   Get user input
 1320 PRINT TAB(0,10);"Choose:"
 1330 FOR j=3 TO 6
        PRINT j;" x ";60/j
      NEXT j
      PRINT
      REPEAT
        SOUND 1,-15,100,3
 1340   INPUT "Select 3 thru 6";w1
 1350 UNTIL w1>2 AND w1<7
 1360 w2=60/w1
      :
      PROC_setup_screen
      :
      REM-----------------------------------------------------------------------------
      REM   Main routine
      REM find new space to fill
      bc = 1 :REM background colour
      TIME = 0
 1690 GOSUB 2310 :p = j  :REM get next unused piece
      REM PRINT TAB(20,1);"p=";p;"j=";j
      REM FOR cc=1 TO 100: NEXT  :REM delay for debugging purpose
 1700 GOSUB 2340         :REM get next empty spot
 1710 IF x1>w2 GOTO 1980 :REM if exceed container width, all filled up
      REM get a new piece
 1730 t(p) = s(p)
      REM PRINT TAB(x0,w1+7);p$(p)
      REM try fitting piece
 1760 c$ = p$(p) :x1(0)=x1 :y1(0)=y1
      fit = 1
      FOR j = 1 TO 4
        x = x(t(p),j-1)+x1
        y = y(t(p),j-1)+y1
        x1(j) = x
        y1(j) = y
        IF x<1 OR y<1 OR x>w2 OR y>w1 THEN fit=0: EXIT FOR
        IF b(y,x)<>0 THEN fit=0: EXIT FOR
        REM IF x<1 OR y<1 OR x>w2 OR y>w1 GOTO 2220 :REM rotate the piece
        REM IF b(y,x)<>0 GOTO 2220
      NEXT j
      IF fit=0 GOTO 2220 :REM rotate the piece
      REM it fits - put piece in place
 1860 b = p
      FOR j=0 TO 4
        x = x1(j)
        y = y1(j)
        GOSUB 2400     :REM place the piece
      NEXT j
      bc = bc+1
      IF bc=4 THEN bc=1
 1920 x2(p) = x1
      y2(p) = y1
      p1 = p1+1
      u(p1) = p
      GOTO 1690
      REM-----------------------------------------------------------------------------
      REM board filled
 1980 tt = TIME
      COLOUR 3        :REM white foreground
      COLOUR 128      :REM black background
      PRINT TAB(0,18);"Solved in ";tt/100;" sec"
      PRINT
      FOR i=1 TO 12
        IF u(i)=ur(i) THEN
          COLOUR 3
        ELSE
          COLOUR 1
        ENDIF
        PRINT " ";p$(u(i));
      NEXT
      COLOUR 3
      REM END
      PRINT TAB(0,22);
      INPUT "Try next combination (Y/N)", ch$
      IF ch$="n" OR ch$="N" OR ch$="no" OR ch$="NO" THEN END
      REM reset some paramaters
      PRINT TAB(0,18);"                                "
      PRINT TAB(0,20);"                                "
      PRINT TAB(0,22);"                                "
      FOR i=1 TO 12
        ur(i) = u(i)
      NEXT
      TIME = 0
      :
      REM-----------------------------------------------------------------------------
      REM undraw last one
 2030 p = u(p1)
      u(p1) = 0
      p1 = p1-1
      IF p1<0 THEN PRINT TAB(0,20);"That's all" :END
      b = 0
      x = x2(p)
      y = y2(p)
      c$ = " "
      GOSUB 2400         :REM place the piece
 2120 x1 = x
      y1 = y
      FOR j=1 TO 4
        x = x(t(p),j-1)+x1
        y = y(t(p),j-1)+y1
        x1(j) = x
        y1(j) = y
        GOSUB 2400     :REM place the piece
      NEXT j
      REM rotate the piece
 2220 t(p) = t(p)+1
      IF p(t(p)) = p GOTO 1760
      REM give up on piece
 2250 t(p) = 0
      REM look for new piece
 2270 p = p+1
      IF p>12 GOTO 2030
      IF t(p)<>0 GOTO 2270
      GOTO 1730
      :
      REM-----------------------------------------------------------------------------
      REM   Find next unused piece
 2310 FOR j=1 TO 12
        IF t(j)=0 THEN RETURN
      NEXT
      RETURN
      :
      REM-----------------------------------------------------------------------------
      REM   Find next empty spot
 2340 FOR x1=1 TO w2
        FOR y1=1 TO w1
          REM PRINT TAB(20,3);x1;" ";y1
          IF b(y1,x1) = 0 GOTO 2390
        NEXT y1
      NEXT x1
 2390 RETURN
      :
      REM-----------------------------------------------------------------------------
      REM   Place the piece
 2400 PRINT TAB(x+x0,y+y0);c$
      b(y,x)=b
      RETURN

      REM-----------------------------------------------------------------------------
      DEF PROC_setup_screen

      COLOUR 3        :REM white foreground
      COLOUR 128      :REM black background
      CLS
      PRINT TAB(4,2);"P E N T O M I N O S"
      REM   Place container
      COLOUR 0        :REM black foreground
      COLOUR 130      :REM white background
      FOR i = 0 TO w2+1
        PRINT TAB(x0+i,y0);" ";
        PRINT TAB(x0+i,y0+w1+1);" ";
      NEXT
      FOR i = 1 TO w1
        PRINT TAB(x0,y0+i);" ";
        PRINT TAB(x0+w2+1,y0+i);" "
      NEXT
      COLOUR 3        :REM white foreground
      COLOUR 128      :REM black background

      ENDPROC

      REM-----------------------------------------------------------------------------
      REM The pentomino pieces
      REM
      REM Piece I      0OOOO   0
      REM                      O
      REM                      O
      REM                      O
      REM                      O
      DATA I,2
      DATA 0,1,0,2,0,3,0,4
      DATA 1,0,2,0,3,0,4,0
      REM
      REM Piece X       0
      REM              OOO
      REM               O
      DATA X,1
      DATA 1,-1,1,0,2,0,1,1
      REM
      REM Piece V      0OO     0
      REM              O       O
      REM              O       OOO
      DATA V,4
      DATA 0,1,0,2,1,0,2,0
      DATA 0,1,0,2,1,2,2,2
      DATA 1,0,2,0,2,1,2,2
      DATA 1,0,2,0,2,-1,2,-2
      REM
      REM Piece T      0       0OO      O
      REM              OOO      O       O
      REM              O        O      0OO
      DATA T,4
      DATA 0,1,0,2,1,1,2,1
      DATA 1,0,1,1,2,0,1,2
      DATA 1,0,2,0,1,-1,1,-2
      DATA 2,-1,2,0,2,1,1,0
      DATA W,4
      DATA 0,1,1,1,1,2,2,2
      DATA 1,0,1,1,2,1,2,2
      DATA 0,1,1,-1,1,0,2,-1
      DATA 1,-1,1,0,2,-2,2,-1
      DATA U,4
      DATA 0,2,1,0,1,1,1,2
      DATA 2,0,0,1,1,1,2,1
      DATA 0,1,1,0,2,0,2,1
      DATA 1,0,0,1,0,2,1,2
      DATA F,8
      DATA 0,1,1,-1,1,0,2,0
      DATA 1,-1,2,-1,1,0,1,1
      DATA 1,-1,1,0,1,1,2,1
      DATA 1,-1,1,0,2,0,2,1
      DATA 0,1,1,1,1,2,2,1
      DATA 1,0,1,1,2,1,1,2
      DATA 1,0,1,1,2,-1,2,0
      DATA 1,-2,1,-1,2,-1,1,0
      DATA L,8
      DATA 1,0,2,0,3,0,3,1
      DATA 0,1,0,2,0,3,1,3
      DATA 1,-3,1,-2,1,-1,1,0
      DATA 1,0,2,0,3,0,3,-1
      DATA 1,0,2,0,3,0,0,1
      DATA 0,1,0,2,0,3,1,0
      DATA 0,1,1,1,2,1,3,1
      DATA 1,0,1,1,1,2,1,3
      DATA Y,8
      DATA 0,1,0,2,0,3,1,1
      DATA 1,0,2,0,3,0,1,1
      DATA 1,-1,1,0,1,1,1,2
      DATA 1,-1,1,0,2,0,3,0
      DATA 0,1,0,2,0,3,1,2
      DATA 1,0,2,0,3,0,2,1
      DATA 1,-2,1,-1,1,0,1,1
      DATA 1,0,2,0,3,0,2,-1
      DATA Z,4
      DATA 0,1,1,1,2,1,2,2
      DATA 1,0,1,1,1,2,2,2
      DATA 1,-2,1,-1,1,0,2,-2
      DATA 2,-1,1,0,2,0,0,1
      DATA P,8
      DATA 0,1,1,0,1,1,2,0
      DATA 1,0,0,1,1,1,0,2
      DATA 0,1,1,0,1,1,1,2
      DATA 1,0,0,1,1,1,2,1
      DATA 1,-1,1,0,2,-1,2,0
      DATA 1,-1,1,0,0,1,1,1
      DATA 0,1,0,2,1,1,1,2
      DATA 1,0,2,0,1,1,2,1
      DATA R,8
      DATA 0,1,0,2,1,2,1,3
      DATA 1,0,2,0,2,1,3,1
      DATA 1,-1,1,0,2,-1,3,-1
      DATA 1,-1,1,0,0,1,0,2
      DATA 0,1,1,1,1,2,1,3
      DATA 1,0,1,1,2,1,3,1
      DATA 1,0,2,-1,2,0,3,-1
      DATA 1,-2,1,-1,1,0,0,1
      DATA A,0
