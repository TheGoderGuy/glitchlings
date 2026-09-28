from mons import *
import math
def cookie(s,base,cx=15.5,cy=18,r=11.5,bite=True):
    m=s.m_ell(cx,cy,r,r*.92)
    if bite: m=m&~s.m_ell(cx+r*.85,cy-r*.75,4.2,4.2)
    s.body(m,base); return m
def chips(s,pts,col): 
    for (x,y) in pts: s.px([(x,y),(x+1,y),(x,y+1)],col)

def kekso(blink=False):
    s=S(); cookie(s,'#E2A866')
    chips(s,[(7,13),(22,20),(9,24),(18,26),(24,14)],'#5B3420')
    s.px([(6,19),(26,24)],'#58D68D')  # Code-Bits
    face(s,10,18,15,blink,cheek='#FF9E8A',mouth='open',mx=14)
    s.px([(28,7),(29,8),(27,10)],'#E2A866')  # Krümel
    s.outline(); return s
def tracko(blink=False):
    s=S(); cookie(s,'#C9925E',cy=19,bite=False)
    chips(s,[(7,20),(22,24),(12,26),(24,16)],'#7B3AB8')
    hat=s.m_ell(15.5,10,11,5)&(np.mgrid[0:N,0:N][0]<=11)
    s.body(hat,'#8A6A4A'); s.body(s.m_ell(15.5,6.5,6.5,4.5),'#9E7B55')
    s.paint(s.m_line([(9,9),(22,9)]),'#5C4330')
    s.eye_white(10,15,4,3,side=1,blink=blink,brow=1); s.eye_white(18,15,4,3,side=1,blink=blink,brow=-1)
    s.px([(14,21),(15,21),(16,21),(17,20)],'#5A2F63')
    # Lupe
    lens=s.m_ell(27,24,3.2,3.2); s.body(lens,'#BFEFFF',flat=True,dither=False); s.contour(lens,'#5C4330')
    s.paint(s.m_line([(25,26),(22,29)],w=2),'#5C4330'); s.px([(26,23)],'#FFFFFF')
    s.outline(); return s
def cachy(blink=False):
    s=S()
    for i in range(8):
        a=i/8*math.tau; x,y=15.5+math.cos(a)*14.5,17.5+math.sin(a)*13.5
        s.body(s.m_poly([(x,y),(15.5+math.cos(a-.2)*11,17.5+math.sin(a-.2)*10.5),(15.5+math.cos(a+.2)*11,17.5+math.sin(a+.2)*10.5)]),'#FFE58A',vert=0,dither=False)
    cookie(s,'#FFC766',cy=17.5,r=10.5,bite=False)
    heart=[(21,21),(22,20),(23,21),(24,20),(25,21),(21,22),(22,22),(23,22),(24,22),(25,22),(22,23),(23,23),(24,23),(23,24)]
    s.px(heart,'#FF6F91'); chips(s,[(8,21),(12,24)],'#A0602A')
    face(s,10,18,13,blink,cheek='#FF9EB0',mouth='smile')
    s.outline(); return s
def cursor_shape(s,ox=0,oy=0,sc=1.0):
    P=[(6,3),(6,24),(11,19),(15,28),(19,26),(15,17),(22,17)]
    return s.m_poly([(ox+(x-6)*sc+6,oy+(y-3)*sc+3) for x,y in P])
def lumi(blink=False):
    s=S()
    bulb=s.m_ell(25,25,4.5,4.5); s.body(bulb,'#FFE45C',vert=-.1)
    s.px([(24,23),(23,24)],'#FFFFFF'); s.paint(s.m_line([(19,24),(22,25)]),'#C9B24A')
    s.body(cursor_shape(s,1,0),'#F7F3FF')
    s.eye(8,12,2,3,blink=blink); s.eye(13,12,2,3,blink=blink)
    s.px([(7,16),(15,16)],'#FFA7C8'); s.px([(10,16),(11,16)],'#5A2F63')
    for (x,y) in [(28,17),(29,30),(20,30)]: s.px([(x,y)],'#FFF3A0')
    s.outline(); return s
def blinki(blink=False):
    s=S()
    for side in (-1,1):
        cx=15+side*8
        bolt=s.m_poly([(cx,6),(cx+side*7,9),(cx+side*3,12),(cx+side*8,16),(cx+side*1,14),(cx+side*3,11)])
        s.body(bolt,'#FFE45C',vert=0)
    s.body(cursor_shape(s,4,1,.95),'#FFD84D')
    s.eye(11,13,2,3,blink=blink); s.eye(16,13,2,3,blink=blink)
    s.px([(13,17),(14,17)],'#7A5200'); s.px([(9,17),(18,17)],'#FF9E6B')
    for (x,y) in [(2,24),(28,26),(25,3)]: s.px([(x,y),(x+1,y),(x,y+1)],'#FFFFFF')
    s.outline(); return s
