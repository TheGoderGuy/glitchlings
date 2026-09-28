from px import *
OL='#231B3F'
def face(s,lx,rx,y,blink,cheek='#FFA7C8',mouth='smile',my=None,mx=None,angry=0,ew=3,eh=4):
    s.eye(lx,y,ew,eh,blink=blink,angry=angry); s.eye(rx,y,ew,eh,blink=blink,angry=-angry if angry else 0)
    if cheek:
        cy=y+eh
        for (cx) in (lx-2,rx+ew): s.px([(cx,cy),(cx+1,cy)],cheek)
    mx=mx if mx is not None else (lx+rx+ew)//2-1; my=my if my is not None else y+eh+1
    if mouth=='smile': s.px([(mx-1,my),(mx+2,my),(mx,my+1),(mx+1,my+1)],'#5A2F63')
    elif mouth=='open': s.px([(mx,my),(mx+1,my),(mx-1,my+1),(mx+2,my+1),(mx,my+1),(mx+1,my+1),(mx,my+2),(mx+1,my+2)],'#5A2F63'); s.px([(mx,my+2),(mx+1,my+2)],'#FF7E9E')
    elif mouth=='grr': s.px([(mx-1,my+1),(mx,my),(mx+1,my),(mx+2,my+1)],'#3A1850')
    elif mouth=='cat': s.px([(mx-1,my),(mx,my+1),(mx+1,my),(mx+2,my+1),(mx+3,my)],'#5A2F63')

def pixi(blink=False,base='#E3DBFF',extra=None,antenna=True,tail=True,mouth='smile',angry=0,cheek='#FFA7C8',glitch=True,pre=None):
    s=S()
    # Schwänzchen (Pixel-Kringel rechts)
    if pre: pre(s)
    if tail:
        tl=s.m_ell(26.5,24,3.2,2.6)|s.m_ell(28.5,20.5,1.8,2.2)
        s.body(tl,base)
    b=s.m_ell(15.5,20,11.5,9.5)
    s.body(b,base)
    # Füßchen
    for fx in (9,19): s.body(s.m_rect(fx,27,fx+3,29,1),base,vert=.6)
    # Antenne
    if antenna:
        s.paint(s.m_line([(15,4),(15,11)]),mix(base,'#6B5BA8',.45))
        s.body(s.m_ell(15.5,4,2.3,2.3),'#FF7EB6')
    if extra: extra(s)
    face(s,10,18,15 if not angry else 16,blink,eh=5 if not angry else 4,mouth=mouth,angry=angry,cheek=cheek)
    if glitch:
        s.px([(3,12),(5,9),(27,11)],mix(base,'#FF7EB6',.3)); s.px([(2,15)],'#B9E7FF')
    s.outline(); return s

def funkling(blink=False,base='#FF9447',ray='#FFD34D'):
    s=S()
    rays=[(16,1),(23,5),(29,12),(26,21),(21,29),(10,29),(5,21),(2,12),(8,5)]
    cx,cy=15.5,16.5
    for (x,y) in rays:
        import math
        a=math.atan2(y-cy,x-cx); px_=math.cos(a+1.57)*2.4; py_=math.sin(a+1.57)*2.4
        s.body(s.m_poly([(x,y),(cx+px_*1.4+ (x-cx)*.35,cy+py_*1.4+(y-cy)*.35),(cx-px_*1.4+(x-cx)*.35,cy-py_*1.4+(y-cy)*.35)]),ray,vert=.1)
    s.body(s.m_ell(cx,cy,9.5,8.8),base,vert=.15)
    face(s,10,18,13,blink,cheek='#FFD0A0',mouth='open')
    s.px([(4,3),(27,27),(29,4)],'#FFF1A6')
    s.outline(); return s

