from v2 import *
def bigeye(s,x,y,iris,blink=False,w=4,h=5,ol='#231B3F'):
    if blink:
        s.px([(x+i,y+h-2) for i in range(w)],ol); s.px([(x-1,y+h-3),(x+w,y+h-3)],ol); return
    for yy in range(h):
        for xx in range(w):
            if (yy==0 or yy==h-1) and (xx==0 or xx==w-1): continue
            s.g[y+yy,x+xx]=ol
    for yy in range(2,h-1):
        for xx in range(1,w-1): s.g[y+yy,x+xx]=iris
    s.g[y+h-2,x+w-2]=mix(iris,'#FFFFFF',.5)
    s.g[y+1,x+1]='#FFFFFF'; s.g[y+1,x+2]='#FFFFFF'; s.g[y+2,x+1]='#FFFFFF'
def chibi_base(s,B,belly,head=(16,13,10,8.5),body=(16,25,6,4.3),feet=((12,28),(18,28))):
    for (fx,fy) in feet: s.body(s.m_ell(fx+1.5,fy+1,2.2,1.6),B,vert=.4)
    bd=s.m_ell(*body); s.body(bd,B); s.body(s.m_ell(body[0],body[1]+.8,3.2,2.6),belly,flat=True,dither=False)
    hd=s.m_ell(*head); return hd
def fox3(blink=False):
    s=S();B='#F4F0FF';OL='#5B4F8A'
    tail=s.m_ell(7,22,4.2,6.5)|s.m_ell(4.5,15,3,4); s.body(tail,B,vert=.25)
    ys=np.mgrid[0:N,0:N][0]; s.body(tail&(ys<=14),'#8FE8D0',vert=0)
    for (x,y,c) in [(3,9,'#8FE8D0'),(1,7,'#FF9EC7'),(5,7,'#B9E7FF'),(2,4,'#8FE8D0')]: s.px([(x,y)],c)
    hd=chibi_base(s,B,'#FFFFFF')
    earL=s.m_poly([(7,10),(7,0),(14,6)]);earR=s.m_poly([(18,6),(25,0),(25,10)])
    s.body(earL,B,vert=0);s.body(earR,B,vert=0)
    s.paint(s.m_poly([(9,8),(9,3),(12,6)]),'#FFB3D1');s.paint(s.m_poly([(20,6),(23,3),(23,8)]),'#FFB3D1')
    s.body(hd,B,vert=.2); s.contour(hd,OL)
    # Wangenfell
    s.px([(5,15),(6,16),(26,15),(25,16)],B)
    bigeye(s,9,10,'#5B4AC8',blink); bigeye(s,19,10,'#5B4AC8',blink)
    s.px([(15,16),(16,16)],'#3A2A5A'); s.px([(14,17),(15,18),(16,18),(17,17)],'#6B4A7A')
    s.px([(7,16),(8,16),(23,16),(24,16)],'#FFB3D1')
    s.px([(12,21),(13,21),(14,21),(15,21),(16,21),(17,21),(18,21),(19,21)],'#8FE8D0'); s.px([(16,22)],'#FF7EB6')
    s.outline(); return s
def pup3(blink=False):
    s=S();B='#FF9A4A';OL='#7A2E12'
    fl=s.m_poly([(24,26),(31,18),(28,20),(30,13),(26,19),(25,15),(22,23)]); s.body(fl,'#FFCF4A',vert=0)
    s.body(s.m_poly([(24,25),(28,20),(26,20),(26,18),(23,23)]),'#FF6A2B',vert=0)
    hd=chibi_base(s,B,'#FFE3C2')
    s.body(s.m_poly([(12,5),(14,-1),(16,3),(18,-1),(20,5)]),'#FFCF4A',vert=0)
    s.body(hd,B,vert=.2)
    for side,cx in ((-1,7),(1,25)):
        ear=s.m_poly([(cx,7),(cx+side*4,9),(cx+side*4,16),(cx+side*2,14),(cx+side*1,18),(cx-side*1,12)])
        s.body(ear,'#FF6A2B',vert=0); s.contour(ear,OL)
    s.contour(hd,OL)
    s.body(s.m_ell(16,16,5,3),'#FFE3C2',flat=True,dither=False)
    bigeye(s,9,10,'#8A3A12',blink); bigeye(s,19,10,'#8A3A12',blink)
    s.px([(15,15),(16,15),(15,16),(16,16)],'#3A1A10')
    s.px([(13,17),(14,18),(15,18),(16,18),(17,18),(18,17)],'#7A2E12')
    if not blink: s.px([(15,19),(16,19)],'#FF7E9E')
    s.px([(7,16),(8,16),(23,16),(24,16)],'#FF6A6A')
    s.outline(); return s
def axo3(blink=False):
    s=S();B='#9ADDF7';OL='#1F5A7A'
    tail=s.m_poly([(20,26),(30,19),(29,25),(22,29)]); s.body(tail,mix(B,'#FFFFFF',.25),vert=.2)
    hd=chibi_base(s,B,'#E6F8FF',head=(16,13.5,11,8),body=(15,25,6.5,4.2),feet=((10,28),(17,28)))
    for side in (-1,1):
        for k,(dx,dy) in enumerate([(5,-4),(6,0),(5,4)]):
            x0=16+side*9; x1=x0+side*dx; y1=12+dy
            s.paint(s.m_line([(x0,12+dy*.4),(x1,y1)],w=2),'#FF8FC0')
            s.body(s.m_ell(x1+.5,y1+.5,1.8,1.8),'#FF8FC0',flat=True,dither=False)
    s.body(hd,B,vert=.2); s.contour(hd,OL)
    bigeye(s,8,11,'#1F6A9A',blink,w=4,h=4); bigeye(s,20,11,'#1F6A9A',blink,w=4,h=4)
    s.px([(11,17),(12,18),(13,18),(14,18),(15,18),(16,18),(17,18),(18,18),(19,18),(20,17)],'#2A4A6A')
    if not blink: s.px([(15,19),(16,19)],'#FF8FC0')
    s.px([(6,16),(7,16),(24,16),(25,16)],'#FFB3D1')
    for i,(x,y) in enumerate([(13,7),(15,6),(17,6),(19,7)]): s.px([(x,y)],mix('#FFFFFF',B,.25*i))
    s.outline(); return s
if __name__=='__main__':
    sc=7;pad=16
    im=Image.new('RGBA',(3*(N*sc+pad)+pad,2*(N*sc+pad)+pad+30),(239,233,255,255))
    old=[pixi,funkling,troepfel];new=[fox3,pup3,axo3]
    for i in range(3):
        im.alpha_composite(old[i]().img(sc),(pad+i*(N*sc+pad),pad+20))
        im.alpha_composite(new[i]().img(sc),(pad+i*(N*sc+pad),pad*2+20+N*sc))
    d=ImageDraw.Draw(im);d.text((pad,4),"VORHER",fill=(80,70,120));d.text((pad,pad+20+N*sc+2),"NACHHER",fill=(80,70,120))
    im.save('vergleich.png')