def screenshina(blink=False):
    s=S()
    s.body(s.m_rect(3,5,28,26,2),'#E8B64A',vert=.1)
    ys=np.mgrid[0:N,0:N][0]
    pic=s.m_rect(6,8,25,23)
    s.paint(pic&(ys<=15),'#BDE6FF'); s.body(pic&(ys>15),'#58D68D',vert=.1,dither=False)
    s.paint(s.m_ell(21,11,2,2),'#FFF3A0')
    s.eye(10,13,3,4,blink=blink); s.eye(18,13,3,4,blink=blink)
    s.px([(8,18),(9,18),(22,18),(23,18)],'#FFA7C8'); s.px([(14,19),(15,20),(16,20),(17,19)],'#1F5A3A')
    s.body(s.m_poly([(13,26),(18,26),(20,30),(15.5,28),(11,30)]),'#FF6F91',vert=0)
    for (x,y) in [(1,3),(30,2),(30,28)]: s.px([(x,y)],'#FFFFFF')
    s.outline(); return s
def popupsi(blink=False):
    s=S()
    for i,(ox,oy,col) in enumerate([(10,1,'#D9B8FF'),(5,6,'#E9D8FF'),(0,11,'#F4ECFF')]):
        w=s.m_rect(ox+1,oy+1,ox+21,oy+18,3); s.body(w,col,vert=.15)
        bar=s.m_rect(ox+1,oy+1,ox+21,oy+5,3)&(np.mgrid[0:N,0:N][0]<=oy+5); s.body(bar,'#C77DFF',vert=0)
        s.px([(ox+18,oy+2),(ox+19,oy+2),(ox+18,oy+3),(ox+19,oy+3)],'#FF5470')
        if i<2: s.contour(w,'#6B3B9E')
    s.eye(4,19,3,4,blink=blink); s.eye(13,19,3,4,blink=blink)
    s.px([(2,23),(3,23),(17,23),(18,23)],'#FFA7C8')
    s.px([(8,24),(9,25),(10,25),(11,24)],'#5A2F63'); s.px([(9,26),(10,26)],'#FF7E9E')
    s.outline(); return s
def trojo(blink=False):
    s=S()
    for x in (7,11,20,24): s.body(s.m_rect(x,23,x+2,29,1),'#A56A36',vert=.3)
    s.body(s.m_rect(5,14,26,24,3),'#C98B4F',vert=.2)
    s.body(s.m_poly([(20,15),(24,5),(29,5),(29,10),(26,11),(25,16)]),'#C98B4F',vert=.1)
    s.px([(24,3),(25,4),(22,5),(23,6)],'#E0A866'); s.paint(s.m_line([(21,6),(19,14)],w=1),'#7A4A1E')
    s.eye(26,7,2,2,blink=blink)
    for y in (17,21): s.paint(s.m_line([(6,y),(25,y)]),'#A56A36')
    door=s.m_rect(10,16,17,22,1); s.paint(door,'#3A2210')
    if not blink: s.px([(12,18),(15,18)],'#FFE45C')
    s.body(s.m_poly([(5,15),(1,19),(3,20),(5,18)]),'#7A4A1E',vert=0)
    for x in (6,12,20,26): s.px([(x,30)],'#58D68D')
    s.outline(); return s
def dampfbyte(blink=False):
    s=S()
    for (x,y,r) in [(9.5,6,2.6),(5.5,3.5,2),(12.5,2,1.5)]:
        s.body(s.m_ell(x,y,r,r*.85),'#E3EAF5',vert=.3)
    s.body(s.m_rect(7,8,11,14,1),'#5A3A3A',vert=0); s.paint(s.m_rect(6,8,12,9),'#3E2828')
    s.body(s.m_rect(3,13,27,24,5),'#E8563A')
    s.body(s.m_rect(19,6,29,16,2),'#C9432E',vert=.1)
    s.paint(s.m_rect(21,8,27,12,1),'#BDE6FF'); s.px([(22,9)],'#FFFFFF')
    s.eye(7,16,3,4,blink=blink); s.eye(14,16,3,4,blink=blink)
    s.px([(5,21),(6,21),(18,21),(19,21)],'#FFC9A0'); s.px([(11,21),(12,22),(13,21)],'#5A1F1A')
    for x in (7,19): 
        w=s.m_ell(x+.5,26.5,3.5,3.5); s.body(w,'#4A4460',vert=.1); s.px([(x,26)],'#B8B0DD')
    s.px([(24,26),(25,26)],'#FFB03B')
    s.outline(); return s
