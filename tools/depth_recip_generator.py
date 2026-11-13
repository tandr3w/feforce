vals = [65535]
strings = ["0"]
streak = 0
for i in range(1, 4096):
    val = int((2**13/i))
    if (val != vals[-1]):
        vals.append(val)
        if streak > 0:
            strings[-1] = (f"[{i-streak-1}..{i-1}]")
            streak = 0
        strings.append(str(i))
    else:
        streak += 1

if val == vals[-1]:
    strings[-1] = (f"[{4095-streak}..{4095}]")

print(vals)
print(len(strings))
print(len(vals))

for i in range(len(strings)):
    print(f"{strings[i]} : {vals[i]:04x};")

# for desim
for i in range(4000, 4096):
    val = int((2**13/i))
    print(f"            16'd{i} :   q <= 16'h{int((2**13/i)):04x};")
