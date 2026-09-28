from v3 import *
NAVY='#2A2450'
def almond(s,x,y,iris,blink=False,ol='#1A1433',brow=True):
    # 4x3 mandelförmiges Auge, nach rechts schauend, mit Braue
    if blink:
        s.px([(x,y+1),(x+1,y+1),(x+2,y+1),(x+3,y+2)],ol); return
    s.px([(x,y),(x+1,y),(x+2,y),(x+3,y+1),(x,y+1),(x,y+2),(x+1,y+2),(x+2,y+2),(x+3,y+2)],ol)
    s.px([(x+1,y+1),(x+2,y+1)],iris); s.px([(x+2,y+1)],mix(iris,'#FFFFFF',.55)); s.px([(x+1,y+1)],iris)
    if brow: s.px([(x-1,y-1),(x,y-1),(x+1,y-1),(x+2,y-2)],ol)
def fox4(blink=False):
    s=S();B='#ECE7FA';M='#4FF0C4'
    tail=s.m_poly([(10,22),(4,19),(1,12),(2,6),(5,10),(7,15),(12,19)])
    s.body(tail,B,dither=False,vert=.2)
    ys=np.mgrid[0:N,0:N][0]; s.body(tail&(ys<=10),M,dither=False,vert=0)
    for (x,y,c) in [(2,3,M),(4,4,'#B9FFF0'),(0,5,M),(3,1,'#FFFFFF')]: s.px([(x,y)],c)
    haunch=s.m_ell(12,24,4.5,4.8); s.body(haunch,B,dither=False)
    body=s.m_poly([(10,18),(18,15),(22,22),(21,29),(12,29),(9,24)]); s.body(body,B,dither=False)
    s.body(s.m_poly([(17,17),(22,22),(20,26),(16,21)]),'#FFFFFF',flat=True,dither=False)
    for (x0,x1) in ((18,20),(14,16)):
        leg=s.m_rect(x0,24,x1,30); s.body(leg,B,dither=False,vert=.3); s.paint(s.m_rect(x0,29,x1,30),NAVY)
    s.contour(body,'#6E62A8')
    ears=[s.m_poly([(13,8),(12,0),(17,5)]),s.m_poly([(17,6),(21,-1),(22,8)])]
    for e in ears: s.body(e,B,dither=False,vert=0)
    s.paint(ears[0]&(ys<=2),NAVY); s.paint(ears[1]&(ys<=1),NAVY)
    s.paint(s.m_poly([(18,5),(20,2),(20,6)]),'#9C8FD6')
    head=s.m_poly([(12,7),(20,4),(24,7),(29,10),(29,12),(23,14),(16,16),(12,13)])
    s.body(head,B,dither=False,vert=.25); s.contour(head,'#6E62A8')
    s.px([(13,15),(12,16),(14,16)],B)
    almond(s,19,7,M,blink)
    s.px([(28,10),(29,10),(29,11)],NAVY)
    s.px([(22,13),(23,13),(24,13),(25,12),(26,12)],NAVY); s.px([(24,14)],'#FFFFFF')
    # Schaltkreis-Linien
    s.px([(11,21),(12,21),(13,21),(13,22),(13,23),(14,23)],M); s.px([(14,23)],'#FFFFFF')
    s.px([(5,14),(6,14),(6,15),(7,16)],M)
    s.px([(14,11),(15,11),(16,12)],M)
    s.outline(); return s
