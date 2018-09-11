#!/usr/bin/python 
from __future__ import print_function  
# Using Python 3 (should also run in Python 2)
"""
-------------------------------------------------------------------------------
	Pentominos 
	A.B.Sayuti H.M.Saman

	A puzzle-solving program. Originally Pentominos for commodore computers
	by Jim Butterfield, Compute! May 1984

	0.29	23-10-15	Trying to use "GUI" for input instead of console
						input
	0.28	22-10-15	It's working now. Yeay... Nope... There's a BIG bug
						.. Piece 'R' was repeated 3 times!!!
						Adding more stuff to it
	0.27	21-10-15	There's a bug (or two), it did not turn back when 
						it reached the end but the pieces did not fit.
						I think it just checked that it reached the end but
						NOT whether ther board is full. :((
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

# Brick tile's size
tileWIDTH   	= 24
tileHEIGHT  	= 24

# Game window's size/colours
windowWidth 	= 24*tileWIDTH
windowHeight 	= 16*tileHEIGHT
windowTOP   	= tileHEIGHT		# for the text at top
windowColourDepth = 32

PLAYTIME		= 100               # 100 seconds? I don't know what this is for
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
board 		= [[-1 for y in range(6)] for x in range(20)] 
							# The board max height and width
#X0			= 10			# X origin in the board
#Y0			= 5				# Y origin in the board	

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

# =============================================================================
# Main Loop

def main_loop():
	
	slotno = 0
	start_time = time.time()
	
	while slotno < 12:
		for event in pygame.event.get():
			if event.type == QUIT: return
		full = get_next_empty_spot()		
		if full:
			return False
		while not all_pieces_tried( slotno ):
			p = get_untried_piece( slotno )
			if p==-1: break
			fit = try_piece( p, slotno )
			if fit:
				place_piece( p, nextrot, slotno )
				pieceno[slotno] = p
				rotation[slotno] = nextrot
				slotno = slotno + 1
				break
			else:
				tried[slotno][p] = True
		if not fit:
			reset_unused_pieces( slotno )
			slotno = slotno - 1
			if slotno<0: slotno = 0
			undraw_piece( slotno )	
		display_window( slotno )
		time.sleep(0.01)
	
	elapsed_time = time.time() - start_time
	end_program( elapsed_time )
	
	while True:
		for event in pygame.event.get():
			if event.type == QUIT: return


# -----------------------------------------------------------------------------
def display_window( slots ):
	
	window.fill(pygame.Color('black'))
	# The board
	xx = boardWIDTH*tileWIDTH
	yy = boardHEIGHT*tileHEIGHT
	pygame.draw.rect(window, pygame.Color('white'), (boardX0-2,boardY0-2,xx+4,yy+4),2)
	# The tiles/pieces
	for y in range(boardHEIGHT):
		for x in range(boardWIDTH):
			x1 = x*tileWIDTH + boardX0
			y1 = y*tileHEIGHT + boardY0
			n = board[x][y]
			tilecolour = colour[n+2]
			if n>-1:
				pygame.draw.rect(window, tilecolour, [x1,y1,tileWIDTH,tileHEIGHT])
				pygame.draw.rect(window, pygame.Color('white'), [x1,y1,tileWIDTH,tileHEIGHT],1)
			else:
				pygame.draw.rect(window, pygame.Color('gray'), [x1+1,y1+1,tileWIDTH-2,tileHEIGHT-2],1)
	# Header text
	txtInfo = basicFont.render('PENTOMINOES', ANTI_ALIASED, pygame.Color('white'), pygame.Color('black'))
	txtInfoPos = txtInfo.get_rect()
	txtInfoPos.midtop = window.get_rect().midtop
	window.blit(txtInfo, txtInfoPos)
	# Other text
	text = ""
	for i in range(slots):
		n = pieceno[i]
		#text = text + str(n) + ' '
		text = text + piece[n].name + ' ' 
	txtInfo = basicFont.render( text, ANTI_ALIASED, pygame.Color('yellow'), pygame.Color('black'))
	txtInfoPos = txtInfo.get_rect()
	txtInfoPos.midtop = (windowWidth/2, (boardHEIGHT+3)*tileHEIGHT) #window.get_rect().midbottom
	window.blit(txtInfo, txtInfoPos)
	# Show the window/display
	pygame.display.flip()


# -----------------------------------------------------------------------------
def get_next_empty_spot():	
	global xempty, yempty
	
	for w in range(boardWIDTH):
		for h in range(boardHEIGHT):
			if board[w][h]==-1:
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
	return -1


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
			elif board[x][y]!=-1: 
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
	board[xempty][yempty] = s

	for i in range(4):
		x = xempty+piece[n].x[r][i]
		y = yempty+piece[n].y[r][i]
		board[x][y] = s

	piece[n].used = True
	return
			

# -----------------------------------------------------------------------------
def undraw_piece( s ):

	x = xplace[s]
	y = yplace[s]
	board[x][y] = -1
	n = pieceno[s]
	r = rotation[s]

	for i in range(4):
		x = xplace[s]+piece[n].x[r][i]
		y = yplace[s]+piece[n].y[r][i]
		board[x][y] = -1

	piece[n].used = False
	tried[s][n] = True
	return
	
	
# -----------------------------------------------------------------------------
def disp_info(pno,sno,rno):

	print('S',sno,' P',piece[pno].name,' R',rno)

	
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
	
	global colour
	colour		= []
	colour.append(pygame.Color('black'))
	colour.append(pygame.Color('blue'))
	colour.append(pygame.Color('blueviolet'))
	colour.append(pygame.Color('brown'))
	colour.append(pygame.Color('cadetblue'))
	colour.append(pygame.Color('aquamarine'))
	colour.append(pygame.Color('turquoise'))
	colour.append(pygame.Color('gold'))
	colour.append(pygame.Color('orange'))
	colour.append(pygame.Color('burlywood'))
	colour.append(pygame.Color('cyan'))
	colour.append(pygame.Color('violet'))
	colour.append(pygame.Color('magenta'))
	colour.append(pygame.Color('pink'))
	colour.append(pygame.Color('firebrick'))
	colour.append(pygame.Color('darkolivegreen'))

	global c64colour
	c64colour	= []
	c64colour.append( (0, 0, 0) )		# black
	c64colour.append( (255, 255, 255) )	# white
	c64colour.append( (136, 0, 0) )		# red
	c64colour.append( (170, 255, 238) )	# cyan
	c64colour.append( (204, 68, 204) )	# violet
	c64colour.append( (0, 204, 85) )	# green
	c64colour.append( (0, 0, 170) )		# blue
	c64colour.append( (238, 238, 119) )	# yellow
	c64colour.append( (221, 136, 85) )	# orange
	c64colour.append( (102, 68, 0) )	# brown
	c64colour.append( (255, 119, 119) )	# light red
	c64colour.append( (51, 51, 51) )	# grey 1
	c64colour.append( (119, 119, 119) )	# grey 2
	c64colour.append( (170, 255, 102) )	# light green
	c64colour.append( (0, 136, 255) )	# light blue
	c64colour.append( (187,187,187) )	# grey 3

	return

# -----------------------------------------------------------------------------
def get_user_selection():

	global boardX0, boardY0, boardHEIGHT, boardWIDTH

	while True:
		for event in pygame.event.get():
			if event.type == QUIT: return
			switch( eve
			elif event.type == MOUSEBUTTONDOWN
		text = "3\n 4\n 5\n 6"
		txtInfo = basicFont.render( text, ANTI_ALIASED, pygame.Color('yellow'), pygame.Color('black'))
		txtInfoPos = txtInfo.get_rect()
		txtInfoPos.center = window.get_rect().center
		window.blit(txtInfo, txtInfoPos)
		# Show the window/display
		pygame.display.flip()

	boardHEIGHT	= 3
	boardWIDTH = int(60/boardHEIGHT)
	boardX0	= (windowWidth - boardWIDTH*tileWIDTH)/2
	boardY0	= 2*tileHEIGHT
	
	return

# -----------------------------------------------------------------------------
def get_board_size():

	global boardX0, boardY0, boardHEIGHT, boardWIDTH

	print('PENTOMINOES')
	while True:
		s = input('Board size: 3, 4, 5 or 6? >> ')
		bh = int(s)
		if bh==3 or bh==4 or bh==5 or bh==6:
			boardHEIGHT	= bh
			boardWIDTH = int(60/boardHEIGHT)
			boardX0	= (windowWidth - boardWIDTH*tileWIDTH)/2
			boardY0	= 2*tileHEIGHT
			print(boardHEIGHT,boardWIDTH,boardX0,boardY0)
			break
	return

# -----------------------------------------------------------------------------
def end_program( elapsed ):
	
	text = 'DONE in ' + str(elapsed )
	txtInfo = basicFont.render( text, ANTI_ALIASED, pygame.Color('yellow'), pygame.Color('black'))
	txtInfoPos = txtInfo.get_rect()
	txtInfoPos.midtop = (windowWidth/2, (boardHEIGHT+4)*tileHEIGHT) #window.get_rect().midbottom
	window.blit(txtInfo, txtInfoPos)
	pygame.display.flip()
			

# =============================================================================
# Program Start
# =============================================================================
initialize()
#get_board_size()
	
# set up pygame
pygame.init()
pygame.mixer.pre_init(44100, -16, 2, 2048) # setup mixer to avoid sound lag
#pygame.mixer.init(frequency=22050, size=-16, channels=2, buffer=512)
mainClock = pygame.time.Clock() 

# set up the window
window = pygame.display.set_mode((windowWidth, windowHeight+windowTOP), 0, windowColourDepth)
pygame.display.set_caption('Pentominoes', '')

# set up fonts
basicFont = pygame.font.SysFont(None, 24)

#clock = pygame.time.Clock()             # use pygame clock
#timeout = time.time() + PLAYTIME        # set timeout

get_user_selection()

main_loop()
pygame.quit()
sys.exit()

# =============================================================================
# End of program
# =============================================================================

"""
Valid names for pygame.Color('xxxxx')

