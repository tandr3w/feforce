# import pyperclip
# import math

# vals = [65535]
# strings = ["0"]
# streak = 0
# for i in range(1, 4096):
#     val = int((2**18/i)) # 13 for Q3.13 + 5 because of how the address is passed
#     if val > 65535:
#         val = 65535
#     if (val != vals[-1]):
#         vals.append(val)
#         if streak > 0:
#             strings[-1] = (f"[{i-streak-1}..{i-1}]")
#             streak = 0
#         strings.append(str(i))
#     else:
#         streak += 1

# if val == vals[-1]:
#     strings[-1] = (f"[{4095-streak}..{4095}]")

# print(vals)
# print(len(strings))
# print(len(vals))
# out = " "

# # for i in range(len(strings)):
# #     # print(f"{strings[i]} : {vals[i]:04x};")
# #     out += f"{strings[i]} : {vals[i]:04x};\n"

# # for desim
# for i in range(1, 4096):
#     val = int((2**18/i))
#     if val > 65535:
#         val = 65535
#     out += f"            16'd{i} :   q <= 16'h{val:04x};\n"
# pyperclip.copy(out)
#     # print(f"            16'd{i} :   q <= 16'h{int((2**13/i)):04x};")


import math

with open("sine_table", "w") as f:
    for i in range(4096):
        # convert to fixed point signed
        #  i + cur + sin(cur)

        angle_deg = i * 360 / 4096
        val = math.sin(math.radians(angle_deg))
        raw = round(val * 32768)                 # 2^15
        raw = max(-32768, min(32767, raw))       # saturate
        pattern = raw & 0xFFFF                    # two's-complement bit pattern
        # f.write(str(i) + " " + str(-360 + ((720 / 4096) * i)) + " " + str(pattern) + "\n") # -360 to 360

        # angle = -360 + ((720 / 4096) * i)
        # format_code = round(angle * 64) # 10.6 
        # format_code = max(-32768, min(32767, format_code))
        # angle_pattern = format_code & 0xFFFF

        # f.write(f"{angle_pattern:04X} : {pattern:04X};")
        # address = i (the brad), data = sine in Q1.15 hex
        f.write(f"    {i} : {pattern:04X};")
        f.write("\n")  
f.close()