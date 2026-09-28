import px, math
from px import S, mix, shift, Image, ImageDraw, np
def P(pts,k,dx=0,dy=0): return [(x*k+dx,y*k+dy) for x,y in pts]
def fur(pts,k,depth=.55,every=2):
    # fügt Fellzacken zwischen Punkten ein (nach außen)
    out=[];n=len(pts);cx=sum(p[0] for p in pts)/n;cy=sum(p[1] for p in pts)/n
    for i in range(n):
        a=pts[i];b=pts[(i+1)%n];out.append(a)
        L=math.hypot(b[0]-a[0],b[1]-a[1]);m=max(1,int(L/every))
        for j in range(1,m):
            t=j/m;x=a[0]+(b[0]-a[0])*t;y=a[1]+(b[1]-a[1])*t
            if j%2: 
                nx,ny=x-cx,y-cy;l=math.hypot(nx,ny)+1e-6;x+=nx/l*depth;y+=ny/l*depth
            out.append((x,y))
    return out
def eyeL(s,cx,cy,w,h,iris,ol,shape='round',look=1):
    n=px.N
    yy,xx=np.mgrid[0:n,0:n]
    if shape=='round':
        m=((xx+.5-cx)/(w/2))**2+((yy+.5-cy)/(h/2))**2<=1
    else:
        m=s.m_poly([(cx-w/2,cy-h*.15),(cx-w*.1,cy-h/2),(cx+w/2,cy-h*.25),(cx+w*.35,cy+h/2),(cx-w*.3,cy+h*.45)])
    s.paint(m,ol)
    inner=((xx+.5-cx-look*w*.08)/(w*.36))**2+((yy+.5-cy-h*.05)/(h*.4))**2<=1
    inner&=m
    ys=np.nonzero(inner)[0]
    if len(ys):
        y0,y1=ys.min(),ys.max()
        for y,x in zip(*np.nonzero(inner)):
            t=(y-y0)/max(1,y1-y0); s.g[y,x]=mix(shift(iris,dv=-.25),mix(iris,'#FFFFFF',.35),t)
    pup=((xx+.5-cx-look*w*.1)/(w*.14))**2+((yy+.5-cy-h*.02)/(h*.22))**2<=1
    s.paint(pup&inner,ol)
    hx_,hy_=cx-w*.12,cy-h*.22
    s.paint(((xx+.5-hx_)/max(.9,w*.13))**2+((yy+.5-hy_)/max(.9,h*.13))**2<=1,'#FFFFFF')
    s.px([(int(cx+w*.18),int(cy+h*.2))],'#FFFFFF')
def body(s,mask,col,**kw):
    kw.setdefault('dither',False); return s.body(mask,col,**kw)

FIRE=dict(B='#F2702F',C='#FFE6C4',D='#3A1E24',Y='#FFC93C',YL='#FFF3B0',E='#7A2A16',R='#E23B1E')

