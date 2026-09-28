import px
from px import S, mix, Image, ImageDraw, np
from v3 import fox3, bigeye, chibi_base
def P(pts,k,dx=0,dy=0): return [(x*k+dx,y*k+dy) for x,y in pts]
def eyeK(s,x,y,k,iris,ol='#1A1433'):
    w=round(4*k); h=max(3,round(3*k))
    m=s.m_poly([(x,y),(x+w-1,y),(x+w+round(k*.8),y+h*.55),(x+w-1,y+h-1),(x,y+h-1)])
    s.paint(m,ol)
    ir=s.m_ell(x+w*.55,y+h*.55,max(1.1,w*.28),max(1.1,h*.33)); s.paint(ir&m,iris)
    s.px([(round(x+w*.45),round(y+h*.35))],'#FFFFFF')
    s.px([(round(x+w*.65),round(y+h*.6))],mix(iris,'#FFFFFF',.55))
    s.paint(s.m_line([(x-round(k),y-round(k)),(x+w-1,y-1),(x+w+round(k*.6),y-round(k*1.6))],w=max(1,round(k*.7))),ol)
def blazebit_cute(blink=False):
    px.setN(32); s=fox3(blink)
    # umfärben: Fell orange, Schweifspitze Flamme
    for y in range(32):
        for x in range(32):
            c=s.g[y,x]
            if c is None: continue
            r,g,b=px.hx(c)
            if r>200 and g>190 and b>200 and not (r==255 and g==255 and b==255):  # helles Fell
                l=(r+g+b)/765; s.g[y,x]=mix('#E8612C','#FFD9A8',max(0,(l-.78)*4.5))
            elif c=='#8FE8D0' or c=='#B9E7FF': s.g[y,x]='#FFC23D'
    for (x,y) in [(15,2),(16,1),(16,3),(17,2)]: s.g[y,x]='#FFC23D'
    return s
def fox_big(n,kind,blink=False):
    px.setN(n); s=S(); k=n/32
    if kind=='champ':
        B='#F07234';Bl='#FFE0B8';M='#FFD34D';D='#3A2230';E='#8A2E14';tails=1
    else:
        B='#E24A2A';Bl='#FFD9A8';M='#FFE45C';D='#231428';E='#6A1A10';tails=3
    ys=np.mgrid[0:n,0:n][0]
    # Schweife
    base_tail=[(10,23),(4,20),(1,13),(2,6),(5,10),(7,16),(12,20)]
    offs=[(0,0)] if tails==1 else [(-1.2,4),(0,0),(2.2,-3.5)]
    for (ox,oy) in offs:
        t=s.m_poly(P(base_tail,k,ox*k,oy*k)); s.body(t,B,dither=False,vert=.2)
        tip=t&(ys<=(11+oy)*k); s.body(tip,M,dither=False,vert=0)
        s.body(t&(ys<=(8+oy)*k),'#FFF3B0',dither=False,vert=0)
    # Hinterbein + Körper
    s.body(s.m_ell(12*k,24.5*k,4.5*k,4.5*k),B,dither=False)
    body=s.m_poly(P([(11,17),(18,16),(22,22),(21,29),(12,29),(10,24)],k)); s.body(body,B,dither=False)
    s.body(s.m_poly(P([(17,18),(22,22),(20,26),(16,22)],k)),Bl,flat=True,dither=False)
    for (x0,x1) in ((18,20),(14,16)):
        s.body(s.m_rect(x0*k,24*k,x1*k,30*k),B,dither=False,vert=.3); s.paint(s.m_rect(x0*k,28.5*k,x1*k,30*k),D)
        if kind=='ultra':
            fl=s.m_poly(P([(x0-.5,29),(x0,26.5),(x0+1,28),(x1,26),(x1+.8,29)],k)); s.body(fl,M,dither=False,vert=0)
    s.contour(body,E)
    # Ohren
    ears=[s.m_poly(P([(12,8),(11,0),(16,5)],k)),s.m_poly(P([(16,5),(20,-1),(21,7)],k))]
    for e in ears: s.body(e,B,dither=False,vert=0); s.paint(e&(ys<=2*k),D)
    s.paint(s.m_poly(P([(17,5),(19,2),(19,6)],k)),mix(B,D,.35))
    # Kopf
    head=s.m_ell(17*k,10.5*k,6.5*k,5.2*k)|s.m_poly(P([(21,9),(27,11),(27,13),(21,15)],k))|s.m_poly(P([(11,11),(9,15),(13,14),(12,17),(16,15),(18,16),(20,14)],k))
    s.body(head,B,dither=False,vert=.25); s.contour(head,E)
    s.paint(s.m_poly(P([(21,13),(27,13),(21,15)],k)),Bl)
    s.paint(s.m_poly(P([(12,13),(10,15),(14,15)],k)),Bl)
    # Flammenmähne
    mane=s.m_poly(P([(9,12),(6,8),(9,9),(7,4),(11,7),(12,3),(14,7)],k)); s.body(mane,M,dither=False,vert=0)
    if kind=='ultra':
        # Stirnpanzer mit Leuchtlinie
        plate=s.m_poly(P([(14,6),(20,4.5),(23,7.5),(19,8),(15,8.5)],k)); s.body(plate,'#3A3550',dither=False,vert=.2)
        s.paint(s.m_line(P([(15.5,7.3),(19.5,6),(22,7.2)],k),w=1),M)
        # Brustpanzer
        cp=s.m_poly(P([(17,17.5),(21.5,21),(20,23),(17,21)],k)); s.body(cp,'#3A3550',dither=False,vert=.2); s.paint(s.m_line(P([(18,19),(20.5,21.5)],k)),M)
    if not blink: eyeK(s,round(18*k),round(8*k),k,M if kind=='ultra' else '#FFB020')
    else: s.paint(s.m_line(P([(18,9.5),(22,9.5)],k),w=max(1,round(k*.7))),'#1A1433')
    s.paint(s.m_poly(P([(26,10),(27.4,10),(27.4,11.4),(26,11)],k)),D)
    s.paint(s.m_line(P([(22,13),(24.5,13),(25.5,12.2)],k),w=max(1,round(k*.6))),D)
    s.paint(s.m_poly(P([(23.3,13),(24.2,13),(23.8,14.2)],k)),'#FFFFFF')
    # Schaltkreis-Linien
    lw=max(1,round(k*.6))
    s.paint(s.m_line(P([(11,21),(13,21),(13,23),(14.5,23)],k),w=lw),M)
    s.paint(s.m_line(P([(13,9),(15,9),(16,10)],k),w=lw),M)
    if kind=='ultra':
        s.paint(s.m_line(P([(8,18),(10,19),(10,26)],k),w=lw),M); s.paint(s.m_line(P([(19,24),(19,27.5)],k),w=lw),M)
        for (x,y) in [(3,26),(28,4),(30,18),(5,30),(27,27)]: s.paint(s.m_ell(x*k,y*k,k*.7,k*.7),'#FFE45C')
    s.outline(); return s
