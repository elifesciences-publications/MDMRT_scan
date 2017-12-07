#!/usr/bin/env python

import pygame, sys,os, random
import numpy as np
from pygame.locals import * 

def instructions():
    screen.fill((0, 0, 0))
    text1=font.render("As explained, please bid on each of the following items",1,white)
    text2=font.render("by clicking on the amount on the bar below",1,white)
    text3=font.render("Please click to continue..",1,white)
    textpos1=text1.get_rect(centerx=width/2, centery=height/2-40)
    textpos2=text2.get_rect(centerx=width/2, centery=height/2)
    textpos3=text3.get_rect(centerx=width/2, centery=height/2+60)
    screen.blit(text1, textpos1)
    screen.blit(text2, textpos2)
    screen.blit(text3, textpos3)
    pygame.display.flip()
    while 1:
        event=pygame.event.poll()
        if event.type==MOUSEBUTTONDOWN:
            pygame.event.clear()
            break

def instructions2():
    screen.fill((0, 0, 0))
    text1=font.render("You will now have a chance to change your bid if you would like.",1,white)
    text2=font.render("You can choose to keep your original bid, or change it.",1,white)
    text3=font.render("Please click to continue..",1,white)
    textpos1=text1.get_rect(centerx=width/2, centery=height/2-40)
    textpos2=text2.get_rect(centerx=width/2, centery=height/2)
    textpos3=text3.get_rect(centerx=width/2, centery=height/2+60)
    screen.blit(text1, textpos1)
    screen.blit(text2, textpos2)
    screen.blit(text3, textpos3)
    pygame.display.flip()
    while 1:
        event=pygame.event.poll()
        if event.type==MOUSEBUTTONDOWN:
            pygame.event.clear()
            break
        
def display_trial(stim,pos):
    file = os.path.join("stim",stim)
    pic=pygame.image.load(file).convert()
    screen.fill((0, 0, 0))
    pygame.draw.rect(screen, white, rect)
    text=font.render("$0                 $1                 $2                 $3",1,white)
    textpos=text.get_rect(centerx=width/2, centery=height-30)
    screen.blit(text, textpos)
    screen.blit(pic,pic.get_rect(centerx=width/2, centery=height/2))
    draw_marker(pos)
    pygame.display.flip()

def display_trial2(stim,price,yescol,nocol):
    file = os.path.join("stim",stim)
    pic=pygame.image.load(file).convert()
    screen.fill((0, 0, 0))
    #pygame.draw.rect(screen, white, rect)
    text1=font.render("You bid $" + str(round(price,2)),1,white)
    text2=font.render("Would you like to change your bid?",1,white)
    text3=font.render("YES",1,yescol)
    text4=font.render("NO",1,nocol)
    #text1pos=text1.get_rect(centerx=width/2, centery=height-200)
    text1pos=text1.get_rect(centerx=width/2, centery=height-150)
    #text2pos=text2.get_rect(centerx=width/2, centery=height-150)
    text2pos=text2.get_rect(centerx=width/2, centery=height-100)    
    #text3pos=text3.get_rect(centerx=width/2-150, centery=height-100)
    text3pos=text3.get_rect(centerx=width/2-150, centery=height-50)
    #text4pos=text4.get_rect(centerx=width/2+150, centery=height-100)
    text4pos=text4.get_rect(centerx=width/2+150, centery=height-50)
    screen.blit(text1, text1pos)
    screen.blit(text2, text2pos)
    screen.blit(text3, text3pos)
    screen.blit(text4, text4pos)
    screen.blit(pic,pic.get_rect(centerx=width/2, centery=height/2))
    #draw_marker(pos)
    pygame.display.flip()

def get_response2(stim,price):
    pygame.event.clear()
    while 1:
        event=pygame.event.poll()
        pos = pygame.mouse.get_pos()
        #if pos[0] > width/2-180 and pos[0] < width/2-100 and pos[1]>height-120 and pos[1]<height-80:
        if pos[0] > width/2-180 and pos[0] < width/2-100 and pos[1]>height-70 and pos[1]<height-30:
            display_trial2(stim,price,yellow,white)
        #if pos[0] > width/2+100 and pos[0] < width/2+180 and pos[1]>height-120 and pos[1]<height-80:
        if pos[0] > width/2+100 and pos[0] < width/2+180 and pos[1]>height-70 and pos[1]<height-30:
            display_trial2(stim,price,white,yellow)
        if pygame.key.get_pressed()[K_ESCAPE]: #and pygame.key.get_pressed()[K_BACKQUOTE]:
            raise SystemExit
        if pygame.key.get_pressed()[K_LSHIFT] and pygame.key.get_pressed()[K_EQUALS]:
            save_image()
        if event.type==MOUSEBUTTONUP:
            pos = pygame.mouse.get_pos()
            #if pos[0] > width/2-180 and pos[0] < width/2-100 and pos[1]>height-120 and pos[1]<height-80:
            if pos[0] > width/2-180 and pos[0] < width/2-100 and pos[1]>height-70 and pos[1]<height-30:
                answer=1
                return answer
                break
            #elif  pos[0] > width/2+100 and pos[0] < width/2+180 and pos[1]>height-120 and pos[1]<height-80:
            elif  pos[0] > width/2+100 and pos[0] < width/2+180 and pos[1]>height-70 and pos[1]<height-30:
                answer=2
                return answer
                break
            