def rookie(blink=False):
    n=64;px.setN(n);s=S();k=2;c=FIRE
    ys=np.mgrid[0:n,0:n][0]
    tail=s.m_poly(P(fur2([(12,25),(6,23.5),(2.5,18),(1.5,12),(3.5,7),(6,10),(7.5,15),(10.5,19.5),(14.5,22)],.5,1.5,seed=2),k))
    body(s,tail,c['B'],vert=.2)
    tip=s.m_poly(P([(0,4),(9,4),(9,13.5),(0,13.5)],k))&tail; body(s,tip,c['Y'],vert=0)
    fl=s.m_poly(P([(3,8),(1.5,2),(4.5,5),(5.5,0.5),(7,6.5),(6.5,9)],k)); body(s,fl,c['Y'],vert=-.1)
    body(s,s.m_poly(P([(3.5,7.5),(3.2,4),(4.8,5.8),(5.6,3),(6.2,7.5)],k)),c['YL'],vert=0)
    s.contour(tail|fl,c['E'])
    body(s,s.m_ell(12.5*k,25.5*k,4.6*k,4.6*k),c['B'],vert=.35)
    bd=s.m_poly(P(fur2([(11,18),(19,17),(22,23),(21,30),(12,30),(10,25)],.35,1.7,seed=4),k)); body(s,bd,c['B'],vert=.35)
    body(s,s.m_poly(P(fur2([(17,19),(20.5,21),(21.5,23.5),(20,26),(17,26.5),(16,23)],.45,1.1,seed=6),k)),c['C'],flat=True)
    for (x0,x1) in ((18,20.4),(14.4,16.8)):
        leg=s.m_rect(x0*k,24*k,x1*k,30.6*k,2); body(s,leg,c['B'],vert=.4); s.paint(leg&(ys>=29.2*k),c['D']); s.contour(leg,c['E'])
    s.contour(bd,c['E'])
    earB=s.m_poly(P([(11.3,9.5),(9.8,0.8),(15.5,5.5)],k)); earF=s.m_poly(P([(16,5.2),(21.3,-0.2),(22.2,8)],k))
    for e in (earB,earF): body(s,e,c['B'],vert=0); s.paint(e&(ys<=2.8*k),c['D'])
    s.paint(s.m_poly(P([(17.8,5.3),(20.6,1.8),(20.9,6.4)],k)),c['C']); s.paint(s.m_poly(P([(11.9,7.5),(11.2,3),(14,5.6)],k)),mix(c['C'],c['B'],.4))
    s.contour(earB,c['E']);s.contour(earF,c['E'])
    head=s.m_ell(17*k,12.2*k,7.3*k,6.3*k)|s.m_poly(P([(21.5,10.5),(26.8,12.3),(26.4,14.6),(21.5,16.3)],k))|s.m_poly(P(fur2([(10.8,12),(8.6,16.3),(11.6,15.3),(10.6,18.8),(14.2,16.6),(15.2,18.2),(17.5,16.5)],.3,1.2,seed=8),k))
    body(s,head,c['B'],vert=.3)
    s.paint(s.m_poly(P([(21.3,14),(26.4,14),(21.5,16.3),(19,16)],k)),c['C'])
    s.paint(s.m_poly(P([(11.5,14.5),(9,16.2),(14.5,16.5),(16,15)],k)),c['C'])
    s.contour(head,c['E'])
    tuft=s.m_poly(P([(13.6,6.8),(14.6,2),(16.4,4.8),(18,0.8),(19.6,6)],k)); body(s,tuft,c['Y'],vert=-.1); s.contour(tuft,c['E'])
    if blink: s.paint(s.m_line(P([(17.3,11.8),(22,11.2)],k),w=2),c['D'])
    else: eyeL(s,19.6*k,11*k,4.4*k,4.9*k,'#E0561F',c['D'],'round')
    s.paint(s.m_ell(26.2*k,12.4*k,1.1*k,.9*k),c['D'])
    s.paint(s.m_line(P([(22.4,14.6),(24.2,15),(25.6,14.4)],k),w=1),c['D'])
    s.paint(s.m_poly(P([(23,14.8),(23.8,14.9),(23.4,16)],k)),'#FFFFFF')
    s.paint(s.m_ell(14.2*k,14.3*k,1.2*k,.6*k),'#FF8F7A')
    s.outline(); return s

