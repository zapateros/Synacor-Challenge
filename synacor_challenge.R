# SPOILERS!!!!
# SPOILERS!!!!
# SPOILERS!!!!
# Notes
# Be careful, arrays start at one, so when applying a jump, add 1

setwd("C:/Users/paul/Documents/R-projects/Synacor-Challenge")


# Initialize
file_name <- "challenge.bin"
info      <- file.info(file_name)
lbe       <- readBin(file_name, integer(), size = 2, n = info$size, endian = "little", signed = FALSE)
regs      <- c(0, 0, 0, 0, 0, 0, 0, 0)
mdl       <- 32768
rel       <- NULL
stack     <- NULL
reg_st    <- NULL
step      <- 1
it        <- 1
i         <- 1

#functions ----
# take relevant numbers from i and change to register values if larger than 32767
relevants <- function(){
  rel <<- lbe[i:(i+3)]
  reg_nums <<- rel
  reg_vals <<- rel
  if(any(rel > 32767)){
    tt     <-  rel > 32767
    reg_nums[tt] <<- rel[tt] - 32767
    reg_vals[tt] <<-  regs[reg_nums[tt]]
  }
}

# set mode: auto or manual
mode <- "auto"
set_mode <- function(x){
  mode <<- x
}


# opcodes ----
# 1, set register <a> to the value of <b>
set <- function(){
  regs[reg_nums[2]] <<- reg_vals[3]
  i <<- i + 3
}

# 2. push <a> onto the stack
push <- function(){
  stack <<- c(stack, reg_vals[2])
  i <<- i + 2
}

# 3. remove the top element from the stack and write it into <a>; empty stack = error
pop <- function(){
  n <- length(stack)
  if(n > 0){
    regs[reg_nums[2]] <<- stack[n]
    stack <<- stack[-n]
    i     <<- i + 2
  }else{
    cat("Error: empty stack \n")
  }
}

# 4. set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
eq <- function(){
  if( reg_vals[3] == reg_vals[4]){
    regs[reg_nums[2]] <<- 1
  }else{
    regs[reg_nums[2]] <<- 0
  }
  i <<- i + 4
}

# 5. set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
gt <- function(){
  if(reg_vals[3] > reg_vals[4]){
    regs[reg_nums[2]] <<- 1
  }else{
    regs[reg_nums[2]] <<- 0
  }
  i <<- i + 4
}

# 6. jump to <a>
jmp <- function(){
  i <<- reg_vals[2] + 1
}

# 7. if <a> is nonzero, jump to <b>
jt <- function(){
  if(reg_vals[2] != 0){
    i <<- reg_vals[3] + 1
  }else{
    i <<- i + 3
  }
}

# 8. if <a> is zero, jump to <b>
jf <- function(){
  if(reg_vals[2] == 0){
    i <<- reg_vals[3] + 1
  }else{
    i <<- i + 3
  }
}

# 9. assign into <a> the sum of <b> and <c> (modulo 32768)
add <- function(){
  nm <- (reg_vals[3] + reg_vals[4]) %% mdl
  regs[reg_nums[2]] <<- nm
  i <<- i + 4
}

# 10. store into <a> the product of <b> and <c> (modulo 32768)
mult <- function(){
  nm <- (reg_vals[3] * reg_vals[4]) %% mdl
  regs[reg_nums[2]] <<- nm
  i <<- i + 4
}

# 11. store into <a> the remainder of <b> divided by <c>
mod <- function(){
  regs[reg_nums[2]] <<- reg_vals[3] %% reg_vals[4]
  i <<- i + 4
}

# 12. stores into <a> the bitwise and of <b> and <c>
and <- function(){
  regs[reg_nums[2]] <<- bitwAnd(reg_vals[3], reg_vals[4])
  i <<- i + 4
}

# 13. stores into <a> the bitwise or of <b> and <c>
or <- function(){
  regs[reg_nums[2]] <<- bitwOr(reg_vals[3], reg_vals[4])
  i <<- i + 4
}

