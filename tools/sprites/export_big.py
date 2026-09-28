import px, json
from big import pixi_baby, rookie, champion2, ultra3
CH="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$%&*+-/:;<=>?@^_~"
def enc(fn,n):
    a=fn(False); b=fn(True); px.setN(n); cols=[]
    for s in (a,b):
        for y in range(n):
            for x in range(n):
                c=s.g[y,x]
                if c and c not in cols: cols.append(c)
    assert len(cols)<=len(CH),(len(cols))
    pal={CH[i]:c for i,c in enumerate(cols)}; inv={c:k for k,c in pal.items()}
    rows=lambda s:[''.join(inv[s.g[y,x]] if s.g[y,x] else '.' for x in range(n)) for y in range(n)]
    dark=[inv[c] for c in cols if sum(px.hx(c))/765<.2]
    return {'n':n,'pal':pal,'px':rows(a),'pb':rows(b),'ol':''.join(dark)}, a
out={};imgs={}
for key,f,n in [('pixi',pixi_baby,32),('Blazebit',rookie,64),('Glutfuchs',champion2,80),('Infernitsune',ultra3,96)]:
    out[key],spr=enc(f,n); px.setN(n); spr.img(1).save(f'pngs/{key}_{n}.png'); spr.img(4).save(f'pngs/{key}_{n}_x4.png')
open('spr_big.js','w').write("Object.assign(SPR,"+json.dumps(out,separators=(',',':'),ensure_ascii=False)+");\n")
print({k:(v['n'],len(v['pal'])) for k,v in out.items()})