def champion(blink=False):
    n=80;px.setN(n);s=S();k=2.5;c=dict(FIRE,B='#EB5F28')
    ys=np.mgrid[0:n,0:n][0]
    tail=s.m_poly(P(fur([(11,24),(5,22),(1.5,15),(1.5,7),(4.5,10),(6.5,15.5),(12,20)],1,.5,1.4),k)); body(s,tail,c['B'],vert=.15)
    body(s,tail&(ys<=12*k),c['Y'],vert=0)
    for fp in ([(1.5,8),(0.5,1.5),(3.5,5),(4.2,0),(5.5,7),(4.5,10)],):
        f=s.m_poly(P(fp,k)); body(s,f,c['Y'],vert=-.1); body(s,s.m_poly(P([(2,7),(2,3.5),(3.4,5.4),(4,2.5),(4.6,7.5)],k)),c['YL'],vert=0)
    s.contour(tail,c['E'])
    body(s,s.m_ell(12*k,24.3*k,4.8*k,4.9*k),c['B'],vert=.35)
    bd=s.m_poly(P(fur([(10.5,17),(18,15.5),(22.3,22),(21.3,29.5),(12,29.5),(9.8,24)],1,.4,1.6),k)); body(s,bd,c['B'],vert=.35)
    body(s,s.m_poly(P(fur([(17,17.5),(22,21.5),(20.3,26),(16.2,22)],1,.4,1.1),k)),c['C'],flat=True)
    for (x0,x1) in ((18.2,20.4),(14.2,16.4)):
        leg=s.m_rect(x0*k,23.5*k,x1*k,30.6*k,2); body(s,leg,c['B'],vert=.4); s.paint(leg&(ys>=29*k),c['D']); s.contour(leg,c['E'])
    s.contour(bd,c['E'])
    mane=s.m_poly(P([(9,13),(6.2,7.5),(9.3,9.2),(8.6,4.2),(11.8,7.4),(12.4,3),(14.6,7)],k)); body(s,mane,c['Y'],vert=0)
    body(s,s.m_poly(P([(10,11.5),(8.8,8.4),(10.5,9.2),(10.5,6.4),(12.3,9)],k)),c['R'],vert=0); s.contour(mane,c['E'])
    ears=[s.m_poly(P([(12,8),(10.8,0),(16,5)],k)),s.m_poly(P([(16,5),(20.2,-.8),(21,7)],k))]
    for e in ears: body(s,e,c['B'],vert=0); s.paint(e&(ys<=2.5*k),c['D']); s.contour(e,c['E'])
    s.paint(s.m_poly(P([(17,5),(19.4,2),(19.6,6)],k)),mix(c['B'],c['D'],.35))
    head=s.m_ell(17*k,10.5*k,6.3*k,5.1*k)|s.m_poly(P([(21,8.8),(28.3,11),(28,13.2),(21,15)],k))|s.m_poly(P(fur([(11,11),(8.8,15.5),(12.6,14.3),(11.3,17.6),(15.6,15.4),(18,16.2),(20,14)],1,.3,1.2),k))
    body(s,head,c['B'],vert=.3)
    s.paint(s.m_poly(P([(21,12.9),(28,13.2),(21,15),(18.5,15)],k)),c['C']); s.paint(s.m_poly(P([(11.8,13.2),(9.4,15.4),(14.2,15.3)],k)),c['C'])
    s.contour(head,c['E'])
    if blink: s.paint(s.m_line(P([(17.6,9.6),(22,9)],k),w=2),c['D'])
    else: eyeL(s,19.8*k,9.3*k,4.4*k,3.1*k,'#FFB020',c['D'],'almond')
    s.paint(s.m_line(P([(17,7.4),(20,6.9),(22.6,7.8)],k),w=2),c['D'])
    s.paint(s.m_ell(27.7*k,11*k,1*k,.8*k),c['D'])
    s.paint(s.m_line(P([(22,13.1),(24.8,13.2),(26.2,12.4)],k),w=1),c['D']); s.paint(s.m_poly(P([(23.3,13.2),(24.2,13.2),(23.8,14.4)],k)),'#FFFFFF')
    Mc=c['Y']
    for ln in ([(11,21),(13.2,21),(13.2,23.4),(15,23.4)],[(13,8.8),(15,8.8),(16,9.8)],[(19.2,25),(19.2,27.8)]):
        s.paint(s.m_line(P(ln,k),w=2),Mc)
    s.outline(); return s

def rot(pts,cx,cy,a):
    c_,sn=math.cos(a),math.sin(a); return [(cx+(x-cx)*c_-(y-cy)*sn, cy+(x-cx)*sn+(y-cy)*c_) for x,y in pts]
