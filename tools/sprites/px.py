import numpy as np, colorsys
from PIL import Image, ImageDraw
N=32
def setN(n):
    global N
    N=n
def hx(c): c=c.lstrip('#'); return tuple(int(c[i:i+2],16) for i in (0,2,4))
def th(t): return '#%02X%02X%02X'%tuple(max(0,min(255,int(round(v)))) for v in t)
def mix(a,b,k): a,b=hx(a),hx(b); return th([a[i]+(b[i]-a[i])*k for i in range(3)])
def shift(c,dh=0,ds=0,dv=0):
    r,g,b=[v/255 for v in hx(c)]; h,s,v=colorsys.rgb_to_hsv(r,g,b)
    h=(h+dh)%1; s=max(0,min(1,s+ds)); v=max(0,min(1,v+dv)); return th([x*255 for x in colorsys.hsv_to_rgb(h,s,v)])
def ramp(base):
    # hi, light, base, shadow, deep, outline  (Schatten wandern Richtung Violett, Lichter Richtung Gelb)
    return [mix(shift(base,dh=+.02),'#FFFFFF',.62), mix(shift(base,dh=+.01),'#FFFFFF',.28), base,
            mix(shift(base,dh=-.03,ds=.08,dv=-.18),'#3A1F6B',.18), mix(shift(base,dh=-.05,ds=.1,dv=-.38),'#2A1650',.35),
            mix(shift(base,ds=.15,dv=-.62),'#1A0F33',.55)]
class S:
    def __init__(s):
        s.g=np.full((N,N),None,dtype=object); s.reg=np.zeros((N,N),int); s.nreg=0; s.ramps={}; s.ol={}
        s.eyes=[]
    def m_ell(s,cx,cy,rx,ry):
        y,x=np.mgrid[0:N,0:N]; return ((x+.5-cx)/rx)**2+((y+.5-cy)/ry)**2<=1
    def m_poly(s,pts):
        SS=4; im=Image.new('L',(N*SS,N*SS),0); ImageDraw.Draw(im).polygon([(x*SS,y*SS) for x,y in pts],fill=255)
        a=np.array(im,dtype=float).reshape(N,SS,N,SS).mean(axis=(1,3)); return a>=128
    def m_rect(s,x0,y0,x1,y1,r=0):
        im=Image.new('L',(N,N),0); ImageDraw.Draw(im).rounded_rectangle([x0,y0,x1,y1],radius=r,fill=1); return np.array(im)>0
    def m_line(s,pts,w=1):
        im=Image.new('L',(N,N),0); ImageDraw.Draw(im).line(pts,fill=1,width=w); return np.array(im)>0
    def body(s,mask,base,light=(-.62,-.78),flat=False,vert=.35,bands=(.84,.6,.34,.12),dither=True):
        s.nreg+=1; rid=s.nreg; R=ramp(base); s.ramps[rid]=R
        if not mask.any(): return rid
        m=mask.astype(float); k=np.ones(5)/5
        bl=np.apply_along_axis(lambda r:np.convolve(np.pad(r,2,mode='edge'),k,'valid'),1,m)
        bl=np.apply_along_axis(lambda c:np.convolve(np.pad(c,2,mode='edge'),k,'valid'),0,bl)
        gy,gx=np.gradient(bl); nx,ny=-gx,-gy; ln=np.hypot(nx,ny)+1e-6
        ys,xs=np.nonzero(mask); cy,cx=ys.mean(),xs.mean(); h=max(1,ys.max()-ys.min())
        for y,x in zip(ys,xs):
            e=min(1,ln[y,x]*3.2)
            d=(nx[y,x]/ln[y,x]*light[0]+ny[y,x]/ln[y,x]*light[1])*e
            # Kugel-Term: Abstand zum Lichtpunkt oben links
            lx,ly=cx-(xs.max()-xs.min())*.22, cy-h*.25
            sph=1-min(1,np.hypot((x-lx)/((xs.max()-xs.min())/2+1),(y-ly)/(h/2+1))*.75)
            lum=.40+.26*d+.42*sph-vert*(y-cy)/h
            if flat: lum=.5
            if dither: lum+=.022*(1 if (x+y)%2 else -1)
            i=0 if lum>bands[0] else 1 if lum>bands[1] else 2 if lum>bands[2] else 3 if lum>bands[3] else 4
            s.g[y,x]=R[i]; s.reg[y,x]=rid
        return rid
    def paint(s,mask,col,rid=None):
        ys,xs=np.nonzero(mask)
        for y,x in zip(ys,xs): s.g[y,x]=col; s.reg[y,x]=rid if rid is not None else s.reg[y,x] or 0
    def px(s,pts,col):
        for x,y in pts:
            if 0<=x<N and 0<=y<N: s.g[y,x]=col
    def eye(s,x,y,w=3,h=4,look=1,blink=False,angry=0,outline='#231B3F'):
        # Auge: dunkle Iris mit Glanzpunkt
        if blink:
            for i in range(w): s.g[y+h-2,x+i]=outline
            s.g[y+h-3,x]=outline if angry<0 else s.g[y+h-3,x]; return
        for yy in range(h):
            for xx in range(w):
                s.g[y+yy,x+xx]=outline
        s.g[y,x]='#FFFFFF'; 
        if h>=4: s.g[y+1,x]='#FFFFFF'
        s.g[y+h-1,x+w-1]='#6D5BD0' if w>2 else outline
        if angry: # schräge Braue
            for i in range(w+1):
                yy=y-1-(i if angry>0 else w-i)//2
                if 0<=yy<N: s.g[yy,x+i-(0 if angry>0 else 1)]=outline
    def eye_white(s,x,y,w,h,side=1,blink=False,outline='#231B3F',brow=0):
        if blink:
            for i in range(w): s.g[y+h//2,x+i]=outline
            return
        for yy in range(h):
            for xx in range(w): s.g[y+yy,x+xx]='#FFFFFF'
        px_=x+w-2 if side>0 else x
        for yy in range(h//2,h):
            for xx in range(2): s.g[y+yy,px_+xx]=outline
        if brow:
            for i in range(w):
                yy=y-1+( (i*2)//w if brow>0 else ((w-1-i)*2)//w )
                s.g[yy,x+i]=outline
    def contour(s,mask,col):
        for y in range(N):
            for x in range(N):
                if not mask[y,x]: continue
                for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
                    yy,xx=y+dy,x+dx
                    if 0<=yy<N and 0<=xx<N and not mask[yy,xx] and s.g[yy,xx] is not None:
                        s.g[y,x]=col;break
    def outline(s):
        filled=np.vectorize(lambda v:v is not None)(s.g)
        out=s.g.copy()
        for y in range(N):
            for x in range(N):
                if filled[y,x]: continue
                nb=[(y+dy,x+dx) for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)) if 0<=y+dy<N and 0<=x+dx<N and filled[y+dy,x+dx]]
                if nb:
                    rid=max(s.reg[a,b] for a,b in nb)
                    out[y,x]=s.ramps[rid][5] if rid in s.ramps else '#1E1238'
        s.g=out
    def img(s,scale=8,bg=None):
        im=Image.new('RGBA',(N*scale,N*scale),bg or (0,0,0,0)); d=ImageDraw.Draw(im)
        for y in range(N):
            for x in range(N):
                if s.g[y,x]: d.rectangle([x*scale,y*scale,x*scale+scale-1,y*scale+scale-1],fill=hx(s.g[y,x])+(255,))
        return im
