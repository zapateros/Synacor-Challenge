
mdl = 32768
hs = []
hs_m = []
import time
start = time.time()
for h in range(1,32768):
    a = 0
    b = 15
    x = 9
    y = 37
    z = 35
    st = 178
    while 1==1:
        if( a == 1 and x == 0 and y == 0 and z == 0):
            break
        if( a == 0 and y > 0):
            a = 1
            b = (b + z + 1) % mdl
            z = 0
            y = y - 1
        elif( a == 1):
            a = 0
            z = b
            b = h
        elif(a == 0 and y == 0):
            a = 2
            b = (z + 1 + h) % mdl
            z = 0
            x = x - 1
        elif(a == 2):
            y = b
            a = 0
            b = h
            z = h
    m = (b + h) % mdl
    if(m == 5):
        print(h, m)
    hs_m.append(m)
    hs.append(b) 
end = time.time()
print(end - start)