def draw_marker(pos):
    marker = pygame.Rect(pos-2,(height-75),4,30)
    pygame.draw.rect(screen, blue, marker)
    pygame.display.flip()

def get_response():
    pygame.event.clear()
    while 1:
        event=pygame.event.poll()
        pos = pygame.mouse.get_pos()
        if pos[0] > width/2-225 and pos[0] < width/2+225 and pos[1]>height-70 and pos[1]<height-50:
            display_trial(stim,pos[0])
        
        
        if pygame.key.get_pressed()[K_ESCAPE]: #and pygame.key.get_pressed()[K_BACKQUOTE]:
            raise SystemExit
        if pygame.key.get_pressed()[K_LSHIFT] and pygame.key.get_pressed()[K_EQUALS]:
            save_image()
        if event.type==MOUSEBUTTONUP:
            pos = pygame.mouse.get_pos()
            if pos[0] > width/2-225 and pos[0] < width/2+225 and pos[1]>height-70 and pos[1]<height-50:
                bet=(pos[0]-(width/2-225))/150.0
                return bet
                break

def write_header():
    sd=("Subjid"+'\t'"Trial"+'\t'+"StimName"+'\t'+"Bid"+'\t'+"RT"+'\n')
    sepname=subjid+"_food_BDM1.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()

def write_header2():
    sd=("Subjid"+'\t'"Trial"+'\t'+"StimName"+'\t'+"Bid"+'\t'+"RT"+'\n')
    sepname=subjid+"_food_BDM2.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()
    
    
def write_header2():
    sd=("Subjid"+'\t'"Trial"+'\t'+"StimName"+'\t'+"Bid"+'\t'+"RT"+'\n')
    sepname=subjid+"_food_BDM2.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()
    
def write_response(trial,bet,rt):
    sd=(subjid+'\t'+str(trial)+'\t'+stim+'\t'+str(bet)+'\t'+str(rt)+'\n')
    sepname=subjid+"_food_BDM1.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()

def write_response2(trial,bet,rt):
    sd=(subjid+'\t'+str(trial)+'\t'+stim+'\t'+str(bet)+'\t'+str(rt)+'\n')
    sepname=subjid+"_food_BDM2.txt"
    sep_path=os.path.join("Output",sepname)
    sepfile=open(sep_path, "a")
    sepfile.write(sd)
    sepfile.close()

def intertrial():
    screen.fill((0, 0, 0))
    text=font2.render("+",1,white)
    textpos=text.get_rect(centerx=width/2, centery=height/2)
    screen.blit(text, textpos)
    pygame.display.flip()
    pygame.time.wait(1000)

def end():
    screen.fill((0, 0, 0))
    text=font2.render("Thank you! Please get the experimenter.",1,yellow)
    textpos=text.get_rect(centerx=width/2, centery=height/2)
    screen.blit(text, textpos)
    pygame.display.flip()
    pygame.time.wait(5000)

subjid=sys.argv[1]

pygame.init()

# Set up variables
screen = pygame.display.set_mode((1280,800), FULLSCREEN)
#screen = pygame.display.set_mode((1440,900),FULLSCREEN)
white = (255, 255, 255)
yellow = (255, 255, 0)
blue=(0,0,255)
height=screen.get_height()
width=screen.get_width()
font = pygame.font.Font(None, 36)
font2 = pygame.font.Font(None, 72)
rect = pygame.Rect((width/2-225),(height-70),450,20)


