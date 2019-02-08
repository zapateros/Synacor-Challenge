setwd("C:/Users/paul/Documents/R-projects/Synacor-Challenge")

# Initialize
file_name <- "challenge.bin"
info      <- file.info(file_name)
lbe       <- readBin(file_name, integer(), size = 2, n = info$size, endian = "little", signed = FALSE)
i         <- 1

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

# 19. write the character represented by ascii code <a> to the terminal
out <- function(){ 
  cat(rawToChar(as.raw(reg_vals[2]))) 
  i <<- i + 2
}

# 21. no operation
noop <- function(){
  i <<- i + 1
}

# run the virtual machine
run_vm <- function(){
  while(TRUE){
    lbe_at_i <- lbe[i]
    insert_rel()
    if(lbe_at_i == 0){ 
      break
    }else if(lbe_at_i == 19){ 
      out()
    } else if(lbe_at_i == 21){ 
      noop() 
    } else{ 
      break 
    }
  }
}

run_vm()