def ultra(blink=False):
    n=96;px.setN(n);s=S();k=3;c=dict(FIRE,B='#DE4A26',E='#5A160E');AR='#3B3552';ARl='#6C6590'
    ys=np.mgrid[0:n,0:n][0]
    base_tail=[(12,23),(7.5,21.5),(4,16),(3,9),(5.5,11.5),(8.5,16.5),(13,20)]
    for a in (-0.42,-0.08,0.26):
        pts=rot(fur(base_tail,1,.45,1.3),12,22,a); t=s.m_poly(P(pts,k,1*k))
        body(s,t,c['B'],vert=.15)
        tipm=s.m_poly(P(rot([(-3,-3),(10,-3),(10,12),(-3,12)],12,22,a),k,1*k))&t; body(s,tipm,c['Y'],vert=0)
        tipl=s.m_poly(P(rot([(-3,-3),(10,-3),(10,9.5),(-3,9.5)],12,22,a),k,1*k))&t; body(s,tipl,c['YL'],vert=0)
        s.contour(t,c['E'])
    body(s,s.m_ell(13*k,24.5*k,4.6*k,4.7*k),c['B'],vert=.35)
    bd=s.m_poly(P(fur([(12,17),(19,15.5),(23,22),(22,29.3),(13,29.3),(11,24)],1,.35,1.5),k)); body(s,bd,c['B'],vert=.35)
    body(s,s.m_poly(P(fur([(18,17.5),(23,21.5),(21.2,25.5),(17.4,22)],1,.35,1),k)),c['C'],flat=True)
    cp=s.m_poly(P([(18.6,18),(22.4,21.2),(21.3,23.4),(18.3,21.3)],k)); body(s,cp,AR,vert=.2); s.contour(cp,'#1A1428')
    s.paint(s.m_line(P([(19.3,19.3),(21.7,21.7)],k),w=2),c['YL'])
    for (x0,x1) in ((19.2,21.3),(15.2,17.3)):
        leg=s.m_rect(x0*k,23.5*k,x1*k,30.5*k,2); body(s,leg,c['B'],vert=.4)
        grv=s.m_rect(x0*k,26.6*k,x1*k,29*k,1); body(s,grv,AR,vert=.2); s.paint(s.m_line([(x0*k+1,27.6*k),(x1*k-1,27.6*k)],w=1),c['Y'])
        s.paint(leg&(ys>=29.2*k),c['D']); s.contour(leg|grv,c['E'])
        body(s,s.m_poly(P([(x0-.5,30.3),(x0+.2,28.8),(x0+.9,29.8),(x1-.4,28.6),(x1+.5,30.3)],k)),c['Y'],vert=0)
    s.contour(bd,c['E'])
    mane=s.m_poly(P([(10,13.5),(6.5,8),(9.8,9.3),(8.8,3.8),(12.3,7.3),(12.9,2.2),(15.3,6.6)],k)); body(s,mane,c['Y'],vert=0)
    body(s,s.m_poly(P([(11,12),(9.4,8.5),(11.2,9.4),(11.2,6.2),(13,9)],k)),c['R'],vert=0); s.contour(mane,c['E'])
    ears=[s.m_poly(P([(13,8),(11.8,-.5),(17,5)],k)),s.m_poly(P([(17,5),(21.4,-1.2),(22,7)],k))]
    for e in ears: body(s,e,c['B'],vert=0); s.paint(e&(ys<=2.4*k),c['D']); s.contour(e,c['E'])
    head=s.m_ell(18*k,10.5*k,6.1*k,5*k)|s.m_poly(P([(22,8.8),(29.6,11.2),(29.2,13.2),(22,15)],k))|s.m_poly(P(fur([(12,11),(9.8,15.5),(13.4,14.4),(12.3,17.4),(16.4,15.4),(19,16.2),(21,14)],1,.3,1.1),k))
    body(s,head,c['B'],vert=.3)
    s.paint(s.m_poly(P([(22,12.9),(29.2,13.2),(22,15),(19.5,15)],k)),c['C'])
    s.contour(head,c['E'])
    plate=s.m_poly(P([(14.6,6.4),(20.8,4.4),(24.6,7.4),(20,8.1),(16,8.7)],k)); body(s,plate,AR,vert=.2); s.contour(plate,'#1A1428')
    s.paint(s.m_line(P([(16,7.5),(20.4,5.9),(23.4,7.3)],k),w=2),c['YL'])
    if blink: s.paint(s.m_line(P([(18.8,9.7),(23.2,9.2)],k),w=2),c['D'])
    else: eyeL(s,21*k,9.6*k,4.2*k,2.7*k,'#FFE45C',c['D'],'almond')
    s.paint(s.m_ell(29*k,11.2*k,1*k,.8*k),c['D'])
    s.paint(s.m_line(P([(23,13.1),(26,13.2),(27.4,12.3)],k),w=2),c['D']); s.paint(s.m_poly(P([(24.2,13.2),(25.2,13.2),(24.7,14.6)],k)),'#FFFFFF')
    for ln in ([(12,21),(14.2,21),(14.2,23.4),(16,23.4)],[(9,19),(11,20),(11,26)]):
        s.paint(s.m_line(P(ln,k),w=2),c['Y'])
    for (x,y,r) in [(4,88,1.4),(90,8,1.4),(92,50,1.2),(84,86,1.3),(70,4,1)]: s.paint(s.m_ell(x,y,r,r),c['YL'])
    s.outline(); return s