[https://sites.google.com/site/meticulosslacker/pygame-thecolors]

'aliceblue', 'antiquewhite', 'antiquewhite1', 'antiquewhite2', 
'antiquewhite3', 'antiquewhite4', 'aquamarine', 'aquamarine1', 'aquamarine2',
'aquamarine3', 'aquamarine4', 'azure', 'azure1', 'azure2', 'azure3', 
'azure4', 'beige', 'bisque', 'bisque1', 'bisque2', 'bisque3', 'bisque4', 
'black', 'blanchedalmond', 'blue', 'blue1', 'blue2', 'blue3', 'blue4', 
'blueviolet', 'brown', 'brown1', 'brown2', 'brown3', 'brown4', 'burlywood', 
'burlywood1', 'burlywood2', 'burlywood3', 'burlywood4', 'cadetblue', 
'cadetblue1', 'cadetblue2', 'cadetblue3', 'cadetblue4', 'chartreuse', 
'chartreuse1', 'chartreuse2', 'chartreuse3', 'chartreuse4', 'chocolate', 
'chocolate1', 'chocolate2', 'chocolate3', 'chocolate4', 'coral', 'coral1', 
'coral2', 'coral3', 'coral4', 'cornflowerblue', 'cornsilk', 'cornsilk1', 
'cornsilk2', 'cornsilk3', 'cornsilk4', 'cyan', 'cyan1', 'cyan2', 'cyan3', 
'cyan4', 'darkblue', 'darkcyan', 'darkgoldenrod', 'darkgoldenrod1', 
'darkgoldenrod2', 'darkgoldenrod3', 'darkgoldenrod4', 'darkgray', 
'darkgreen', 'darkgrey', 'darkkhaki', 'darkmagenta', 'darkolivegreen', 
'darkolivegreen1', 'darkolivegreen2', 'darkolivegreen3', 'darkolivegreen4', 
'darkorange', 'darkorange1', 'darkorange2', 'darkorange3', 'darkorange4', 
'darkorchid', 'darkorchid1', 'darkorchid2', 'darkorchid3', 'darkorchid4', 
'darkred', 'darksalmon', 'darkseagreen', 'darkseagreen1', 'darkseagreen2', 
'darkseagreen3', 'darkseagreen4', 'darkslateblue', 'darkslategray', 
'darkslategray1', 'darkslategray2', 'darkslategray3', 'darkslategray4', 
'darkslategrey', 'darkturquoise', 'darkviolet', 'deeppink', 'deeppink1', 
'deeppink2', 'deeppink3', 'deeppink4', 'deepskyblue', 'deepskyblue1', 
'deepskyblue2', 'deepskyblue3', 'deepskyblue4', 'dimgray', 'dimgrey', 
'dodgerblue', 'dodgerblue1', 'dodgerblue2', 'dodgerblue3', 'dodgerblue4', 
'firebrick', 'firebrick1', 'firebrick2', 'firebrick3', 'firebrick4', 
'floralwhite', 'forestgreen', 'gainsboro', 'ghostwhite', 'gold', 'gold1', 
'gold2', 'gold3', 'gold4', 'goldenrod', 'goldenrod1', 'goldenrod2', 
'goldenrod3', 'goldenrod4', 'gray', 'gray0', 'gray1', 'gray10', 'gray100', 
'gray11', 'gray12', 'gray13', 'gray14', 'gray15', 'gray16', 'gray17', 
'gray18', 'gray19', 'gray2', 'gray20', 'gray21', 'gray22', 'gray23', 
'gray24', 'gray25', 'gray26', 'gray27', 'gray28', 'gray29', 'gray3', 
'gray30', 'gray31', 'gray32', 'gray33', 'gray34', 'gray35', 'gray36', 
'gray37', 'gray38', 'gray39', 'gray4', 'gray40', 'gray41', 'gray42', 
'gray43', 'gray44', 'gray45', 'gray46', 'gray47', 'gray48', 'gray49', 
'gray5', 'gray50', 'gray51', 'gray52', 'gray53', 'gray54', 'gray55', 
'gray56', 'gray57', 'gray58', 'gray59', 'gray6', 'gray60', 'gray61', 
'gray62', 'gray63', 'gray64', 'gray65', 'gray66', 'gray67', 'gray68', 
'gray69', 'gray7', 'gray70', 'gray71', 'gray72', 'gray73', 'gray74', 
'gray75', 'gray76', 'gray77', 'gray78', 'gray79', 'gray8', 'gray80', 
'gray81', 'gray82', 'gray83', 'gray84', 'gray85', 'gray86', 'gray87', 
'gray88', 'gray89', 'gray9', 'gray90', 'gray91', 'gray92', 'gray93', 
'gray94', 'gray95', 'gray96', 'gray97', 'gray98', 'gray99', 'green', 
'green1', 'green2', 'green3', 'green4', 'greenyellow', 'grey', 'grey0', 
'grey1', 'grey10', 'grey100', 'grey11', 'grey12', 'grey13', 'grey14', 
'grey15', 'grey16', 'grey17', 'grey18', 'grey19', 'grey2', 'grey20', 
'grey21', 'grey22', 'grey23', 'grey24', 'grey25', 'grey26', 'grey27', 
'grey28', 'grey29', 'grey3', 'grey30', 'grey31', 'grey32', 'grey33', 
'grey34', 'grey35', 'grey36', 'grey37', 'grey38', 'grey39', 'grey4', 
'grey40', 'grey41', 'grey42', 'grey43', 'grey44', 'grey45', 'grey46', 
'grey47', 'grey48', 'grey49', 'grey5', 'grey50', 'grey51', 'grey52', 
'grey53', 'grey54', 'grey55', 'grey56', 'grey57', 'grey58', 'grey59', 
'grey6', 'grey60', 'grey61', 'grey62', 'grey63', 'grey64', 'grey65', 
'grey66', 'grey67', 'grey68', 'grey69', 'grey7', 'grey70', 'grey71', 
'grey72', 'grey73', 'grey74', 'grey75', 'grey76', 'grey77', 'grey78', 
'grey79', 'grey8', 'grey80', 'grey81', 'grey82', 'grey83', 'grey84', 
'grey85', 'grey86', 'grey87', 'grey88', 'grey89', 'grey9', 'grey90', 
'grey91', 'grey92', 'grey93', 'grey94', 'grey95', 'grey96', 'grey97', 
'grey98', 'grey99', 'honeydew', 'honeydew1', 'honeydew2', 'honeydew3', 
'honeydew4', 'hotpink', 'hotpink1', 'hotpink2', 'hotpink3', 'hotpink4', 
'indianred', 'indianred1', 'indianred2', 'indianred3', 'indianred4', 'ivory',
'ivory1', 'ivory2', 'ivory3', 'ivory4', 'khaki', 'khaki1', 'khaki2', 
'khaki3', 'khaki4', 'lavender', 'lavenderblush', 'lavenderblush1', 
'lavenderblush2', 'lavenderblush3', 'lavenderblush4', 'lawngreen', 
'lemonchiffon', 'lemonchiffon1', 'lemonchiffon2', 'lemonchiffon3', 
'lemonchiffon4', 'lightblue', 'lightblue1', 'lightblue2', 'lightblue3', 
'lightblue4', 'lightcoral', 'lightcyan', 'lightcyan1', 'lightcyan2', 
'lightcyan3', 'lightcyan4', 'lightgoldenrod', 'lightgoldenrod1', 
'lightgoldenrod2', 'lightgoldenrod3', 'lightgoldenrod4', 
'lightgoldenrodyellow', 'lightgray', 'lightgreen', 'lightgrey', 'lightpink', 
'lightpink1', 'lightpink2', 'lightpink3', 'lightpink4', 'lightsalmon', 
'lightsalmon1', 'lightsalmon2', 'lightsalmon3', 'lightsalmon4', 
'lightseagreen', 'lightskyblue', 'lightskyblue1', 'lightskyblue2', 
'lightskyblue3', 'lightskyblue4', 'lightslateblue', 'lightslategray', 
'lightslategrey', 'lightsteelblue', 'lightsteelblue1', 'lightsteelblue2', 
'lightsteelblue3', 'lightsteelblue4', 'lightyellow', 'lightyellow1', 
'lightyellow2', 'lightyellow3', 'lightyellow4', 'limegreen', 'linen', 
'magenta', 'magenta1', 'magenta2', 'magenta3', 'magenta4', 'maroon', 
'maroon1', 'maroon2', 'maroon3', 'maroon4', 'mediumaquamarine', 'mediumblue',
'mediumorchid', 'mediumorchid1', 'mediumorchid2', 'mediumorchid3', 
'mediumorchid4', 'mediumpurple', 'mediumpurple1', 'mediumpurple2', 
'mediumpurple3', 'mediumpurple4', 'mediumseagreen', 'mediumslateblue', 
'mediumspringgreen', 'mediumturquoise', 'mediumvioletred', 'midnightblue', 
'mintcream', 'mistyrose', 'mistyrose1', 'mistyrose2', 'mistyrose3', 
'mistyrose4', 'moccasin', 'navajowhite', 'navajowhite1', 'navajowhite2', 
'navajowhite3', 'navajowhite4', 'navy', 'navyblue', 'oldlace', 'olivedrab', 
'olivedrab1', 'olivedrab2', 'olivedrab3', 'olivedrab4', 'orange', 'orange1', 
'orange2', 'orange3', 'orange4', 'orangered', 'orangered1', 'orangered2', 
'orangered3', 'orangered4', 'orchid', 'orchid1', 'orchid2', 'orchid3', 
'orchid4', 'palegoldenrod', 'palegreen', 'palegreen1', 'palegreen2', 
'palegreen3', 'palegreen4', 'paleturquoise', 'paleturquoise1', 
'paleturquoise2', 'paleturquoise3', 'paleturquoise4', 'palevioletred', 
'palevioletred1', 'palevioletred2', 'palevioletred3', 'palevioletred4', 
'papayawhip', 'peachpuff', 'peachpuff1', 'peachpuff2', 'peachpuff3', 
'peachpuff4', 'peru', 'pink', 'pink1', 'pink2', 'pink3', 'pink4', 'plum', 
'plum1', 'plum2', 'plum3', 'plum4', 'powderblue', 'purple', 'purple1', 
'purple2', 'purple3', 'purple4', 'red', 'red1', 'red2', 'red3', 'red4', 
'rosybrown', 'rosybrown1', 'rosybrown2', 'rosybrown3', 'rosybrown4', 
'royalblue', 'royalblue1', 'royalblue2', 'royalblue3', 'royalblue4', 
'saddlebrown', 'salmon', 'salmon1', 'salmon2', 'salmon3', 'salmon4', 
'sandybrown', 'seagreen', 'seagreen1', 'seagreen2', 'seagreen3', 'seagreen4',
'seashell', 'seashell1', 'seashell2', 'seashell3', 'seashell4', 'sienna', 
'sienna1', 'sienna2', 'sienna3', 'sienna4', 'skyblue', 'skyblue1', 
'skyblue2', 'skyblue3', 'skyblue4', 'slateblue', 'slateblue1', 'slateblue2', 
'slateblue3', 'slateblue4', 'slategray', 'slategray1', 'slategray2', 
'slategray3', 'slategray4', 'slategrey', 'snow', 'snow1', 'snow2', 'snow3', 
'snow4', 'springgreen', 'springgreen1', 'springgreen2', 'springgreen3', 
'springgreen4', 'steelblue', 'steelblue1', 'steelblue2', 'steelblue3', 
'steelblue4', 'tan', 'tan1', 'tan2', 'tan3', 'tan4', 'thistle', 'thistle1', 
'thistle2', 'thistle3', 'thistle4', 'tomato', 'tomato1', 'tomato2', 
'tomato3', 'tomato4', 'turquoise', 'turquoise1', 'turquoise2', 'turquoise3', 
'turquoise4', 'violet', 'violetred', 'violetred1', 'violetred2', 
'violetred3', 'violetred4', 'wheat', 'wheat1', 'wheat2', 'wheat3', 'wheat4', 
'white', 'whitesmoke', 'yellow', 'yellow1', 'yellow2', 'yellow3', 'yellow4', 
'yellowgreen'
"""



