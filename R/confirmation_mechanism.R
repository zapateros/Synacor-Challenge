reg1  <- 4
reg2  <- 1
reg8  <- 1
stack <- c( 6080, 16, 6124, 1, 2952, 25978, 3568, 3599, 2708, 5445, 3, 5491)
mdl   <- 32768

while(TRUE){
  if(reg1 != 0){  
    if(reg2 == 0){
      reg1  <- (reg1 + 32767) %% mdl
      reg2  <- reg8
      stack <- c(stack, 6047)
    }else{
      stack <- c(stack, reg1)
      reg2  <- (reg2 + 32767) %% mdl
      stack <- c(stack, 6056)
    }
  }else{ 
    reg1 <- (reg2 + 1) %% mdl
    n    <- length(stack)
    st   <- stack[n]
    if(!((st == 6047) | (st == 6067))){
      stack <- stack[-n]
    }
    while((st == 6047) | (st == 6067)){
      n     <- length(stack)
      st    <- stack[n]
      stack <- stack[-n]
    }
    if(st != 6056){
      break
    }else{
      reg2  <- reg1
      n     <- length(stack)
      st    <- stack[n]
      reg1  <- st
      stack <- stack[-n]
      reg1  <- (reg1 + 32767) %% mdl
      stack <- c(stack, 6067)
    }
  }
}
