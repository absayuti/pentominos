#!/usr/bin/python 
from __future__ import print_function  
# Using Python 3 (should also run in Python 2)
"""
-------------------------------------------------------------------------------
	Pentominos 
	A.B.Sayuti H.M.Saman

	A puzzle-solving program. Originally Pentominos for commodore computers
	by Jim Butterfield, Compute! May 1984

	0.26	12-10-15	Let's really try :((((((
	0.25  	25-9-15		Let's try with PyGame
	
	0.24  	25-9-15		Now it can't run in Windows !
			20-9-15		Trying to put some colours and stuff	
	
	0.23  	20-9-15		Using tried[][] to mark tried pieces in each slot
						Seems to be working now. 
			
	0.22  	19-9-15		Need to add number of tries for each slot
			
	0.21  	16-9-15		Started

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
import pygame, sys, time, random, os
from   pygame.locals import *
from   datetime import datetime


# =============================================================================
# Global constants & variables

# Define the colors
BLACK       = (0, 0, 0)
WHITE       = (255, 255, 255)
RED    		= (255, 0, 0)
GREEN  		= (0, 255, 0)
BLUE   		= (0, 0, 255)
YELLOW 		= (255, 255, 0)
CYAN   		= (0, 255, 255)
GRAY   		= (128, 128, 128)
SILVER      = (192, 192, 192)
	
# Brick tile's size
tileWIDTH   	= 24
tileHEIGHT  	= 24

# Game window's size/colours
windowWIDTH 	= 24*tileWIDTH
windowHEIGHT 	= 16*tileHEIGHT
windowTOP   	= tileHEIGHT		# for the text at top
windowColourDepth = 32

# Container coord 0,0 and max size
boardX0			= 2*tileWIDTH
boardY0			= 2*tileHEIGHT
boardWIDTH		= 20				# to be set by user input later...
boardHEIGHT		= 3					# ...

PLAYTIME		= 100                          # 100 seconds?
ANTI_ALIASED	= True


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
# Main Loop

def main_loop():
	
	slotno = 0
	start_time = time.time()
	while slotno < 12:
		for event in pygame.event.get():
			if event.type == QUIT: return

		if not compute_next_move():
			break
		#board[slotno][1] = 1
		#slotno = slotno+1
		
		### Re-draw display ###
		window.fill(BLACK)
		# The board
		xx = boardWIDTH*tileWIDTH
		yy = boardHEIGHT*tileHEIGHT
		pygame.draw.rect(window, WHITE, (boardX0-2,boardY0-2,xx+4,yy+4),2)
		# The tiles/pieces
		for y in range(boardHEIGHT):
			for x in range(boardWIDTH):
				x1 = x*tileWIDTH + boardX0
				#x2 = (x+1)*tileWIDTH + boardX0
				y1 = y*tileHEIGHT + boardY0 
				#y2 = (y+1)*tileHEIGHT + boardY0
				if board[x][y]==1:
					pygame.draw.rect(window, RED, [x1,y1,tileWIDTH,tileHEIGHT])
					pygame.draw.rect(window, WHITE, [x1,y1,tileWIDTH,tileHEIGHT],2)
				#else:
				#	pygame.draw.rect(window, BLUE, [x1,y1,tileWIDTH,tileHEIGHT],1)
		# Header text
		txtInfo = basicFont.render('PENTOMINOS', ANTI_ALIASED, WHITE, BLACK)
		txtInfoPos = txtInfo.get_rect()
		txtInfoPos.midtop = window.get_rect().midtop
		# Show the window/display
		window.blit(txtInfo, txtInfoPos)
		pygame.display.flip()
		pygame.time.wait(500)
		#clock.tick(20)
	
	elapsed_time = time.time() - start_time
	end_game( elapsed_time )


# -----------------------------------------------------------------------------
def compute_next_move():
	global slotno
	
	# The thinking part...
	full = get_next_empty_spot()		
	if full:
		return False
	while not all_pieces_tried( slotno ):
		p = get_untried_piece( slotno )
		if p==12: break
		fit = try_piece( p, slotno )
		if fit:
			place_piece( p, nextrot, slotno )
			pieceno[slotno] = p
			rotation[slotno] = nextrot
			slotno = slotno+1
			break
		else:
			tried[slotno][p] = True
		if not fit:
			reset_unused_pieces( slotno )
			slotno = slotno - 1
			if slotno<0: slotno = 0
			undraw_piece( slotno )
	return True


# -----------------------------------------------------------------------------
def get_next_empty_spot():	
	global xempty, yempty
	
	for w in range(boardWIDTH):
		for h in range(boardHEIGHT):
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
			if x<0 or y<0 or x>=boardWIDTH or y>=boardHEIGHT:
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
	#gotoxy( X0+xempty*2, Y0+yempty )
	#xx = boardX0+xempty*2*tileWIDTH
	#yy = boardY0+yempty*tileHEIGHT
	#pygame.draw.rect(window, RED, (0,0,tileWIDTH,tileHEIGHT),2)
	#pygame.draw.rect(window, WHITE, (xx,yy,xx+tileWIDTH,yy+tileHEIGHT),1)
	#print(colour[s%COLOURS]+'██')

	for i in range(4):
		x = xempty+piece[n].x[r][i]
		y = yempty+piece[n].y[r][i]
		board[x][y] = 1
		#gotoxy( X0+x*2, Y0+y )
		#print(colour[s%COLOURS]+'██')

	piece[n].used = True
	return
			

# -----------------------------------------------------------------------------
def undraw_piece( s ):

	x = xplace[s]
	y = yplace[s]
	board[x][y] = 0	
	#gotoxy( X0+x*2, Y0+y )
	print('  ')
	n = pieceno[s]
	r = rotation[s]

	for i in range(4):
		x = xplace[s]+piece[n].x[r][i]
		y = yplace[s]+piece[n].y[r][i]
		board[x][y] = 0
		#gotoxy( X0+x*2, Y0+y )
		print('  ')

	piece[n].used = False
	tried[s][n] = True
	return
	
	
# -----------------------------------------------------------------------------
def disp_info(pno,sno,rno):

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

	return


# -----------------------------------------------------------------------------
def end_game( elapsed ):
	
	print('DONE in', elapsed )
			

# =============================================================================
# Program Start
initialize()	
	
# set up pygame
pygame.init()
pygame.mixer.pre_init(44100, -16, 2, 2048) # setup mixer to avoid sound lag
#pygame.mixer.init(frequency=22050, size=-16, channels=2, buffer=512)
mainClock = pygame.time.Clock() 

# set up the window
window = pygame.display.set_mode((windowWIDTH, windowHEIGHT+windowTOP), 0, windowColourDepth)

# set up sprite list
#brick_list = pygame.sprite.RenderPlain()
#all_sprites_list = pygame.sprite.RenderPlain()

# set up fonts
basicFont = pygame.font.SysFont(None, 24)


# set up light
#light = pygame.image.load('light.png').convert()
#light.set_colorkey(WHITE)
#lightPos = pygame.Rect(100, 100, tileWIDTH-1, tileHEIGHT-1)
#window.blit(light, lightPos)

# set up maze
#setup_maze()

# set up key & location of the key
#key = KeySprite()
#while(True):
#    row = random.randrange(1,tileCOUNT-1)
#    col = random.randrange(1,tileCOUNT-1)
#    if maze[row][col]==0:
#        maze[row][col] = KEY
#        break  
#key.rect.x = col*tileWIDTH
#key.rect.y = row*tileHEIGHT+windowTOP
#all_sprites_list.add(key)

# set up player
#player = pygame.image.load('player.png').convert()
#player.set_colorkey(WHITE)
#while(True):
#    playerRow = random.randrange(1,tileCOUNT-1)
#    playerCol = random.randrange(1,tileCOUNT-1)
#    if maze[playerRow][playerCol]==0:
#        break  
#x = playerCol*tileWIDTH
#y = playerRow*tileHEIGHT+windowTOP
#playerPos = pygame.Rect(x, y, tileWIDTH-1, tileHEIGHT-1)

# set up sound effects
#game_start = load_sound('creepy_ambient.wav')
#fanfare = load_sound('fanfare2.wav')
#footstep = load_sound('onestep.wav')
#clang = load_sound('clang.wav')
#door_open = load_sound('door_open.wav')
#laugh = load_sound('laugh.wav')

clock = pygame.time.Clock()             # use pygame clock
timeout = time.time() + PLAYTIME        # set timeout
score = 0
hiscore = 0

main_loop()
pygame.quit()
sys.exit()

#
# End of program
# =============================================================================





