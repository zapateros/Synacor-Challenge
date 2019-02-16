mdl <- 32768
reg8 <- 0
while(TRUE){
reg8 <- reg8 + 1
b    <- reg8
d    <- reg8
e    <- reg8
f    <- reg8

while(d>0){
  e <- (b + ((b+1)*e + f) + 1) %% mdl
  d <- d - 1
}
d <- (b + ((b+1)*e + f) + 1) %% mdl
e <- reg8

while(d>0){
  e <- (b + ((b+1)*e + f) + 1) %% mdl
  d <- d - 1
}

f <- ((b+1)*e + f) %% mdl
b <- (f + b) %% mdl

if(b == 5){
  cat(reg8)
  break
}
}
