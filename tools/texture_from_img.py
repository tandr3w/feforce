from PIL import Image

img = Image.open("wood.jpg").convert("RGB")
img = img.resize((64, 64))

out = """WIDTH=16;
DEPTH=4096;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;
CONTENT BEGIN
"""

with open("../sim/texture.hex", "w") as f:
    for y in range(64):
        for x in range(64):
            r, g, b = img.getpixel((x, y))

            # convert from rgb888 to rgb565
            r = r >> 3
            g = g >> 2
            b = b >> 3

            color = (r << 11) | (g << 5) | b
            addr = y * 64 + x

            out += f"    {addr} : {color:04X};\n"
            f.write(f"{color:04X}\n")

out += "END;\n"

open("../ip/texture.mif", "w").write(out)

