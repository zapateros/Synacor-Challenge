# 1. INITIALIZE
file_name <- "challenge.bin"
info      <- file.info(file_name)
lbe       <- readBin(file_name, integer(), size = 2, n = info$size, endian = "little", signed = FALSE)
regs      <- c(0, 0, 0, 0, 0, 0, 0, 0)
mdl       <- 32768
stack     <- NULL
i         <- 1
end_input <- TRUE
mode      <- "auto"
step      <- 1
# 2. OPCODES
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

# 20. read a character from the terminal and write its ascii code to <a>
go <- function(input){
    if(mode == "auto"){
    ch   <-  input_chars[step]
    step <<- step + 1
    nm   <-  charToRaw(ch)
    regs[reg_nums[2]] <<- as.numeric(nm)
    i    <<- i + 2
  }else if(mode == "manual"){
  for(j in unlist(strsplit(input,""))){
    nm <- charToRaw(j)
    regs[reg_nums[2]] <<- as.numeric(nm)
    i <<- i + 2
    run_vm()
  }
  regs[reg_nums[2]] <<- as.numeric(charToRaw("\n"))
  i <<- i + 2
  run_vm()
  }
}

# 21. no operation
noop <- function(){
  i <<- i + 1
}

# Add all functions to a list to call the relevant one from run_vm function
op_functions <- c(set, push, pop, eq, gt, jmp, jt, jf, add, mult, mod, and, or, not, 
                  rmem, wmem, call, ret, out, go, noop)


# 3. FUNCTIONS
# take relevant numbers from i and change to register values if larger than 32767
insert_rel <- function(){
  rel_lbe      <<- lbe[i:(i+3)]
  reg_nums <<- rel_lbe
  reg_vals <<- rel_lbe
  if(any(rel_lbe > 32767)){
    larger <- rel_lbe > 32767
    reg_nums[larger] <<- rel_lbe[larger] - 32767
    reg_vals[larger] <<- regs[reg_nums[larger]]
  }
}

# set input mode: auto or manual
set_mode <- function(x){
  mode <<- x
}

# function to run the virtual machine
run_vm <- function(){
  while(TRUE){
    lbe_at_i <- lbe[i]
    insert_rel()
    if(lbe_at_i == 0){
      break
    }else if(lbe_at_i == 20){
      if(mode == "auto"){
        if((step) > length(input_chars)){
          step <<- 1
          break
        }
        go()
      } else if(mode == "manual"){
        break
      }
    } else{
      op_functions[[lbe_at_i]]()
    }
  }
}

# 4. RUN THE VM
inputs <-c("doorway", "north", "north", "bridge", "continue", "down", "east", "take empty lantern", "west",
           "west", "passage", "ladder", "west", "south", "north")
input_chars <- unlist(strsplit(paste0(inputs,"0"),""))
input_chars <- gsub("0","\n", input_chars)
run_vm()
