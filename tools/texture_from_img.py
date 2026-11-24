from PIL import Image

img0 = Image.open("assets/wood.jpg").convert("RGB")
img0 = img0.resize((64, 64))

img1 = Image.open("assets/bricks.jpg").convert("RGB")
img1 = img1.resize((64, 64))

img2 = Image.open("assets/cloth.jpg").convert("RGB")
img2 = img2.resize((64, 64))

img3 = Image.open("assets/crystals.jpg").convert("RGB")
img3 = img3.resize((64, 64))

images = [img0, img1, img2, img3]

out = """WIDTH=16;
DEPTH=4096;
ADDRESS_RADIX=UNS;
DATA_RADIX=HEX;
CONTENT BEGIN
"""

img_index = 0

with open("../sim/texture.hex", "w") as f:
    for img in images:
        for y in range(64):
            for x in range(64):
                r, g, b = img.getpixel((x, y))

                # convert from rgb888 to rgb565
                r = r >> 3
                g = g >> 2
                b = b >> 3

                color = (r << 11) | (g << 5) | b
                addr = y * 64 + x + 4096*img_index

                out += f"    {addr} : {color:04X};\n"
                f.write(f"{color:04X}\n")
        img_index += 1

out += "END;\n"

open("../ip/texture.mif", "w").write(out)