def troepfel(blink=False,base='#4CC3F0'):
    s=S()
    m=s.m_ell(15.5,20.5,11,9.5)|s.m_poly([(15.5,1),(7,15),(24,15)])
    s.body(m,base)
    # Ladekreis-Punkte auf der Stirn
    for i,(x,y) in enumerate([(13,9),(15,8),(17,8),(19,9)]): s.px([(x,y)],mix(base,'#FFFFFF',.2+.2*i))
    face(s,10,19,16,blink,cheek='#9FE3FF',mouth='cat',mx=15)
    # Glanzstreifen
    s.px([(8,15),(7,17),(7,18)],'#FFFFFF')
    s.outline(); return s

def bugsy(blink=False,base='#A970F5'):
    s=S()
    # Beine
    for (a,b) in [((6,19),(2,22)),((6,23),(2,27)),((8,27),(5,30)),((25,19),(29,22)),((25,23),(29,27)),((23,27),(26,30))]:
        s.paint(s.m_line([a,b]),'#4B2A7A')
    # Fühler
    s.paint(s.m_line([(12,7),(8,2)]),'#4B2A7A'); s.paint(s.m_line([(19,7),(23,2)]),'#4B2A7A')
    s.body(s.m_ell(7.5,2,1.6,1.6),'#FF7AA8'); s.body(s.m_ell(23.5,2,1.6,1.6),'#FF7AA8')
    # Panzer
    shell=s.m_ell(15.5,20,11,9.5)
    s.body(shell,base)
    s.paint(s.m_line([(15,13),(15,29)]),'#4B2A7A'); 
    s.px([(10,20),(11,20),(20,23),(21,23),(19,17)],mix(base,'#2A1650',.35))
    # Kopf
    s.body(s.m_ell(15.5,10,7.5,5),mix(base,'#2A1650',.1))
    s.eye_white(10,8,4,3,side=1,blink=blink,brow=1); s.eye_white(18,8,4,3,side=-1,blink=blink,brow=-1)
    s.px([(14,13),(15,12),(16,12),(17,13)],'#E7D2FF')
    s.outline(); return s

def motte(blink=False,base='#FFD24A'):
    s=S()
    wingL=s.m_ell(8,12,7.5,7.5)|s.m_ell(9.5,23,5.5,5)
    wingR=s.m_ell(23,12,7.5,7.5)|s.m_ell(21.5,23,5.5,5)
    s.body(wingL,base,vert=.2); s.body(wingR,base,vert=.2)
    for (x,y) in [(5,9),(25,9)]:
        s.body(s.m_ell(x+.5,y+.5,2.4,2.4),'#FF7AA8',flat=True,dither=False); s.px([(x,y)],'#FFFFFF')
    for (x,y) in [(8,23),(22,23)]: s.px([(x,y),(x+1,y),(x,y+1),(x+1,y+1)],'#FF9F43')
    # kleiner Körper unter dem Kopf
    s.body(s.m_ell(15.5,24,3.2,5),'#E0A64A')
    s.px([(14,24),(15,24),(16,24),(17,24)],'#B8792F'); s.px([(14,26),(15,26),(16,26),(17,26)],'#B8792F')
    # flauschiger Kopf
    head=s.m_ell(15.5,15,6.8,6.2)|s.m_ell(12,10,2,2)|s.m_ell(19,10,2,2)
    s.body(head,'#FFF3D6',vert=.25); s.contour(head,'#8A5A3C')
    s.paint(s.m_line([(13,9),(10,3)]),'#8A5A3C'); s.paint(s.m_line([(18,9),(21,3)]),'#8A5A3C')
    s.px([(9,2),(10,1),(11,2),(20,2),(21,1),(22,2)],'#FF9F43')
    s.eye(11,13,3,4,blink=blink); s.eye(18,13,3,4,blink=blink)
    s.px([(9,17),(10,17),(21,17),(22,17)],'#FFA7C8')
    s.px([(15,18),(16,18)],'#5A2F63')
    s.outline(); return s