# 14. stores 15-bit bitwise inverse of <b> in <a>
not <- function(){
  bts   <- as.integer(intToBits(reg_vals[3]))[1 : 15]
  bts_t <- bts == 0
  clc   <- 2 ^ (0 : 14)
  regs[reg_nums[2]] <<- sum(clc[bts_t])
  i <<- i + 3
}

# 15. read memory at address <b> and write it to <a>
rmem <- function(){
  regs[reg_nums[2]] <<- lbe[reg_vals[3] + 1]
  i <<- i + 3
}

# 16. write the value from <b> into memory at address <a>
wmem <- function(){
  lbe[reg_vals[2]+1] <<- reg_vals[3]
  i <<- i + 3
}

# 17. write the address of the next instruction to the stack and jump to <a>
call <- function(){
  stack <<- c(stack, (i + 2 - 1)) #-1 because R start indexes
  i <<- reg_vals[2] + 1
}

# 18. remove the top element from the stack and jump to it; empty stack = halt
ret <- function(){
  n <- length(stack)
  if(n > 0){
    i <<- stack[n] + 1
    stack <<- stack[-n]
  }else{
    break
  }
}

# 19. write the character represented by ascii code <a> to the terminal
out <- function(){ 
  cat(rawToChar(as.raw(reg_vals[2]))) 
  i <<- i + 2
}

# 20. (auto) read a character from the terminal and write its ascii code to <a>
goa <- function(){
  ch   <-  inps[step]
  step <<- step + 1
  nm   <-  charToRaw(ch)
  regs[reg_nums[2]] <<- as.numeric(nm)
  i    <<- i + 2
}

# 20. (manual) read a character from the terminal and write its ascii code to <a>
gom <- function(ch,enter = TRUE){
  
  for(j in unlist(strsplit(ch,""))){
    nm <- charToRaw(j)
    regs[reg_nums[2]] <<- as.numeric(nm)
    i <<- i + 2
    virt()
  }
  if(enter == TRUE){
    regs[reg_nums[2]] <<- as.numeric(charToRaw("\n"))
    i <<- i + 2
    virt()
  }else{
    cat("You have to input an enter to complete")
  }
  
}

# 21. no operation
noop <- function(){
  i <<- i + 1
}



help<-"1"
jj <- NULL
jind <- NULL
# run while true ----
virt <- function(){
  while(T){
    it  <- it + 1
    ind <- lbe[i]
    relevants()
    # cat(i,"\n")
    if(help == "2"){
        jj <<- c(jj, i)
        jind <<- c(jind,length(stack))
    }
    if(ind == 0){ 
      break
    }else if(ind == 1){
      set()
    } else if(ind == 2){
      push()
    } else if(ind == 3){
      pop()
    } else if(ind == 4){
      eq()
    } else if(ind == 5){
      gt()
    } else if(ind == 6){ 
      jmp()
    } else if(ind == 7){ 
      jt()
    } else if(ind == 8){ 
      jf()
    } else if(ind == 9){
      add()
    } else if(ind == 10){
      mult()
    } else if(ind == 11){
      mod()
    } else if(ind == 12){
      and()
    } else if(ind == 13){
      or()
    } else if(ind == 14){
      not()
    } else if(ind == 15){
      rmem()
    } else if(ind == 16){
      wmem()
    } else if(ind == 17){
      call()
    } else if(ind == 18){
      ret()
    } else if(ind == 19){ 
      out()
    } else if(ind == 20){
      if(mode == "auto"){
        if((step) > length(inps)){
          break
        }
        goa()
      } else if(mode == "manual"){
        break
      }
    } else if(ind == 21){ 
      noop() 
    } else{ 
      cat(i) 
      break 
    }
  }
}