def pixi_baby(blink=False):
    px.setN(32); from v3 import fox3; return fox3(blink)
LINE=[('Baby: Pixi',pixi_baby,32),('Rookie: Blazebit',rookie,64),('Champion: Glutfuchs',champion,80),('Ultra: Infernitsune',ultra,96)]
if __name__=='__main__':
    sc=4;pad=16
    W=sum(n*sc+pad for _,_,n in LINE)+pad;H=96*sc+2*pad+24
    im=Image.new('RGBA',(W,H),(239,233,255,255));d=ImageDraw.Draw(im);x=pad
    for lab,f,n in LINE:
        spr=f();px.setN(n);im.alpha_composite(spr.img(sc),(x,H-pad-n*sc));d.text((x,6),f"{lab} ({n}x{n})",fill=(60,50,100));x+=n*sc+pad
    im.save('linie_big.png')

import random
def fur2(pts,depth=.5,every=1.6,seed=1):
    rnd_=random.Random(seed);out=[];n=len(pts);cx=sum(p[0] for p in pts)/n;cy=sum(p[1] for p in pts)/n
    for i in range(n):
        a=pts[i];b=pts[(i+1)%n];out.append(a)
        L=math.hypot(b[0]-a[0],b[1]-a[1]);m=max(1,int(L/(every*rnd_.uniform(.8,1.3))))
        for j in range(1,m):
            t=j/m;x=a[0]+(b[0]-a[0])*t;y=a[1]+(b[1]-a[1])*t
            if j%2:
                nx,ny=x-cx,y-cy;l=math.hypot(nx,ny)+1e-6;dd=depth*rnd_.uniform(.4,1.2);x+=nx/l*dd;y+=ny/l*dd
            out.append((x,y))
    return out
def strokes(s,lines,k,col,w=1):
    for ln in lines: s.paint(s.m_line(P(ln,k),w=w),col)
