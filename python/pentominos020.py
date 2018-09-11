#!/usr/bin/python
# Using Python 3 (also run in Python 2)
"""
-------------------------------------------------------------------------------
	Pentominos 
	A.B.Sayuti H.M.Saman

	A puzzle-solving program. Originally Pentominos for commodore computers
	by Jim Butterfield, Compute! May 1984

    Algorithm:
				Initilization
				Get user input
				Clear screen, draw container
				Find new space to fill
				While not filled up
					Get next unused piece
					Repeat
						Try fitting piece
						If it fits then
							Put piece in place
						Else
							Rotate the piece
					Until piece fit or all rotation tried
					If all rotation tried
						Undraw previous piece
					Find new space to fill
				End-while
-------------------------------------------------------------------------------
"""
# =============================================================================
#
import sys, os, time, math

if 'win' in sys.platform:
    import colorama
    colorama.init()	
	
#from colorconsole import terminal
#screen = terminal.get_terminal()

# -----------------------------------------------------------------------------
class Piece(object):
	def __init__(self, name, num, data):
		self.name = name
		self.num = num
		self.x = [[0 for i in range(4)] for r in range(num)]
		self.y = [[0 for i in range(4)] for r in range(num)]
		j = 0
		r = 0
		while r < num:
			for i in range(4):
				self.x[r][i] = data[j]
				j = j+1
				self.y[r][i] = data[j]
				j = j+1
			r = r+1
		self.used = False		# marked if piece is used

# -----------------------------------------------------------------------------
piece 	= []			# All pieces are stored in a list of objects
board 	= [[0 for x in range(6)] for x in range(20)] 
						# The board max height and width
X0		= 10			# X origin in the board
Y0		= 5				# Y origin in the board	

slotno	= 0				# Number of current slot being tried
xplace	= [0 for x in range(12)]
yplace	= [0 for x in range(12)]
						# starting square in current slot for piece placed


# =============================================================================
#
def main():
	
	initialize()
	get_user_input()
	init_screen()
	nextpiece = 0
	full = get_next_empty_spot( nextpiece )
	while not full:
		#gotoxy(1,1)
		#print( full )
		nextpiece = get_unused_piece( nextpiece )
		rot = 0
		while rot < piece[nextpiece].num:
			fit = try_piece( nextpiece, rot )
			if fit:
				place_piece( nextpiece, rot )
				slotno = slotno+1
				break
			else:
				rot = rot+1
		#If all rotation tried
			#Undraw previous piece
				
		nextpiece = nextpiece+1
		if nextpiece==12:
			
		#Find new space to fill
	#End-while
#

# -----------------------------------------------------------------------------
def initialize():
	global piece

	clrscr()
	gotoxy(10,10)
	print( txtcyn )
	print(' P E N T O M I N O E S')
	piece.append(Piece('I', 2, [0,1,0,2,0,3,0,4,   1,0,2,0,3,0,4,0]))
	piece.append(Piece('X', 1, [1,-1,1,0,2,0,1,1]))
	piece.append(Piece('V', 4, [0,1,0,2,1,0,2,0,   0,1,0,2,1,2,2,2,	  	\
								1,0,2,0,2,1,2,2,   1,0,2,0,2,-1,2,-2]))
	piece.append(Piece('T', 4, [0,1,0,2,1,1,2,1,    1,0,1,1,2,0,1,2,  	\
								1,0,2,0,1,-1,1,-2,  2,-1,2,0,2,1,1,0]))
	piece.append(Piece('W', 4, [0,1,1,1,1,2,2,2,    1,0,1,1,2,1,2,2,  	\
								0,1,1,-1,1,0,2,-1,  1,-1,1,0,2,-2,2,-1]))
	piece.append(Piece('U', 4, [0,2,1,0,1,1,1,2,	2,0,0,1,1,1,2,1,  	\
								0,1,1,0,2,0,2,1,	1,0,0,1,0,2,1,2]))
	piece.append(Piece('F', 8, [0,1,1,-1,1,0,2,0,	1,-1,2,-1,1,0,1,1, 	\
								1,-1,1,0,1,1,2,1,	1,-1,1,0,2,0,2,1,  	\
								0,1,1,1,1,2,2,1,	1,0,1,1,2,1,1,2,   	\
								1,0,1,1,2,-1,2,0,	1,-2,1,-1,2,-1,1,0]))
	piece.append(Piece('L', 8, [1,0,2,0,3,0,3,1,	0,1,0,2,0,3,1,3,   	\
								1,-3,1,-2,1,-1,1,0,	1,0,2,0,3,0,3,-1,	\
								1,0,2,0,3,0,0,1,	0,1,0,2,0,3,1,0,	\
								0,1,1,1,2,1,3,1,	1,0,1,1,1,2,1,3]))
	piece.append(Piece('Y', 8, [0,1,0,2,0,3,1,1,	1,0,2,0,3,0,1,1,	\
								1,-1,1,0,1,1,1,2,	1,-1,1,0,2,0,3,0,	\
								0,1,0,2,0,3,1,2,	1,0,2,0,3,0,2,1,	\
								1,-2,1,-1,1,0,1,1,	1,0,2,0,3,0,2,-1]))
	piece.append(Piece('Z', 4, [0,1,1,1,2,1,2,2,	1,0,1,1,1,2,2,2,	\
								1,-2,1,-1,1,0,2,-2,	2,-1,1,0,2,0,0,1]))
	piece.append(Piece('P', 8, [0,1,1,0,1,1,2,0,	1,0,0,1,1,1,0,2,	\
								0,1,1,0,1,1,1,2,	1,0,0,1,1,1,2,1,	\
								1,-1,1,0,2,-1,2,0,	1,-1,1,0,0,1,1,1,	\
								0,1,0,2,1,1,1,2,	1,0,2,0,1,1,2,1]))
	piece.append(Piece('R', 8, [0,1,0,2,1,2,1,3,	1,0,2,0,2,1,3,1,	\
								1,-1,1,0,2,-1,3,-1,	1,-1,1,0,0,1,0,2,	\
								0,1,1,1,1,2,1,3,	1,0,1,1,2,1,3,1,	\
								1,0,2,-1,2,0,3,-1,	1,-2,1,-1,1,0,0,1]))
	piece.append(Piece('A', 0, []))
	
	for i in range(13):
		print( piece[i].name, end='' )

	return