def spamlet(blink=False,base='#F4ECFF'):
    s=S()
    for x in (9,21): s.body(s.m_rect(x,27,x+2,30,1),'#8E5CD9')
    win=s.m_rect(3,5,28,27,4)
    s.body(win,base,vert=.2)
    bar=s.m_rect(3,5,28,10,4)&(np.mgrid[0:N,0:N][0]<=10)
    s.body(bar,'#B26BFF',vert=0)
    s.body(s.m_rect(23,6,26,9,1),'#FF5470',vert=0); s.px([(24,7),(25,8),(25,7),(24,8)],'#FFD6DE')
    for x in (6,9,12): s.px([(x,7),(x,8)],'#E6CCFF')
    s.eye(8,14,4,4,blink=blink); s.eye(19,14,4,4,blink=blink)
    for cx in (6,24): s.px([(cx,19),(cx+1,19)],'#FFA7C8')
    s.px([(13,20),(18,20),(14,21),(15,21),(16,21),(17,21)],'#5A2F63'); s.px([(15,22),(16,22)],'#FF7E9E')
    # Ladebalken unten
    s.paint(s.m_rect(7,24,24,25),'#D8C7F2'); s.paint(s.m_rect(7,24,15,25),'#58D68D')
    s.outline(); return s

def boss(blink=False,base='#F1E6FF'):
    s=S()
    for x in (6,12,19,25): s.body(s.m_rect(x,28,x+2,31,1),'#6B32C9')
    s.body(s.m_rect(1,7,30,29,4),base,vert=.2)
    bar=s.m_rect(1,7,30,12,4)&(np.mgrid[0:N,0:N][0]<=12)
    s.body(bar,'#8B3DF0',vert=0)
    s.body(s.m_rect(26,8,29,11,1),'#FF5470',vert=0)
    # Krone
    crown=s.m_poly([(5,7),(5,1),(9,4),(12,0),(15.5,4),(19,0),(22,4),(26,1),(26,7)])
    s.body(crown,'#FFCF3F',vert=.1)
    s.px([(12,2),(19,2)],'#FF5470'); s.px([(15,4),(16,4)],'#58D68D')
    s.eye_white(6,15,6,4,side=1,blink=blink,brow=1); s.eye_white(20,15,6,4,side=-1,blink=blink,brow=-1)
    mouth=s.m_rect(7,21,24,26,2); s.paint(mouth,'#5A1F4F')
    for x in range(8,24,3): s.px([(x,21),(x+1,21),(x,22)],'#FFFFFF'); s.px([(x+1,26),(x+2,26),(x+2,25)],'#FFFFFF')
    s.px([(14,25),(15,25),(16,24),(17,25)],'#FF7E9E')
    s.outline(); return s


# ---------- Evolutionen ----------
def blazebit(blink=False):
    def pre(s):
        fl=s.m_poly([(9,12),(10,4),(13,8),(15,0),(18,7),(21,3),(22,12)])
        s.body(fl,'#FFC23D',vert=-.2)
        s.body(s.m_poly([(12,12),(14,6),(16,9),(18,5),(20,12)]),'#FF6A2B',vert=0)
        tf=s.m_poly([(25,25),(31,15),(29,23),(31,22),(28,27)]); s.body(tf,'#FFB23D')
    def ex(s): s.px([(3,6),(28,5),(1,20)],'#FFE08A')
    return pixi(blink,base='#FF8A4C',pre=pre,extra=ex,antenna=False,tail=False,mouth='open',cheek='#FFC9A0',glitch=False)
def firewallo(blink=False):
    def ex(s):
        ys=np.mgrid[0:N,0:N][0]
        helm=s.m_ell(15.5,16,13,9)&(ys<=15)&(ys>=7)
        s.body(helm,'#E4664D',vert=.05,dither=False)
        mort='#FFD2C2'
        s.paint(s.m_line([(3,11),(28,11)])&helm,mort)
        s.paint(s.m_line([(3,14),(28,14)])&helm,mort)
        for x in (10,17,24): s.paint(s.m_line([(x,8),(x,10)])&helm,mort)
        for x in (6,13,20,27): s.paint(s.m_line([(x,12),(x,13)])&helm,mort)
        s.contour(helm,'#7A2A1E')
        s.px([(3,24),(2,25),(3,26),(28,24),(29,25),(28,26)],'#1F7A4B')
    return pixi(blink,base='#58D68D',extra=ex,antenna=False,mouth='smile',angry=1,cheek=None,glitch=False)
