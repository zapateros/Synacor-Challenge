# Notes
# Be careful, arrays start at one, so when applying a jump, add 1


# Initialize
file_name <- "challenge.bin"
info      <- file.info(file_name)
lbe       <- readBin(file_name, integer(), size = 2, n = info$size, endian = "little", signed = FALSE)
regs      <- c(0, 0, 0, 0, 0, 0, 0, 0)
mdl       <- 32768


# opcodes
# 6. jump to <a>
jmp <- function(){
  i <<- lbe[i+1] + 1
  cat("i_after = ", i, "\n" )
}

# 7. if <a> is nonzero, jump to <b>
jt <- function(){
  if(lbe[i+1] != 0){
    i <<- lbe[i+2] + 1
  }else{
    i <<- i + 3
  }
  cat("i_after = ", i, "\n" )
}

# 8. if <a> is zero, jump to <b>
jf <- function(){
  if(lbe[i+1] == 0){
    i <<- lbe[i+2] + 1
  }else{
    i <<- i + 3
  }
  cat("i_after = ", i, "\n" )
}

# 19. write the character represented by ascii code <a> to the terminal
out <- function(){ 
  cat(rawToChar(as.raw(lbe[i + 1]))) 
  i <<- i + 2
}

# 21. no operation
noop <- function(){
  i <<- i + 1
}


# run while true
i<-1
while( TRUE){
  ind <- lbe[i]
  if(ind == 0){ break}  
  else if(ind == 6){ jmp()}
  else if(ind == 7){ jt()}
  else if(ind == 8){ jf()}
  else if(ind == 19){ out() }
  else if(ind == 21){ noop() }
  else{ cat(i) 
    break }
}