if __name__=='__main__':
    sc=5;pad=14;items=[('Baby: Pixi (32)',lambda:(px.setN(32),fox3())[1],32),('Rookie: Blazebit (32)',blazebit_cute,32),('Champion: Glutfuchs (48)',lambda:fox_big(48,'champ'),48),('Ultra: Infernitsune (64)',lambda:fox_big(64,'ultra'),64)]
    W=sum(n*sc+pad for _,_,n in items)+pad;H=64*sc+2*pad+24
    im=Image.new('RGBA',(W,H),(239,233,255,255));d=ImageDraw.Draw(im);x=pad
    for lab,f,n in items:
        spr=f();px.setN(n);img=spr.img(sc);im.alpha_composite(img,(x,H-pad-n*sc));d.text((x,6),lab,fill=(60,50,100));x+=n*sc+pad
    im.save('linie.png')

import math
def fox_cute(B,belly,tip,tipdots,inner,collar,blink=False,flame=False):
    px.setN(32); s=S(); OL=mix(B,'#231B3F',.6)
    ys=np.mgrid[0:32,0:32][0]
    tail=s.m_ell(7,22,4.2,6.5)|s.m_ell(4.5,15,3,4); s.body(tail,B,vert=.25)
    s.body(tail&(ys<=14),tip,vert=0)
    if flame: s.body(s.m_poly([(2,14),(1,7),(4,10),(5,4),(7,11),(8,14)]),tip,dither=False,vert=-.1)
    for (x,y,c) in tipdots: s.px([(x,y)],c)
    hd=chibi_base(s,B,belly)
    earL=s.m_poly([(7,10),(7,0),(14,6)]);earR=s.m_poly([(18,6),(25,0),(25,10)])
    s.body(earL,B,vert=0);s.body(earR,B,vert=0)
    s.paint(s.m_poly([(9,8),(9,3),(12,6)]),inner);s.paint(s.m_poly([(20,6),(23,3),(23,8)]),inner)
    if flame: s.body(s.m_poly([(13,5),(15,0),(16,3),(18,0),(19,5)]),'#FFC23D',dither=False,vert=0)
    s.body(hd,B,vert=.2); s.contour(hd,OL)
    s.px([(5,15),(6,16),(26,15),(25,16)],B)
    iris='#C0461A' if flame else '#5B4AC8'
    bigeye(s,9,10,iris,blink); bigeye(s,19,10,iris,blink)
    s.px([(15,16),(16,16)],'#3A2A5A'); s.px([(14,17),(15,18),(16,18),(17,17)],'#6B4A7A')
    s.px([(7,16),(8,16),(23,16),(24,16)],'#FF9E9E' if flame else '#FFB3D1')
    s.px([(x,21) for x in range(12,20)],collar); s.px([(16,22)],'#FF7EB6' if not flame else '#FFE45C')
    s.outline(); return s
def blazebit_cute2(blink=False):
    return fox_cute('#F2743A','#FFE3C2','#FFC23D',[(3,6,'#FFE45C'),(1,9,'#FF8A2A'),(5,3,'#FFE45C')],'#FFB08A','#FFD34D',blink,flame=True)
