# inspiration taken from https://github.com/kohterai/OBJ-Parser

import math

OBJ = "assets/cone.obj"

verts = []
uvs = []
tris = []

# read obj
for line in open(OBJ):
    args = line.split()

    if not args:
        continue

    if args[0] == "v":
        verts.append(tuple(map(float, args[1:4])))

    elif args[0] == "vt":
        uvs.append(tuple(map(float, args[1:3])))

    elif args[0] == "f":
        face = []
        for x in args[1:]:
            indices = x.split("/")
            vertex_index = int(indices[0]) - 1
            texture_index = int(indices[1]) - 1 if len(indices) > 1 and indices[1] else 0
            face.append((vertex_index, texture_index))

        # for non-triangle faces, create n-2 triangles by looping through every group of 3 vertices sequentially
        for i in range(1, len(face) - 1):
            tris.append((face[0], face[i], face[i + 1]))

def q88(x): # convert x to q8.8 fixed point
    return int(round(x * 256)) & 0xffff

def q114(x): # convert x to (signed) q1.14 fixed point
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

open("../ip/vertices.mif", "w").write(out)

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

out += f"    [{len(tris)}..4095] : 0;\nEND;\n"

open("../ip/triangles.mif", "w").write(out)

print(len(verts), "vertices")
print(len(tris), "triangles")