def fox_stand(n,k,c,ultra=False,blink=False):
    px.setN(n);s=S();ys=np.mgrid[0:n,0:n][0]
    B,C,D,E,Y,YL,R=c['B'],c['C'],c['D'],c['E'],c['Y'],c['YL'],c['R']
    far=shift(B,dv=-.18)
    AR,ARl='#3B3552','#6C6590'
    # Schweif(e)
    base_tail=[(8.5,18),(4,15),(1.5,9.5),(2.2,3.5),(4.8,6.8),(6.2,11.2),(10,15.5)]
    angs=(-0.32,0.0,0.32) if ultra else (0.0,)
    for a in angs:
        pts=rot(fur2(base_tail,.45,1.3,seed=3),9,17,a); t=s.m_poly(P(pts,k))
        body(s,t,B,vert=.15)
        body(s,s.m_poly(P(rot([(-3,-3),(9,-3),(9,10.5),(-3,10.5)],9,17,a),k))&t,Y,vert=0)
        body(s,s.m_poly(P(rot([(-3,-3),(9,-3),(9,7.5),(-3,7.5)],9,17,a),k))&t,YL,vert=0)
        s.contour(t,E)
    # ferne Beine
    for (x0,y0,x1,y1) in ((12.4,21,12,29.6),(19,21,19.4,29.6)):
        leg=s.m_poly(P([(x0-1.1,y0),(x0+1.1,y0),(x1+1,y1),(x1-1,y1)],k)); body(s,leg,far,vert=.3); s.paint(leg&(ys>=28.6*k),D); s.contour(leg,E)
    # Körper
    torso=s.m_poly(P(fur2([(7.5,17.5),(11.5,14.8),(18.5,14.2),(22.5,15.8),(23.5,19.8),(21,23),(12,23.2),(7.8,21.2)],.35,1.5,seed=5),k))
    body(s,torso,B,vert=.45)
    belly=s.m_poly(P(fur2([(11,21.4),(20.5,21.2),(20,23.2),(12,23.4)],.4,1.2,seed=7),k))&torso; body(s,belly,C,flat=True)
    # Oberschenkel hinten + nahe Beine
    thigh=s.m_ell(10.4*k,20*k,3.6*k,4*k); body(s,thigh,B,vert=.45); s.contour(thigh,E)
    for (x0,y0,x1,y1) in ((10.4,22,9.6,29.8),(21.4,21.5,22.2,29.8)):
        leg=s.m_poly(P([(x0-1.3,y0),(x0+1.3,y0),(x1+1.2,y1),(x1-1.2,y1)],k)); body(s,leg,B,vert=.35)
        if ultra:
            grv=s.m_poly(P([(x0-1.3+.3,25),(x0+1.3+.3,25),(x1+1.25,28.3),(x1-1.25,28.3)],k)); body(s,grv,AR,vert=.15)
            s.paint(s.m_line(P([((x0+x1)/2-.7,26.7),((x0+x1)/2+.9,26.7)],k),w=1),Y)
        s.paint(leg&(ys>=28.7*k),D); s.contour(leg,E)
        if ultra: body(s,s.m_poly(P([(x1-1.6,30),(x1-1,28.3),(x1-.2,29.4),(x1+.6,28.1),(x1+1.6,30)],k)),Y,vert=0)
    s.contour(torso,E)
    strokes(s,[[(13,16.2),(14.4,15.6)],[(16,16.4),(17.4,15.8)],[(12,18.6),(13.2,18.1)],[(8.6,19.4),(9.6,18.6)]],k,shift(B,dv=-.2))
    # Hals + Brustfell
    neck=s.m_poly(P([(18.6,15.2),(20.6,8.8),(25.2,9.6),(25.4,16.6),(22,18.5)],k)); body(s,neck,B,vert=.3)
    chest=s.m_poly(P(fur2([(23.2,12.8),(26.2,14.6),(25.4,18.4),(22.6,19.6),(21.2,16)],.5,1,seed=9),k)); body(s,chest,C,flat=True)
    if ultra:
        sp=s.m_poly(P([(19.6,14.6),(22.6,12.4),(24.4,14.6),(22.2,17.4)],k)); body(s,sp,AR,vert=.2); s.contour(sp,'#1A1428')
        s.paint(s.m_line(P([(20.8,15),(23.2,14.4)],k),w=1),YL)
    # Mähne
    mane=s.m_poly(P([(18.4,15),(16,9.5),(18.6,11),(18,6),(20.6,9),(21.3,4.4),(23,8.6)],k)); body(s,mane,Y,vert=0)
    body(s,s.m_poly(P([(19,13),(17.8,10),(19.3,11),(19.4,8),(20.8,10.5)],k)),R,vert=0); s.contour(mane,E)
    # Ohren
    ears=[s.m_poly(P([(20.6,7.4),(20.2,-.2),(24.2,4.4)],k)),s.m_poly(P([(23.6,4.6),(26.8,-.6),(27.2,6.4)],k))]
    for e in ears: body(s,e,B,vert=0); s.paint(e&(ys<=2.2*k),D); s.contour(e,E)
    s.paint(s.m_poly(P([(24.6,4.4),(26.4,1.6),(26.5,5.4)],k)),mix(B,D,.35))
    # Kopf
    head=s.m_ell(23.6*k,9.4*k,4.9*k,4.2*k)|s.m_poly(P([(26.6,7.8),(31.6,9.8),(31.3,11.6),(26.4,13)],k))|s.m_poly(P(fur2([(19.4,9.6),(18.6,13.2),(21.2,12.6),(20.8,15),(23.6,13.4),(25.6,13.8)],.3,.9,seed=11),k))
    body(s,head,B,vert=.3)
    s.paint(s.m_poly(P([(26.4,11.6),(31.3,11.6),(26.4,13),(24.6,13)],k)),C)
    s.contour(head,E)
    if ultra:
        plate=s.m_poly(P([(21,6.2),(25.8,4.6),(28.4,7),(25,7.6),(22,8.2)],k)); body(s,plate,AR,vert=.2); s.contour(plate,'#1A1428')
        s.paint(s.m_line(P([(22.2,7.2),(25.4,5.8),(27.4,6.9)],k),w=1),YL)
    if blink: s.paint(s.m_line(P([(24,8.8),(27,8.4)],k),w=max(1,int(k*.7))),D)
    else: eyeL(s,25.6*k,8.7*k,3.4*k,2.2*k,'#FFE45C' if ultra else '#FFB020',D,'almond')
    if not ultra: s.paint(s.m_line(P([(23.6,6.8),(25.8,6.5),(27.4,7.2)],k),w=max(1,int(k*.7))),D)
    s.paint(s.m_ell(31.2*k,9.9*k,.85*k,.7*k),D)
    s.paint(s.m_line(P([(27.2,11.7),(29.6,11.8),(30.8,11.1)],k),w=1),D); s.paint(s.m_poly(P([(28.2,11.8),(29,11.8),(28.6,12.9)],k)),'#FFFFFF')
    lw=max(1,int(k*.6))
    strokes(s,[[(8.5,17.4),(10.5,17.4),(10.5,19.8),(12.2,19.8)],[(21.4,10.8),(22.8,10.8),(23.4,11.6)]],k,Y,w=lw)
    if ultra:
        strokes(s,[[(13,19.6),(16,19.6),(16,20.8),(18.4,20.8)]],k,Y,w=lw)
        for (x,y,r) in [(4,90,1.4),(92,6,1.4),(92,52,1.2),(60,4,1),(86,88,1.3)]: s.paint(s.m_ell(x,y,r,r),YL)
    s.outline(); return s
def champion2(blink=False): return fox_stand(80,2.5,dict(FIRE,B='#EB5F28'),False,blink)
def ultra3(blink=False): return fox_stand(96,3,dict(FIRE,B='#DE4A26',E='#5A160E'),True,blink)
LINE=[('Baby: Pixi',pixi_baby,32),('Rookie: Blazebit',rookie,64),('Champion: Glutfuchs',champion2,80),('Ultra: Infernitsune',ultra3,96)]
if __name__=='__main__':
    sc=4;pad=16
    W=sum(n*sc+pad for _,_,n in LINE)+pad;H=96*sc+2*pad+24
    im=Image.new('RGBA',(W,H),(239,233,255,255));d=ImageDraw.Draw(im);x=pad
    for lab,f,n in LINE:
        spr=f();px.setN(n);im.alpha_composite(spr.img(sc),(x,H-pad-n*sc));d.text((x,6),f"{lab} ({n}x{n})",fill=(60,50,100));x+=n*sc+pad
    im.save('linie_big2.png')
