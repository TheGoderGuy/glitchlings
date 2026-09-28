from px import *
import math
def eye2(s,x,y,w=3,h=4,iris='#4A3AA8',blink=False,ol='#231B3F'):
    if blink:
        for i in range(w): s.g[y+h-2,x+i]=ol
        s.g[y+h-3,x-1 if x>0 else x]=None if False else s.g[y+h-3,x]
        return
    for yy in range(h):
        for xx in range(w): s.g[y+yy,x+xx]=ol
    for yy in range(h//2,h):
        for xx in range(1,w): s.g[y+yy,x+xx]=iris
    s.g[y,x]='#FFFFFF'; s.g[y+1,x]='#FFFFFF'
    if w>=3: s.g[y,x+1]='#FFFFFF'
    s.g[y+h-1,x+w-1]=mix(iris,'#FFFFFF',.55)
def fox(blink=False):
    s=S(); B='#F2EEFF'
    # Schwanz mit Pixel-Spitze
    tail=s.m_ell(6,20,4.5,7.5)|s.m_ell(5,13,3.2,4)
    s.body(tail,B,vert=.3)
    ys,xs=np.mgrid[0:N,0:N]
    tip=tail&(ys<=12); s.body(tip,'#8FE8D0',vert=.1)
    for (x,y,c) in [(4,7,'#8FE8D0'),(2,5,'#FF9EC7'),(6,4,'#8FE8D0'),(1,8,'#B9E7FF'),(4,2,'#FF9EC7')]: s.px([(x,y)],c)
    # Körper sitzend
    body=s.m_ell(15.5,23,7.5,6)
    s.body(body,B)
    s.body(s.m_ell(17.5,24,3.5,4),'#FFFFFF',flat=True,dither=False)
    for x in (13,18): s.body(s.m_rect(x,25,x+3,30,1),B,vert=.5)
    s.px([(14,30),(15,30),(19,30),(20,30)],'#D9D2F2')
    # Ohren
    for (bx,tip_) in [((10,9),(9,0)),((18,8),(21,0))]:
        pass
    earB=s.m_poly([(8,10),(9,1),(14,7)]); earF=s.m_poly([(16,6),(21,0),(22,9)])
    s.body(earB,mix(B,'#B8AEE0',.3),vert=.1); s.body(earF,B,vert=.1)
    s.paint(s.m_poly([(10,8),(10,4),(12,7)]),'#FFB3D1'); s.paint(s.m_poly([(18,6),(20,3),(20,8)]),'#FFB3D1')
    # Kopf + Schnauze
    head=s.m_ell(15,12.5,8,6.8); s.body(head,B)
    snout=s.m_ell(21,15,4,2.8); s.body(snout,'#FFFFFF',vert=.3)
    s.px([(24,14),(25,14),(24,15)],'#3A2A5A')
    eye2(s,12,10,3,4,blink=blink); eye2(s,18,10,2,4,blink=blink)
    s.px([(10,15),(11,15)],'#FFB3D1')
    s.px([(21,17),(22,17),(23,16)],'#6B4A7A')
    # Pixel-Halsband
    s.px([(12,19),(13,19),(14,19),(15,19),(16,19),(17,19),(18,19)],'#8FE8D0'); s.px([(15,20)],'#FF7EB6')
    s.outline(); return s
def pup(blink=False):
    s=S(); B='#FF9A4A'
    # Flammenschwanz
    fl=s.m_poly([(8,24),(2,14),(5,17),(4,10),(8,16),(9,12),(11,21)])
    s.body(fl,'#FFCF4A',vert=-.1); s.body(s.m_poly([(8,23),(5,17),(8,18),(8,15),(10,21)]),'#FF6A2B',vert=0)
    body=s.m_ell(16,23,7.5,5.5); s.body(body,B)
    s.body(s.m_ell(18.5,24.5,3.5,3.5),'#FFE3C2',flat=True,dither=False)
    for x in (13,19): s.body(s.m_rect(x,25,x+3,30,1),B,vert=.5)
    s.px([(14,30),(15,30),(20,30),(21,30)],'#FFE3C2')
    head=s.m_ell(16,12.5,8.5,7); s.body(head,B)
    # Flammen-Schlappohren
    for side,cx in ((-1,8),(1,24)):
        ear=s.m_poly([(cx,8),(cx+side*4,6),(cx+side*5,11),(cx+side*3,10),(cx+side*4,15),(cx,13)])
        s.body(ear,'#FFCF4A' if side>0 else '#FFB23D',vert=0)
    s.body(s.m_poly([(14,6),(16,1),(17,5),(19,2),(19,7)]),'#FFCF4A',vert=0)
    muz=s.m_ell(20,16,4.5,3); s.body(muz,'#FFE3C2',vert=.3)
    s.px([(22,14),(23,14),(22,15),(23,15)],'#3A1A10')
    eye2(s,12,10,3,4,iris='#8A3A12',blink=blink); eye2(s,18,10,3,4,iris='#8A3A12',blink=blink)
    s.px([(19,18),(20,18),(21,19),(22,18)],'#7A2E12')
    if not blink: s.px([(21,19)],'#FF7E9E')
    s.px([(10,16),(11,16)],'#FF6A6A')
    s.outline(); return s
def axo(blink=False):
    s=S(); B='#8FD8F5'
    tail=s.m_poly([(4,20),(1,14),(9,17),(12,22)]); s.body(tail,mix(B,'#FFFFFF',.2),vert=.2)
    body=s.m_ell(13,22,9,5.5); s.body(body,B)
    s.body(s.m_ell(14,24.5,6,2.5),'#E6F8FF',flat=True,dither=False)
    for x in (7,16): s.body(s.m_rect(x,25,x+2,29,1),B,vert=.5)
    s.px([(7,29),(9,29),(16,29),(18,29)],'#FFB3D1')
    # Kiemen als Ladekreis-Federn
    for (x0,y0,x1,y1) in [(14,9,10,3),(15,10,9,7),(16,12,10,12),(24,8,27,2),(25,10,30,6),(25,12,30,11)]:
        s.paint(s.m_line([(x0,y0),(x1,y1)],w=2),'#FF8FC0')
    for (x,y) in [(10,3),(9,7),(10,12),(27,2),(30,6),(30,11)]: s.body(s.m_ell(x+.5,y+.5,1.6,1.6),'#FF8FC0',flat=True,dither=False)
    head=s.m_ell(20,14,7.5,6); s.body(head,B)
    eye2(s,16,12,3,3,iris='#1F6A9A',blink=blink); eye2(s,22,12,3,3,iris='#1F6A9A',blink=blink)
    s.px([(17,17),(18,18),(19,18),(20,18),(21,18),(22,18),(23,17)],'#2A4A6A')
    s.px([(15,16),(26,16)],'#FFB3D1')
    for i,(x,y) in enumerate([(19,9),(21,9),(23,9)]): s.px([(x,y)],mix('#FFFFFF',B,.2*i))
    s.outline(); return s
from mons import pixi, funkling, troepfel
if __name__=='__main__':
    sc=7;pad=16
    im=Image.new('RGBA',(3*(N*sc+pad)+pad,2*(N*sc+pad)+pad+30),(239,233,255,255))
    old=[pixi,funkling,troepfel];new=[fox,pup,axo]
    for i in range(3):
        im.alpha_composite(old[i]().img(sc),(pad+i*(N*sc+pad),pad+20))
        im.alpha_composite(new[i]().img(sc),(pad+i*(N*sc+pad),pad*2+20+N*sc))
    d=ImageDraw.Draw(im);d.text((pad,4),"VORHER",fill=(80,70,120));d.text((pad,pad+20+N*sc+2),"NACHHER",fill=(80,70,120))
    im.save('vergleich.png')