def wolkerich(blink=False):
    s=S()
    for (x,y) in [(9,24),(16,27),(23,25)]: s.px([(x,y),(x,y+1)],'#4CC3F0')
    cl=s.m_ell(10,15,7,6)|s.m_ell(18,11,8,7.5)|s.m_ell(24,16,6,5.5)|s.m_rect(4,15,29,21,5)
    s.body(cl,'#EAF6FF',vert=.45)
    s.eye(11,13,3,4,blink=blink); s.eye(19,13,3,4,blink=blink)
    s.px([(9,17),(10,17),(22,17),(23,17)],'#FFB0CF'); s.px([(15,18),(16,19),(17,18)],'#3A5A7A')
    s.px([(26,9),(25,10),(26,10),(27,10),(26,11),(26,12)],'#4CC3F0')
    s.outline(); return s
def quellcoda(blink=False):
    s=S()
    segs=[(6,26),(9,24),(12,23),(15,24),(18,25),(21,24),(23,21),(22,18),(19,16),(16,15),(13,14),(11,11)]
    for i,(x,y) in enumerate(segs):
        s.body(s.m_ell(x+.5,y+.5,3.2,3.2),'#FFD84D' if i%2 else '#FFE89A',vert=.2,dither=False)
    for i,(x,y) in enumerate(segs[::2]): s.px([(x-1,y),(x,y),(x+1,y)],'#B08A1E' if i%2 else '#58D68D')
    head=s.m_ell(12,8,6.5,5); s.body(head,'#FFD84D')
    s.eye(8,6,2,3,blink=blink); s.eye(14,6,2,3,blink=blink)
    s.px([(11,11),(12,11)],'#7A5200'); s.px([(12,13),(11,14),(13,14)],'#FF5470')
    s.px([(22,4),(24,4),(23,3),(23,5)],'#FFFFFF')
    s.outline(); return s
def geist404(blink=False):
    s=S()
    body=s.m_ell(15.5,13,11,10.5)|s.m_rect(4.5,13,26.5,26)
    for i,x in enumerate(range(4,28,5)): body=body&~s.m_ell(x+2.5,29.5,2.4,3.5)
    s.body(body,'#D9CCFF',vert=.25)
    D={'4':["1.1","1.1","111","..1","..1"],'0':["111","1.1","1.1","1.1","111"]}
    for k,ch in enumerate('404'):
        for yy,row in enumerate(D[ch]):
            for xx,c in enumerate(row):
                if c=='1': s.px([(10+k*4+xx,6+yy)],'#8A6BD6')
    s.eye(10,14,3,3,blink=blink); s.eye(18,14,3,3,blink=blink)
    s.px([(8,18),(9,18),(22,18),(23,18)],'#FFB0CF'); s.px([(14,19),(15,20),(16,19)],'#5A2F63')
    for (x,y) in [(1,6),(29,9),(27,2)]: s.px([(x,y)],'#FFFFFF')
    s.outline(); return s
def egg(col,spot,band=None):
    def f(blink=False):
        s=S(); m=s.m_ell(15.5,17.5,9.5,12); s.body(m,col,vert=.35)
        for (x,y,r) in [(11,11,1.8),(19,14,2.3),(13,21,2),(21,23,1.6),(9,17,1.4)]:
            sp=s.m_ell(x+.5,y+.5,r,r)&m; s.body(sp,spot,flat=True,dither=False)
        if band:
            ys=np.mgrid[0:N,0:N][0]; b=m&(ys>=16)&(ys<=17); s.paint(b,band)
        s.outline(); return s
    return f
NEW={'Kekso':kekso,'Tracko':tracko,'Cachy':cachy,'Lumi':lumi,'Blinki':blinki,'Screenshina':screenshina,'Pop-Upsi':popupsi,'Trojo':trojo,
     'Dampfbyte':dampfbyte,'Wolkerich':wolkerich,'Quellcoda':quellcoda,'404-Geist':geist404}
EGGS={'egg_g':egg('#FFF8EC','#7FE0B4'),'egg_s':egg('#F2FAFF','#4CC3F0'),'egg_e':egg('#F4ECFF','#C77DFF','#FFD84D')}
if __name__=='__main__':
    ks=list(NEW)+list(EGGS);sc=6;cols=5
    im=Image.new('RGBA',(cols*(N*sc+12)+12,((len(ks)+cols-1)//cols)*(N*sc+12)+12),(239,233,255,255))
    for i,k in enumerate(ks):
        f=NEW.get(k) or EGGS[k]; im.alpha_composite(f().img(sc),(12+(i%cols)*(N*sc+12),12+(i//cols)*(N*sc+12)))
    im.save('new.png')