# -----------------------------------------------------------------------------
def get_user_input():
	global height, width
	height = 6
	width = int(60/height)
	return


# -----------------------------------------------------------------------------
def init_screen():

	clrscr()
	gotoxy(30,1)
	print('P E N T O M I N O S')
	gotoxy(X0-1,Y0-1)
	print('╔',end='')
	for w in range(width): print('══',end='')
	print('╗')
	y = 0
	for h in range(height): 
		gotoxy(X0-1,Y0+y)
		print('║',end='')
		for w in range(width):print('  ',end='')
		print('║')
		y = y+1
	gotoxy(X0-1,Y0+y)
	print('╚',end='')
	for w in range(width): print('══',end='')
	print('╝')
	return


# -----------------------------------------------------------------------------
def get_next_empty_spot():	
	global xempty, yempty
	
	for w in range(width):
		for h in range(height):
			if board[w][h]==0:
				xempty = w
				yempty = h
				return False 		# Not full yet

	return False					# Board is full


# -----------------------------------------------------------------------------
def get_unused_piece( n ):
	
	for i in range(n,12):
		gotoxy(77,22)
		print(i)
		if not piece[i].used:  return i


# -----------------------------------------------------------------------------
def try_piece( n, r ):

	xp = xplace[n]
	yp = yplace[n]
	for i in range(4):
		x = piece[n].x[r][i]+xp
		y = piece[n].y[r][i]+yp
		if x<0 or y<0 or x>width or y>height: return False
		if board[x][y]!=0: return False
	return True

			
# -----------------------------------------------------------------------------
def place_piece( n, r ):
	
	gotoxy( X0+xempty, Y0+yempty )
	print(piece[n].name+'@')

	for i in range(4):
		x = xempty+piece[n].x[r][i]
		y = yempty+piece[n].y[r][i]
		gotoxy( X0+x*2, Y0+y )
		print(piece[n].name+'@')

	piece[n].used = True
	return
			
			
			
			
# -----------------------------------------------------------------------------
def clrscr():
	print('\033[2J', end='')
	return

	
# -----------------------------------------------------------------------------			
def gotoxy( x, y ):
	lin = str(y).strip()
	col = str(x).strip() 
	c = '\033['+lin+';'+col+'H'
	print( c, end='')
	return
	
	

#------------------------------------------------------------------------------
# Escape codes for colours 
#
txtblk='\033[0;30m' # Black - Regular
txtred='\033[0;31m' # Red
txtgrn='\033[0;32m' # Green
txtylw='\033[0;33m' # Yellow
txtblu='\033[0;34m' # Blue
txtpur='\033[0;35m' # Purple
txtcyn='\033[0;36m' # Cyan
txtwht='\033[0;37m' # White
bldblk='\033[1;30m' # Black - Bold
bldred='\033[1;31m' # Red
bldgrn='\033[1;32m' # Green
bldylw='\033[1;33m' # Yellow
bldblu='\033[1;34m' # Blue
bldpur='\033[1;35m' # Purple
bldcyn='\033[1;36m' # Cyan
bldwht='\033[1;37m' # White
undblk='\033[4;30m' # Black - Underline
undred='\033[4;31m' # Red
undgrn='\033[4;32m' # Green
undylw='\033[4;33m' # Yellow
undblu='\033[4;34m' # Blue
undpur='\033[4;35m' # Purple
undcyn='\033[4;36m' # Cyan
undwht='\033[4;37m' # White
bakblk='\033[40m'   # Black - Background
bakred='\033[41m'   # Red
bakgrn='\033[42m'   # Green
bakylw='\033[43m'   # Yellow
bakblu='\033[44m'   # Blue
bakpur='\033[45m'   # Purple
bakcyn='\033[46m'   # Cyan
bakwht='\033[47m'   # White
txtrst='\033[0m'    # Text Reset
crsrup='\033[1A'    # Cursor up


# -----------------------------------------------------------------------------
# Call main()
#
if __name__ == "__main__":
   main()
#
# End of program
# =============================================================================


"""
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
1760 c$ = "{reverse on}{sh @}{reverse off}" :x1(0)=x1 :y1(0)=y1
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
!-   Place the piece
2400 print hm$;left$(v$,y);left$(h$,x);pc$(p1);c$
2410 b(y,x)=b
2420 return
!------------------------------------------------------------------------------
"""
