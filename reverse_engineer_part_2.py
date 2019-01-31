

a = 0
b = 15
h = 3

mdl = 32768
it = 0
hs = []
import time
start = time.time()
for h in range(1,32767):
    x = 9
    y = 37
    z = 35
    st = 178
    while 1==1:
        
        if( a == 1 and x == 0 and y == 0 and z == 0):
            break
        if( a == 0 and y > 0):
            a = 1
           # st = st - (2 * z + 3)
            b = (b + z + 1) % mdl
            z = 0
            y = y - 1
        elif( a == 1):
            a = 0
           # st = st + 2 * b + 1
            z = b
            b = h
        elif(a == 0 and y == 0):
            a = 2
            b = (z + 1 + h) % mdl
           # st = st - (2 * z + 4)
            z = 0
            x = x - 1
        elif(a == 2):
          #  st = st + 2 * b + 2 * h
            y = b
            a = 0
            b = h
            z = h
    hs.append(b)
    #print(h, b)
end = time.time()
print(end - start)
