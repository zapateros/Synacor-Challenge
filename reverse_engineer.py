
stack = [6080, 16, 6124, 1, 2952, 25978, 3568, 3599, 2708, 5445, 3, 5491, 6067]+ [3, 6056]*9 +[6067]+ [2, 6056]*37 + [6067] + [1,6056]*36 + [6067]

a = 0
b = 14
h = 2
mdl = 32768
it = 0


while 1==1:
    it += 1
    if a == 0:
        a = (b + 1) % mdl
        st = stack[-1]
        if not (st == 6047 or st == 6067):
            del stack[-1]
        while(st == 6047 or st == 6067):
            st = stack[-1]
            del stack[-1]
        if st != 6056:
            break
        else:
            b = a
            st = stack[-1]
            a = st
            del stack[-1]
            a = (a +32767) % mdl
            stack.append(6067)
    else:
        if (b == 0):
            a = (a + 32767) % mdl
            b = h
            stack.append(6047)
        else:
            stack.append(a)
            b = (b + 32767) % mdl
            stack.append(6056)