def wolf4(blink=False):
    s=S();B='#F07A36';D='#3A2A38';Y='#FFD34D'
    tail=s.m_poly([(6,19),(0,12),(3,13),(1,6),(6,13),(8,11),(9,18)]); s.body(tail,'#FFB23D',dither=False,vert=0)
    s.body(s.m_poly([(6,18),(3,13),(6,14),(7,13),(8,17)]),'#FF5A2A',dither=False,vert=0)
    for (x0,x1,c) in ((7,9,D),(11,13,B),(15,17,D),(19,21,B)):
        s.body(s.m_rect(x0,24,x1,30),c if c!=B else B,dither=False,vert=.3)
    torso=s.m_ell(14,21,8.5,5); s.body(torso,B,dither=False)
    s.paint(torso&s.m_ell(12,17,8,3.2),mix(B,D,.45))
    s.body(s.m_poly([(18,19),(22,21),(20,25),(17,23)]),'#FFE3C2',flat=True,dither=False)
    s.contour(torso,'#7A2E12')
    mane=s.m_poly([(10,14),(8,5),(12,9),(13,2),(16,7),(18,2),(19,9)]); s.body(mane,Y,dither=False,vert=0)
    s.body(s.m_poly([(12,12),(12,6),(14,9),(15,5),(17,10)]),'#FF8A2A',dither=False,vert=0)
    ys=np.mgrid[0:N,0:N][0]
    ears=[s.m_poly([(15,9),(15,2),(19,7)]),s.m_poly([(19,7),(22,1),(23,9)])]
    for e in ears: s.body(e,B,dither=False,vert=0); s.paint(e&(ys<=4),D)
    head=s.m_poly([(13,9),(19,7),(24,10),(29,13),(29,15),(23,18),(16,18),(13,15)])
    s.body(head,B,dither=False,vert=.25); s.contour(head,'#7A2E12')
    s.paint(s.m_poly([(22,15),(29,15),(23,18),(18,17)]),'#FFE3C2')
    almond(s,19,10,Y,blink,ol='#2A1010')
    s.px([(28,13),(29,13),(29,14)],'#2A1010')
    s.px([(21,16),(22,16),(23,16),(24,16),(25,15),(26,15)],'#2A1010'); s.px([(24,17),(22,17)],'#FFFFFF')
    s.px([(10,22),(11,22),(12,23),(13,23)],Y)
    s.outline(); return s
def axo4(blink=False):
    s=S();B='#2F97D8';L='#7FF3FF';G='#FF4FA0'
    tail=s.m_poly([(7,21),(0,14),(1,21),(0,28),(8,24)]); s.body(tail,'#5BB8EA',dither=False,vert=.1)
    crest=s.m_poly([(7,19),(11,14),(15,16),(19,12),(19,17),(8,20)]); s.body(crest,'#8AD4F5',dither=False,vert=0)
    for (x0,x1) in ((9,11),(17,19)): s.body(s.m_rect(x0,24,x1,29),'#2A7FB8',dither=False,vert=.2)
    body=s.m_ell(14,22,9.5,4.3); s.body(body,B,dither=False)
    s.body(s.m_ell(15,24.5,7,1.8),'#BFEFFF',flat=True,dither=False)
    for (x0,x1) in ((12,14),(20,22)): s.body(s.m_rect(x0,25,x1,30),B,dither=False,vert=.3)
    s.contour(body,'#12507A')
    for fr in ([(19,15),(15,6),(18,9),(17,3),(21,12)],[(22,13),(22,3),(24,8),(26,2),(25,12)],[(25,14),(29,6),(28,11),(31,9),(27,15)]):
        s.body(s.m_poly(fr),G,dither=False,vert=0)
    head=s.m_ell(24,17,6.5,4.8); s.body(head,B,dither=False,vert=.2); s.contour(head,'#12507A')
    almond(s,24,15,L,blink,ol='#0E2A44')
    s.px([(25,20),(26,20),(27,20),(28,19),(29,19)],'#0E2A44'); s.px([(27,21)],'#FFFFFF')
    s.px([(9,21),(10,21),(11,21),(12,22),(13,22),(14,22),(15,21),(16,21)],L)
    s.px([(3,21),(4,21)],L)
    s.outline(); return s
if __name__=='__main__':
    sc=7;pad=16
    im=Image.new('RGBA',(3*(N*sc+pad)+pad,2*(N*sc+pad)+pad+30),(239,233,255,255))
    old=[fox3,pup3,axo3];new=[fox4,wolf4,axo4]
    for i in range(3):
        im.alpha_composite(old[i]().img(sc),(pad+i*(N*sc+pad),pad+20))
        im.alpha_composite(new[i]().img(sc),(pad+i*(N*sc+pad),pad*2+20+N*sc))
    d=ImageDraw.Draw(im);d.text((pad,4),"NIEDLICH",fill=(80,70,120));d.text((pad,pad+20+N*sc+2),"COOLER",fill=(80,70,120))
    im.save('vergleich2.png')

