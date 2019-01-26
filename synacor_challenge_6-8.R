a     <- 0
b     <- 9
h     <- 1
stack <- c(1, 6056, 6067)
mdl   <- 32768

it <- 0
while(TRUE){
  
  if(it == 10000){
    it <- 0
    a <- 0
    b <- 9
    stack <- c(1, 6056, 6067)
    h <- h + 1
    cat(h, "\n")
  }
  
  
  it <- it + 1
  if(a != 0){
    if(b != 0){
      stack <- c(stack, a)
      b     <- (b + 32767) %% mdl
      stack <- c(stack, 6056)
      #start over
    } else {
      a     <- (a + 32767) %% mdl
      b     <- h
      stack <- c(stack, 6047)
      #start over
    }
  } else{
    a     <- (b + 1) %% mdl
    st    <- stack[length(stack)]
    stack <- stack[-length(stack)]
    if(st == 6047){
      st_1 <- stack[length(stack)]
      if(!(st_1 %in% c(6028, 6047, 6056, 6055))){ 
        cat(st_1)
        break
      }
      stack <- stack[-length(stack)]
      #start over
    } else{
      b <- a
      a <- stack[length(stack)]
      stack <- stack[-length(stack)]
      a <- (a + 32767) %% mdl
      stack <- c(stack, 6067)
      #start over
    }
  }
}
