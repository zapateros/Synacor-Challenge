# IMPORTANT: THIS IS JUST ONE OF MY DRAFTS OF OPTIMIZING THE MECHANISM BUT IT IS NOT FULLY FUNCTIONAL
# BUT IT MIGHT BE OF HELP
# a=reg1, b=reg2, h=reg8, x=amount of 3s, y=amount of 2s, z=amount of 1s

a  <- 4
h  <- 20000
b  <- 1
# st <- 178
x  <- 0
y  <- 0
z  <- 0
it <- 0

mdl <- 32768
time <- Sys.time()
while(1==1){
  # it <- it + 1
  if(a == 1 & x == 0 & y == 0 & z == 0){
    break
  }
if(a == 0 & y > 0){
  a  <- 1
   # st <- st - (2 * z + 3)
  b  <- ((b + z + 1) %% mdl) 
  z  <- 0
  y  <- y - 1
}else if(a == 1 ){
  a  <- 0
   # st <- st + 2 * b + 1
  z  <- b
  b  <- h
}else if(a == 0 & y == 0){
  a  <- 2
  b  <- (z + 1 + h) %% mdl         # ?
   # st <- st - (2 * z + 4)
  z  <- 0
  x  <- x - 1
}else if(a == 2){
   # st <- st + 2 * b + 2 + 2 * h
  y  <- b
  a  <- 0
  b  <- h 
  z  <- h
}else if(a == 3){
  x <- h
  a <- 2
  b <- h
  
}else if(a == 4){
  a <- 3
  b <- 0
  
}
  if(a == 0){  
  cat(c(a, b, x, y, z),'\n')
        Sys.sleep(0.001)
  }
}