def rot(pts,cx,cy,a):
    c,sn=math.cos(a),math.sin(a); return [(cx+(x-cx)*c-(y-cy)*sn, cy+(x-cx)*sn+(y-cy)*c) for x,y in pts]
def ultra2(blink=False):
    n=64;px.setN(n); s=S(); k=2
    B='#E4502C';Bl='#FFE0B8';M='#FFE45C';D='#231428';E='#5A160E';AR='#3A3550'
    ys,xs=np.mgrid[0:n,0:n]
    base_tail=[(11,23),(6,21),(2,15),(1,8),(4,11),(7,16),(12,20)]
    for a in (-0.55,-0.15,0.25):
        pts=rot(base_tail,11,22,a); t=s.m_poly(P(pts,k))
        s.body(t,B,dither=False,vert=.15)
        tipcut=s.m_poly(P(rot([(-5,-5),(9,-5),(9,12),(-5,12)],11,22,a),k))
        s.body(t&tipcut,M,dither=False,vert=0)
        s.body(t&s.m_poly(P(rot([(-5,-5),(9,-5),(9,9),(-5,9)],11,22,a),k)),'#FFF6C0',dither=False,vert=0)
        s.contour(t,E)
    s.body(s.m_ell(12*k,24.5*k,4.5*k,4.5*k),B,dither=False,vert=.3)
    body=s.m_poly(P([(11,17),(18,16),(22,22),(21,29),(12,29),(10,24)],k)); s.body(body,B,dither=False,vert=.3)
    s.body(s.m_poly(P([(17,18),(22,22),(20,26),(16,22)],k)),Bl,flat=True,dither=False)
    for (x0,x1) in ((18,20),(14,16)):
        s.body(s.m_rect(x0*k,24*k,x1*k,30*k),B,dither=False,vert=.3); s.paint(s.m_rect(x0*k,28.5*k,x1*k,30*k),D)
        s.body(s.m_poly(P([(x0-.4,28.6),(x0+.3,26.8),(x0+1,28),(x1-.3,26.6),(x1+.6,28.6)],k)),M,dither=False,vert=0)
    s.contour(body,E)
    cp=s.m_poly(P([(17.5,17.5),(21.5,21),(20.3,23.2),(17.3,21)],k)); s.body(cp,AR,dither=False,vert=.2); s.paint(s.m_line(P([(18.3,19.2),(20.6,21.6)],k)),M)
    ears=[s.m_poly(P([(12,8),(11,-.5),(16,5)],k)),s.m_poly(P([(16,5),(20.5,-1.5),(21,7)],k))]
    for e in ears: s.body(e,B,dither=False,vert=0); s.paint(e&(ys<=2.5*k),D); s.contour(e,E)
    head=s.m_ell(17*k,10.5*k,6.5*k,5.2*k)|s.m_poly(P([(21,9),(27.5,11),(27.5,13),(21,15)],k))|s.m_poly(P([(11,11),(8.5,15.5),(13,14),(11.5,17.5),(16,15),(18,16),(20,14)],k))
    s.body(head,B,dither=False,vert=.3); s.contour(head,E)
    s.paint(s.m_poly(P([(21,13),(27.5,13),(21,15)],k)),Bl); s.paint(s.m_poly(P([(12,13),(9.5,15.5),(14,15)],k)),Bl)
    plate=s.m_poly(P([(13.5,6.5),(20,4.6),(23.5,7.6),(19,8.1),(15,8.6)],k)); s.body(plate,AR,dither=False,vert=.2); s.contour(plate,D)
    s.paint(s.m_line(P([(15.3,7.4),(19.5,6),(22.4,7.3)],k)),M)
    if not blink: eyeK(s,36,17,k,M)
    else: s.paint(s.m_line([(36,19),(43,19)],w=1),'#1A1433')
    s.paint(s.m_rect(52,20,54,22),D)
    s.paint(s.m_line([(44,26),(49,26),(51,24)],w=1),D); s.paint(s.m_poly([(46,26),(48,26),(47,28)]),'#FFFFFF')
    s.paint(s.m_line(P([(12,21),(13.5,21),(13.5,23.5),(15,23.5)],k),w=1),M)
    for (x,y) in [(4,58),(58,6),(60,40),(50,56)]: s.paint(s.m_ell(x,y,1.3,1.3),M)
    s.outline(); return s
if __name__=='__main__':
    sc=5;pad=14;items=[('Baby: Pixi (32)',lambda:(px.setN(32),fox3())[1],32),('Rookie: Blazebit (32)',blazebit_cute2,32),('Champion: Glutfuchs (48)',lambda:fox_big(48,'champ'),48),('Ultra: Infernitsune (64)',ultra2,64)]
    W=sum(n*sc+pad for _,_,n in items)+pad;H=64*sc+2*pad+24
    im=Image.new('RGBA',(W,H),(239,233,255,255));d=ImageDraw.Draw(im);x=pad
    for lab,f,n in items:
        spr=f();px.setN(n);img=spr.img(sc);im.alpha_composite(img,(x,H-pad-n*sc));d.text((x,6),lab,fill=(60,50,100));x+=n*sc+pad
    im.save('linie.png')