inputs <-c("doorway", "north", "north", "bridge", "continue", "down", "east", "take empty lantern", "west",
           "west", "passage", "ladder", "west", "south", "north", "take can", "use can", "west", "ladder",
           "darkness", "use lantern", "continue", "west", "west", "west", "west", "north", "take red coin",
           "north", "east", "take concave coin", "down", "take corroded coin", "up", "west", "west",
           "take blue coin", "up", "take shiny coin", "down", "east", "north", "use blue coin", 
           "use red coin", "use shiny coin", "use concave coin", "use corroded coin", "north", 
           "take teleporter", "use teleporter", "take business card", "take strange book", "outside") 
inps <- unlist(strsplit(paste0(inputs,"8"),""))
inps <- gsub("8","\n",inps)

virt()
set_mode("manual")
regs[8] <- 1
 
help<-"2"
gom("use teleporter")
#6028 6036 6049 6051 6055
# ----
#calculate the formula with 5 unknown variables
#r=2, b=9, cc=7, sh=5, cr=3
# vals <- c(2, 3, 5, 7, 9)
# vl<- NULL
# fn <- vl[1] + vl[2] * vl[3]^2 +vl[4]^3 -vl[5] - 399
# for(i in 1:5){
#   vl[1] <- vals[i]
#   for(j in 1:5){
#     vl[2] <- vals[j]
#     for(k in 1:5){
#       vl[3] <- vals[k]
#       for(l in 1:5){
#         vl[4] <- vals[l]
#         for(m in 1:5){
#           vl[5] <- vals[m]
#           fl <- vl[1] + vl[2] * vl[3]^2 +vl[4]^3 -vl[5] - 399
#           if(fl == 0){ cat(c(i,j,k,l,m))}
#         }
#       }
#     }
#   }
# }

#save state 6/8
# regs_save <- c(25975, 25974, 26006, 0, 101, 0, 0, 0)
# stack_save <- c(6080, 16, 6124, 1, 2826, 32, 0, 6, 101, 0)
# i_save <- 1799
# lbe_save <- lbe

#book
# Recent advances in interdimensional physics have produced fascinating
# predictions about the fundamentals of our universe!  For example,
# interdimensional physics seems to predict that the universe is, at its root, a
# purely mathematical construct, and that all events are caused by the
# interactions between eight pockets of energy called "registers".
# Furthermore, it seems that while the lower registers primarily control mundane
# things like sound and light, the highest register (the so-called "eighth
# register") is used to control interdimensional events such as teleportation.
# 
# A hypothetical such teleportation device would need to have have exactly two
# destinations.  One destination would be used when the eighth register is at its
# minimum energy level - this would be the default operation assuming the user
# has no way to control the eighth register.  In this situation, the teleporter
# should send the user to a preconfigured safe location as a default.
# 
# The second destination, however, is predicted to require a very specific
# energy level in the eighth register.  The teleporter must take great care to
# confirm that this energy level is exactly correct before teleporting its user!
# If it is even slightly off, the user would (probably) arrive at the correct
# location, but would briefly experience anomalies in the fabric of reality
# itself - this is, of course, not recommended.  Any teleporter would need to test
# the energy level in the eighth register and abort teleportation if it is not
# exactly correct.
# 
# This required precision implies that the confirmation mechanism would be very
# computationally expensive.  While this would likely not be an issue for large-
# scale teleporters, a hypothetical hand-held teleporter would take billions of
# years to compute the result and confirm that the eighth register is correct.
# 
# If you find yourself trapped in an alternate dimension with nothing but a
# hand-held teleporter, you will need to extract the confirmation algorithm,
# reimplement it on more powerful hardware, and optimize it.  This should, at the
# very least, allow you to determine the value of the eighth register which would
# have been accepted by the teleporter's confirmation mechanism.
# 
# Then, set the eighth register to this value, activate the teleporter, and
# bypass the confirmation mechanism.  If the eighth register is set correctly, no
# anomalies should be experienced, but beware - if it is set incorrectly, the
# now-bypassed confirmation mechanism will not protect you!
# 
# Of course, since teleportation is impossible, this is all totally ridiculous.