def virulina(blink=False):
    def ex(s):
        for (x,y) in [(7,19),(8,19),(7,20),(22,23),(23,23),(23,22),(12,26),(13,26),(24,17),(5,24)]: s.px([(x,y)],'#7B3AB8')
        s.px([(17,20)],'#FFFFFF')
    def pre(s):
        # zwei kleine Fühler mit Viruskugeln
        s.paint(s.m_line([(11,11),(8,5)]),'#7B3AB8'); s.paint(s.m_line([(20,11),(23,5)]),'#7B3AB8')
        s.body(s.m_ell(8,4.5,2.4,2.4),'#58D68D'); s.body(s.m_ell(23.5,4.5,2.4,2.4),'#58D68D')
    return pixi(blink,base='#C77DFF',pre=pre,extra=ex,antenna=False,mouth='cat',cheek='#FF9ED0',glitch=True)
def prisma(blink=False):
    s=pixi(blink,base='#EEE8FF',antenna=False,glitch=False,mouth='smile')
    rb=['#FF9AA2','#FFC48C','#FFF08C','#A8F0B0','#9AD8FF','#C3A6FF']
    for y in range(N):
        for x in range(N):
            c=s.g[y,x]
            if c and c.startswith('#') and s.reg[y,x]>0 and c not in ('#231B3F','#FFFFFF','#5A2F63','#FFA7C8','#6D5BD0'):
                k=hx(c); lum=sum(k)/765
                if lum>.5:
                    band=rb[((x+y)//4)%len(rb)]; s.g[y,x]=mix(band,c,.1 if lum<.8 else .3)
    # Prisma-Stern als Antenne
    for (x,y,c) in [(15,2,'#FFFFFF'),(14,3,'#9AD8FF'),(16,3,'#FF9AA2'),(15,3,'#FFFFFF'),(15,4,'#FFF08C'),(13,3,'#C3A6FF'),(17,3,'#A8F0B0'),(15,1,'#FFC48C')]:
        s.g[y,x]=c
    for (x,y) in [(3,7),(28,6),(2,21),(29,28)]: s.g[y,x]='#FFFFFF'
    return s
def glutbyte(blink=False):
    s=funkling(blink,base='#E8452C',ray='#FF7A2E')
    # glühende Risse und Lava-Tropfen
    for (x,y) in [(8,19),(9,20),(10,20),(22,11),(23,12),(21,22),(22,22)]: s.g[y,x]='#FFE08A'
    for (x,y) in [(12,27),(12,28),(19,27),(19,28),(19,29)]: s.g[y,x]='#FFB03B'
    for (x,y) in [(12,29),(19,30)]: s.g[y,x]='#8C2A12'
    return s
def overclocko(blink=False):
    s=S()
    import math
    cx,cy=15.5,16.5
    for i in range(6):
        a=i/6*math.tau+.3
        p=[(cx,cy),(cx+math.cos(a)*14,cy+math.sin(a)*14),(cx+math.cos(a+.55)*13,cy+math.sin(a+.55)*13)]
        s.body(s.m_poly(p),'#B8D4E6',vert=.1)
    s.body(s.m_ell(cx,cy,9,8.5),'#58D68D',vert=.2)
    # Visier-Brille
    s.paint(s.m_rect(7,12,24,17,2),'#2A3550')
    s.eye_white(9,13,4,3,side=1,blink=blink); s.eye_white(19,13,4,3,side=1,blink=blink)
    s.px([(8,12),(9,12),(10,12)],'#6F8BB0')
    s.px([(13,20),(14,21),(15,21),(16,21),(17,21),(18,20)],'#1F5A3A')
    s.px([(6,21),(7,21),(24,21),(25,21)],'#9CEFC0')
    s.outline(); return s
def kaskadi(blink=False):
    def base(s):
        pass
    s=S()
    # Welle als Flosse/Mähne
    fin=s.m_poly([(16,3),(25,6),(22,9),(28,11),(23,14),(18,12)])
    s.body(fin,'#9AE6FF',vert=0)
    m=s.m_ell(14.5,20.5,11,9.5)|s.m_poly([(12,2),(6,15),(22,15)])
    s.body(m,'#2F9BE0')
    # Hörnchen
    s.body(s.m_poly([(7,10),(5,5),(10,9)]),'#FFFFFF'); 
    tail=s.m_poly([(24,25),(31,27),(29,22)]); s.body(tail,'#2F9BE0')
    face(s,9,18,16,blink,cheek='#9FE3FF',mouth='open',mx=14)
    s.px([(7,16),(6,18)],'#FFFFFF')
    s.outline(); return s
def pufferling(blink=False):
    s=S()
    import math
    cx,cy=15.5,17
    for i in range(12):
        a=i/12*math.tau
        x,y=cx+math.cos(a)*13.5,cy+math.sin(a)*12.5
        s.body(s.m_poly([(x,y),(cx+math.cos(a-.18)*10,cy+math.sin(a-.18)*9.5),(cx+math.cos(a+.18)*10,cy+math.sin(a+.18)*9.5)]),'#3FB98A',vert=0,dither=False)
    s.body(s.m_ell(cx,cy,11.5,10.5),'#7FE0B4')
    s.body(s.m_ell(cx,cy+5,8,4),'#E6FFF2',flat=True,dither=False)
    face(s,9,19,12,blink,cheek='#FFB0CF',mouth='smile')
    # Speicher-Balken auf dem Bauch
    for i,x in enumerate(range(11,21,2)): s.px([(x,21),(x,22)],'#3FB98A' if i<3 else '#C9F2DD')
    s.outline(); return s
def frostbyte(blink=False):
    s=S()
    m=s.m_ell(15.5,21,10.5,9)|s.m_poly([(15.5,6),(7,16),(24,16)])
    s.body(m,'#A9E8FF')
    # Eiskristall-Krone
    cr=[(15,0),(15,1),(15,2),(15,3),(15,4),(15,5),(13,2),(14,3),(17,2),(16,3),(12,4),(18,4),(11,6),(12,6),(19,6),(20,6),(10,5),(21,5)]
    s.px(cr,'#FFFFFF'); s.px([(15,1),(13,2),(17,2)],'#E8FAFF')
    for (x,y) in [(9,10),(22,10),(8,12),(23,12)]: s.px([(x,y)],'#FFFFFF')
    face(s,10,19,17,blink,cheek='#FFC4DF',mouth='cat',mx=15)
    s.px([(8,17),(7,19)],'#FFFFFF')
    s.outline(); return s

EVO={'Blazebit':blazebit,'Firewallo':firewallo,'Virulina':virulina,'Prisma-Pixi':prisma,'Glutbyte':glutbyte,'Overclocko':overclocko,'Kaskadi':kaskadi,'Pufferling':pufferling,'Frostbyte':frostbyte}
ALL={'pixi':pixi,'funk':funkling,'drop':troepfel,'bug':bugsy,'moth':motte,'spam':spamlet,'boss':boss}
if __name__=='__main__':
    sc=8; keys=list(ALL); W=len(keys)*(N*sc+16)
    im=Image.new('RGBA',(W,2*(N*sc+16)),(239,233,255,255))
    im2=Image.new('RGBA',(W,2*(N*sc+16)),(30,23,56,255))
    for i,k in enumerate(keys):
        for j,bl in enumerate((False,True)):
            spr=ALL[k](blink=bl).img(sc); im.alpha_composite(spr,(8+i*(N*sc+16),8+j*(N*sc+16)))
    im.save('prev.png')
    ek=list(EVO);im3=Image.new('RGBA',(len(ek)*(N*6+12),N*6+12),(239,233,255,255))
    for i,k in enumerate(ek): im3.alpha_composite(EVO[k]().img(6),(6+i*(N*6+12),6))
    im3.save('evo.png')
