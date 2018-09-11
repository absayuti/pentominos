#!/usr/bin/env python 
# -*- coding: latin-1 -*-
from __future__ import print_function  
# Using Python 3 (also run in Python 2)
"""
-------------------------------------------------------------------------------
	Pentominos 
	A.B.Sayuti H.M.Saman

	A puzzle-solving program. Originally Pentominos for commodore computers
	by Jim Butterfield, Compute! May 1984

	0.24  20-9-15	Trying to put some colours and stuff	
	
	0.23  20.9.15	Using tried[][] to mark tried pieces in each slot
					Seems to be working now. 
			
	0.22  19-9-15	Need to add number of tries for each slot
			
	0.21  16-9-15	Started

			Algorithm:
				Initilization
				Get user input
				Clear screen, draw container
				slotno = 0
				While slotno < 12
					Find empty square
					If all filled up then break from loop
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
				End-while
				End game
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
	
	def __init__(self, name, rot, data):
		self.name = name
		self.rototal = rot
		self.x = [[0 for i in range(4)] for r in range(rot)]
		self.y = [[0 for i in range(4)] for r in range(rot)]
		j = 0
		r = 0
		while r < rot:
			for i in range(4):
				self.x[r][i] = data[j]
				j = j+1
				self.y[r][i] = data[j]
				j = j+1
			r = r+1
		self.used = False		# marked if piece is used

# -----------------------------------------------------------------------------
piece 		= []			# All pieces are stored in a list of objects
board 		= [[0 for y in range(6)] for x in range(20)] 
							# The board max height and width
X0			= 10			# X origin in the board
Y0			= 5				# Y origin in the board	

slotno		= 0				# Number of current slot being tried
tried 		= [[False for p in range(12)] for s in range(12)]
							# To mark which pieces have been tried in each
							# of the slots
nextpiece	= 0				# Next piece being tried
pieceno 	= [0 for s in range(12)]
							# Which piece P is placed in slotno S?
rotation	= [0 for s in range(12)]
							# Rotation # for piece P placed in slotno S?
xplace		= [0 for s in range(12)]
yplace		= [0 for s in range(12)]
							# starting square in slotno S for piece P
colour		= []


# =============================================================================
#
def main():
	
	initialize()
	get_user_input()
	init_screen()
	slotno = 0
	start_time = time.time()
	while slotno < 12:
		full = get_next_empty_spot()
		if full: break
		while not all_pieces_tried( slotno ):
			p = get_untried_piece( slotno )
			if p==12: break
			fit = try_piece( p, slotno )
			if fit:
				place_piece( p, nextrot, slotno )
				pieceno[slotno] = p
				rotation[slotno] = nextrot
				#input()
				slotno = slotno+1
				break
			else:
				tried[slotno][p] = True
		if not fit:
			reset_unused_pieces( slotno )
			slotno = slotno - 1
			if slotno<0: slotno = 0
			undraw_piece( slotno )
	elapsed_time = time.time() - start_time
	end_game( elapsed_time )		


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
def reset_unused_pieces( slot ):
	
	for i in range(12):
		tried[slot][i] = False
		

# -----------------------------------------------------------------------------
def all_pieces_tried( slot ):

	for i in range(12):
		if not tried[slot][i]:  
			return False
	
	return True 


# -----------------------------------------------------------------------------
def get_untried_piece( slot ):
	
	for i in range(12):
		if piece[i].used:
			tried[slot][i] = True
		else:
			if not tried[slot][i]:  
				return i
	return i


# -----------------------------------------------------------------------------
def try_piece( n, s ):
	global nextrot
	
	xp = xempty
	yp = yempty
	r = 0
	while r < piece[n].rototal:
		disp_info(n,s,r)
		hit = False
		for i in range(4):
			x = piece[n].x[r][i]+xp
			y = piece[n].y[r][i]+yp
			if x<0 or y<0 or x>=width or y>=height:
				hit = True
			elif board[x][y]!=0: 
				hit = True
		if not hit:
			nextrot = r 
			return True			# Found a rotation that fit
		else:
			r = r+1
	return False				# Tried all rotation, did not find fit
			
			
# -----------------------------------------------------------------------------
def place_piece( n, r, s ):
	global xplace, yplace

	xplace[s] = xempty
	yplace[s] = yempty
	board[xempty][yempty] = 1
	gotoxy( X0+xempty*2, Y0+yempty )
	print(colour[s%COLOURS]+'██')

	for i in range(4):
		x = xempty+piece[n].x[r][i]
		y = yempty+piece[n].y[r][i]
		board[x][y] = 1
		gotoxy( X0+x*2, Y0+y )
		print(colour[s%COLOURS]+'██')

	piece[n].used = True
	return
			

# -----------------------------------------------------------------------------
def undraw_piece( s ):

	x = xplace[s]
	y = yplace[s]
	board[x][y] = 0	
	gotoxy( X0+x*2, Y0+y )
	print('  ')
	n = pieceno[s]
	r = rotation[s]

	for i in range(4):
		x = xplace[s]+piece[n].x[r][i]
		y = yplace[s]+piece[n].y[r][i]
		board[x][y] = 0
		gotoxy( X0+x*2, Y0+y )
		print('  ')

	piece[n].used = False
	tried[s][n] = True
	return


# -----------------------------------------------------------------------------
def disp_info(pno,sno,rno):

	gotoxy(10,3)
	print(txtwht+'                  ')
	gotoxy(10,3)
	print('S',sno,' P',piece[pno].name,' R',rno)
	"""
	for s in range(12):
		gotoxy(60,s+3)
		print('                 ')
		gotoxy(60,s+3)
		if s==sno:
			print('>',s,pieceno[s],end=' ')
		else:
			print(' ',s,pieceno[s],end=' ')
		for i in range(12):
			if i==pieceno[s] and piece[i].used:
				print('X',end='')
			elif tried[s][i]:
				print('+',end='')
			else:
				print('.',end='')
	"""
	#time.sleep(0.1)
	
	
# -----------------------------------------------------------------------------
def initialize():
	global piece, COLOURS

	clrscr()
	gotoxy(10,1)
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
	piece.append(Piece('A', 0, [0,0,0,0,0,0]))
	
	for i in range(12):
		print( piece[i].name, end='' )
	print('\n')

	colour.append(bldblu)
	colour.append(bldylw)
	colour.append(bldred)
	colour.append(bldgrn)
	colour.append(bldpur)
	colour.append(bldcyn)
	COLOURS = 6
	
	return


# -----------------------------------------------------------------------------
def get_user_input():
	global height, width
	
	print('6 x 10 board')
	print('5 x 12 board')
	print('4 x 15 board')
	print('3 x 20 board')
	
	while True:
		print('Please enter 6,5,4 or 3: ')
		h = int(input())
		if h>2 and h<7: break
		
	height = h
	width = int(60/height)
	return


# -----------------------------------------------------------------------------
def init_screen():

	clrscr()
	gotoxy(10,1)
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
def end_game( elapsed ):
	
	gotoxy(1,20)
	print('DONE in', elapsed )
			
			
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