def fox5(blink=False):
    s=S();B='#ECE7FA';M='#4FF0C4';E='#6E62A8'
    ys=np.mgrid[0:N,0:N][0]
    tail=s.m_poly([(10,23),(4,20),(1,13),(2,6),(5,10),(7,16),(12,20)])
    s.body(tail,B,dither=False,vert=.2); s.body(tail&(ys<=10),M,dither=False,vert=0)
    for (x,y,c) in [(2,3,M),(4,4,'#B9FFF0'),(0,5,M),(3,1,'#FFFFFF')]: s.px([(x,y)],c)
    s.body(s.m_ell(12,24.5,4.5,4.5),B,dither=False)
    body=s.m_poly([(11,17),(18,16),(22,22),(21,29),(12,29),(10,24)]); s.body(body,B,dither=False)
    s.body(s.m_poly([(17,18),(22,22),(20,26),(16,22)]),'#FFFFFF',flat=True,dither=False)
    for (x0,x1) in ((18,20),(14,16)):
        s.body(s.m_rect(x0,24,x1,30),B,dither=False,vert=.3); s.paint(s.m_rect(x0,29,x1,30),NAVY)
    s.contour(body,E)
    ears=[s.m_poly([(12,8),(11,0),(16,5)]),s.m_poly([(16,5),(20,-1),(21,7)])]
    for e in ears: s.body(e,B,dither=False,vert=0)
    s.paint(ears[0]&(ys<=2),NAVY); s.paint(ears[1]&(ys<=1),NAVY); s.paint(s.m_poly([(17,5),(19,2),(19,6)]),'#9C8FD6')
    skull=s.m_ell(17,10.5,6.5,5.2)
    snout=s.m_poly([(21,9),(27,11),(27,13),(21,15)])
    cheek=s.m_poly([(11,11),(9,15),(13,14),(12,17),(16,15),(18,16),(20,14)])
    head=skull|snout|cheek
    s.body(head,B,dither=False,vert=.25); s.contour(head,E)
    s.paint(s.m_poly([(21,13),(27,13),(21,15)]),'#FFFFFF')
    almond(s,18,8,M,blink)
    s.px([(21,11),(22,11)],NAVY)
    s.px([(26,10),(27,10),(27,11)],NAVY)
    s.px([(22,13),(23,13),(24,13),(25,12)],NAVY)
    s.px([(11,21),(12,21),(13,21),(13,22),(13,23),(14,23)],M); s.px([(14,23)],'#FFFFFF')
    s.px([(5,14),(6,14),(6,15),(7,16)],M); s.px([(13,9),(14,9),(15,10)],M)
    s.outline(); return s
def axo5(blink=False):
    s=S();B='#2F97D8';L='#7FF3FF';G='#FF4FA0'
    tail=s.m_poly([(6,21),(0,15),(1,21),(0,27),(7,24)]); s.body(tail,'#5BB8EA',dither=False,vert=.1)
    crest=s.m_poly([(6,19),(9,15),(13,17),(16,14),(16,18),(7,20)]); s.body(crest,'#8AD4F5',dither=False,vert=0)
    for (x,y) in ((8,27),(15,27)): s.body(s.m_ell(x,y,2.2,2),'#2A7FB8',dither=False,vert=.2)
    body=s.m_ell(12,22,8,4.3); s.body(body,B,dither=False)
    s.body(s.m_ell(13,24.5,5.5,1.7),'#BFEFFF',flat=True,dither=False)
    for (x,y) in ((11,28),(18,28)): s.body(s.m_ell(x,y,2.3,2),B,dither=False,vert=.3)
    s.contour(body,'#12507A')
    for fr in ([(18,13),(14,5),(17,8),(16,2),(20,10)],[(21,11),(21,2),(23,6),(25,1),(24,10)],[(25,12),(29,4),(28,9),(31,7),(27,13)]):
        s.body(s.m_poly(fr),G,dither=False,vert=0)
    head=s.m_ell(23,16.5,7.5,5.8); s.body(head,B,dither=False,vert=.2); s.contour(head,'#12507A')
    s.body(s.m_ell(24,20,5.5,1.6),'#BFEFFF',flat=True,dither=False)
    almond(s,23,14,L,blink,ol='#0E2A44')
    s.px([(22,19),(23,19),(24,19),(25,19),(26,19),(27,18),(28,18)],'#0E2A44'); s.px([(26,20)],'#FFFFFF')
    s.px([(7,21),(8,21),(9,21),(10,22),(11,22),(12,22),(13,21),(14,21)],L); s.px([(3,21),(4,21)],L)
    s.px([(19,15),(19,16)],L)
    s.outline(); return s
if __name__=='__main__':
    sc=7;pad=16
    im=Image.new('RGBA',(3*(N*sc+pad)+pad,N*sc+2*pad),(239,233,255,255))
    for i,f in enumerate([fox5,wolf4,axo5]): im.alpha_composite(f().img(sc),(pad+i*(N*sc+pad),pad))
    im.save('cool.png')