#stimulus list of 60 items
stimlist=["100grand_small.bmp", "3Musketeers.bmp", "Almondjoy.bmp", "AnimalCrackers.bmp", "BabyRuth.bmp", "Butterfinger.bmp", "Cheese_PeanutButterCrackers.bmp", "CheesyDoritos.bmp", "Cheetos.bmp", "Cheezits.bmp", "ChipsAhoy_small.bmp", "Chocolate_mm.bmp", "Crunch.bmp", "Doritosranch.bmp", "Dots_one.bmp", "FamousAmos_small.bmp", "FigNewton_small.bmp", "FlamingCheetos.bmp", "Fritos.bmp", "Funyuns_small.bmp", "Ghiradelli_milk.bmp", "Ghiradelli_milk_Almonds.bmp", "Goldfish.bmp", "Granolabar.bmp", "Hersheykisses.bmp", "Hersheymilk_several.bmp", "Jollyranchergreen.bmp", "Keeblerfudgestripes.bmp", "KitKat_small.bmp", "Laffytaffyred_one.bmp", "Laysclassic.bmp", "Lollipopred.bmp", "Milano.bmp", "Milkduds.bmp", "MilkyWay.bmp", "MrGoodbar.bmp", "MrsFields.bmp", "Nutterbutter.bmp", "Oreos.bmp", "PayDay.bmp", "PeanutMMs.bmp", "PopTartsStrawberry.bmp", "PringlesRed.bmp", "Reeses.bmp", "RiceKrispyTreat_small.bmp", "Riprolls.bmp", "RitzBitz2.bmp", "Ruffles.bmp", "Skittles.bmp", "Slimjim.bmp", "Snickers.bmp", "SourSkittles.bmp", "Sourpatch.bmp", "Starburst.bmp", "TeddyGrahamschocolate.bmp", "Toberlorone.bmp", "TootsieRolls.bmp", "Twix.bmp", "Whatchamacallit.bmp", "WheatThins.bmp"] 

#stimlist=["100grand_small.bmp", "3Musketeers.bmp", "Almondjoy.bmp", "AnimalCrackers.bmp", "Butterfinger.bmp", "CheesyDoritos.bmp", "Cheetos.bmp", "Cheezits.bmp", "ChipsAhoy_small.bmp", "Chocolate_mm.bmp", "Crunch.bmp", "FamousAmos_small.bmp", "FlamingCheetos.bmp", "Fritos.bmp", "Ghiradelli_milk.bmp", "Goldfish.bmp", "Hersheykisses.bmp", "Keeblerfudgestripes.bmp", "KitKat_small.bmp", "Laysclassic.bmp", "Milano.bmp", "MilkyWay.bmp", "MrsFields.bmp", "Oreos.bmp", "PeanutMMs.bmp", "PopTartsStrawberry.bmp", "PringlesRed.bmp", "Reeses.bmp", "RiceKrispyTreat_small.bmp", "Ruffles.bmp", "Skittles.bmp", "Snickers.bmp", "Sourpatch.bmp", "Starburst.bmp", "Toberlorone.bmp",  "Twix.bmp"] 

random.shuffle(stimlist)

trial=1

instructions()
write_header()
for stim in stimlist:

    pygame.mouse.set_pos(width/2,height/2)

    stimonset=pygame.time.get_ticks()
    if random.random()>.5:
        sign=1
    else:
        sign=-1
    markerpos=width/2+random.random()*225*sign
    display_trial(stim,markerpos)
  
    pygame.time.wait(500)
    
    bet=get_response()
    rt=pygame.time.get_ticks()-stimonset
    write_response(trial,bet,rt)
    
    intertrial()
    trial=trial+1


food=[]
price=[]
sepname=subjid+"_food_BDM1.txt"
sep_path=os.path.join("Output",sepname)
tmp=open(sep_path)
lines=tmp.readlines()
for i in np.arange(60)+1:
    line=lines[i].strip().split()
    food.append(line[2])
    price.append(line[3])
tmp.close()
food_shuf = []
price_shuf = []
index_shuf = list(range(len(food)))
random.shuffle(index_shuf)
for i in index_shuf:
    food_shuf.append(food[i])
    price_shuf.append(price[i])
instructions2()
write_header2()
trial=1
for stim in food_shuf:

    pygame.mouse.set_pos(width/2,height/2)
    display_trial2(stim,float(price_shuf[trial-1]),white,white)
    stimonset=pygame.time.get_ticks()
    answer=get_response2(stim,float(price_shuf[trial-1]))
    
    if answer == 1:
        pygame.mouse.set_pos(width/2,height/2)
        stimonset=pygame.time.get_ticks()
        if random.random()>.5:
            sign=1
        else:
            sign=-1
        markerpos=width/2+random.random()*225*sign
        display_trial(stim,markerpos)
        pygame.time.wait(500)
        bet=get_response()
        rt=pygame.time.get_ticks()-stimonset
    else:
        bet=float(price_shuf[trial-1])
        rt=pygame.time.get_ticks()-stimonset

    write_response2(trial,bet,rt)
    
    intertrial()
    trial=trial+1

end()
