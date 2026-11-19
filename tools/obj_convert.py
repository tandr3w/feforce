import math

OBJ = "monkey.obj"

verts = []
uvs = []
tris = []

# read obj
for line in open(OBJ):
    p = line.split()

    if not p:
        continue

    if p[0] == "v":
        verts.append(tuple(map(float, p[1:4])))

    elif p[0] == "vt":
        uvs.append(tuple(map(float, p[1:3])))

    elif p[0] == "f":
        face = []
        for x in p[1:]:
            s = x.split("/")
            vi = int(s[0]) - 1
            ti = int(s[1]) - 1 if len(s) > 1 and s[1] else 0
            face.append((vi, ti))

        tris.append((face[0], face[1], face[2]))


def q88(x):
    return int(round(x * 256)) & 0xffff

def q114(x):
    return int(round(x * (1 << 14))) & 0xffff

out = """WIDTH=48;
DEPTH=4096;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;
CONTENT BEGIN
"""
with open("../sim/vertices.hex", "w") as f:
    for i, (x, y, z) in enumerate(verts):
        out += f"    {i} : {q88(x):04X}{q88(y):04X}{q88(z):04X};\n"
        f.write(f"{q88(x):04X}{q88(y):04X}{q88(z):04X}\n")

out += f"    [{len(verts)}..4095] : 0;\nEND;\n"

open("../vertices.mif", "w").write(out)


# triangles.mif
# 108 bits:
# normal x : 16
# normal y : 16
# normal z : 16
# u0 v0 : 6 + 6
# u1 v1 : 6 + 6
# u2 v2 : 6 + 6
# vertex0 vertex1 vertex2 : 8 each

out = """WIDTH=120;
DEPTH=4096;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;
CONTENT BEGIN
"""
with open("../sim/triangles.hex", "w") as f:

    for n, tri in enumerate(tris):
        (i0, t0), (i1, t1), (i2, t2) = tri

        a = verts[i0]
        b = verts[i1]
        c = verts[i2]

        # face normal = (B-A) x (C-A)
        ax, ay, az = b[0]-a[0], b[1]-a[1], b[2]-a[2]
        bx, by, bz = c[0]-a[0], c[1]-a[1], c[2]-a[2]

        nx = ay*bz - az*by
        ny = az*bx - ax*bz
        nz = ax*by - ay*bx

        length = math.sqrt(nx*nx + ny*ny + nz*nz)

        nx /= length
        ny /= length
        nz /= length

        # convert obj uv from 0-1 to texture coordinate from 0-64
        uv = []

        for t in (t0, t1, t2):
            u, v = uvs[t]

            u = round(u * 63)
            v = round((1-v) * 63)

            u = max(0, min(63, u))
            v = max(0, min(63, v))

            uv.append((u, v))

        u0, v0 = uv[0]
        u1, v1 = uv[1]
        u2, v2 = uv[2]

        value = q114(nx)
        value = (value << 16) | q114(ny)
        value = (value << 16) | q114(nz)

        value = (value << 6) | u0
        value = (value << 6) | v0
        value = (value << 6) | u1
        value = (value << 6) | v1
        value = (value << 6) | u2
        value = (value << 6) | v2

        value = (value << 12) | i0
        value = (value << 12) | i1
        value = (value << 12) | i2

        out += f"    {n} : {value:030X};\n"
        f.write(f"{value:030X}\n")
    f.write("0" * 30 + "\n")
# zero = end-of-model marker like you already use
out += f"    [{len(tris)}..4095] : 0;\nEND;\n"

open("../triangles.mif", "w").write(out)

print(len(verts), "vertices")
print(len(tris), "triangles")