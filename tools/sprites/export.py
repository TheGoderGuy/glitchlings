from mons import *
from mons2 import NEW,EGGS
import json
CH="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$%&*+-/:;<=>?@^_~"
def enc(fn):
    a=fn(False); b=fn(True)
    cols=[]; 
    for s in (a,b):
        for y in range(N):
            for x in range(N):
                c=s.g[y,x]
                if c and c not in cols: cols.append(c)
    assert len(cols)<=len(CH),len(cols)
    pal={CH[i]:c for i,c in enumerate(cols)}; inv={c:k for k,c in pal.items()}
    rows=lambda s:[''.join(inv[s.g[y,x]] if s.g[y,x] else '.' for x in range(N)) for y in range(N)]
    dark=[inv[c] for c in cols if sum(hx(c))/765<.2]
    return {'pal':pal,'px':rows(a),'pb':rows(b),'ol':''.join(dark)}
out={}
for k,f in ALL.items(): out[k]=enc(f)
for k,f in EVO.items(): out[k]=enc(f)
for k,f in NEW.items(): out[k]=enc(f)
for k,f in EGGS.items(): out[k]=enc(f)
js="const SPR="+json.dumps(out,separators=(',',':'),ensure_ascii=False)+";\n"
open('spr.js','w').write(js); print(len(js))
# Übersichtsbilder für den Vault
sc=6;keys=list(ALL);im=Image.new('RGBA',(len(keys)*(N*sc+12)+12,N*sc+24),(239,233,255,255))
for i,k in enumerate(keys): im.alpha_composite(ALL[k]().img(sc),(12+i*(N*sc+12),12))
im.save('sheet_basis.png')
ek=list(EVO);im=Image.new('RGBA',(5*(N*sc+12)+12,2*(N*sc+12)+12),(239,233,255,255))
for i,k in enumerate(ek): im.alpha_composite(EVO[k]().img(sc),(12+(i%5)*(N*sc+12),12+(i//5)*(N*sc+12)))
im.save('sheet_evolutionen.png')
# Einzel-PNGs in Originalgröße (32x32) und 8x für Artists
import os; os.makedirs('pngs',exist_ok=True)
for k,f in list(ALL.items())+list(EVO.items())+list(NEW.items())+list(EGGS.items()):
    f().img(1).save(f'pngs/{k}.png'); f().img(8).save(f'pngs/{k}_x8.png'); f(True).img(1).save(f'pngs/{k}_blink.png')

# Gesamtübersicht aller 25 Monster in Dex-Reihenfolge
ORDER=[('Pixi','pixi'),('Blazebit',0),('Firewallo',0),('Virulina',0),('Prisma-Pixi',0),('Funkling','funk'),('Glutbyte',0),('Overclocko',0),
('Tröpfel','drop'),('Kaskadi',0),('Pufferling',0),('Frostbyte',0),('Kekso',0),('Tracko',0),('Cachy',0),('Lumi',0),('Blinki',0),('Screenshina',0),
('Spamlet','spam'),('Pop-Upsi',0),('Trojo',0),('Dampfbyte',0),('Wolkerich',0),('Quellcoda',0),('404-Geist',0)]
F={**{k:v for k,v in ALL.items()},**EVO,**NEW}
sc=5;cols=5;im=Image.new('RGBA',(cols*(N*sc+10)+10,5*(N*sc+10)+10),(239,233,255,255))
for i,(n,k) in enumerate(ORDER): im.alpha_composite(F[k or n]().img(sc),(10+(i%cols)*(N*sc+10),10+(i//cols)*(N*sc+10)))
im.save('sheet_alle25.png')
