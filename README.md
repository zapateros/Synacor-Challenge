# Synacor-Challenge
Synacor Challenge: Solutions in R

Started at 18:25, 7 January 2019

Completed at 14:29, 7 February 2019

After completing Advent of Code 2018, I was looking for the next challenge when I stumbled upon the Synacor Challenge (https://challenge.synacor.com/). **If you don't want to see spoilers, you should now stop reading!** Basically what you have to do is create a virtual machine capable of running the included binary file. It starts out with implementing pretty basic Opcodes and it's not until you make your first mistake when you see the first signs of the true ingenuity of this challenge. The binary file talks back! Okay, no, it just gives hints about what you did wrong, but in a smart way. In total you have find eight codes to complete the challenge. Some of which are earned after just following steps and some are earned after solving some nice puzzles. And then there is this one code which is earned, only after losing a couple of nights sleep and gaining some grey hairs: code seven. I immediately knew exactly what to do, but I did it wrong anyway. When I eventually earned this code, I didn't even feel glad or relieved; I just was annoyed by the fact it took me so long. For more info about that part, see below. 

I'm writing this readme as a manual/blog, or at least how I solved the problems, but I will probably transfer it to a website someday. I completed the challenge completely in R, but there are some calculations which could be sped up with python or even faster with C# (from 15 minutes to 15 seconds). The manual contains 8 chapters, one for each code obviously. In the map 'R' the script is given per chapter/code. *An important note* is that the script works on my input files. With a different input file (bin-file) it is possible you have to change the order of some parts (as explained in the chapters below). 

## Chapter 1: A jump start
Finding the first code is easy. Just download the files from the website (the given link). The file 'arch-spec' contains the instructions to get you going and 'challenge.bin' obviously is the input binary file. The first file also contains your first code (1/8). Now you can't stop anymore.

## Chapter 2: Little-endian pairs
Your first step is to convert the binary file to a vector of readable numbers (for us). Each number is composed of a 16-bit little-endian pair, which basically means that every 16 bits (or two bytes of 8 bits each) represent an integer. The term little-endian pair means that the first byte (read from left to right) is the small one, and so the second the large one. Each byte is read from right to left by standard means, so 01010110 is equivalent to ```0 + 64 + 0 + 16 + 0 + 4 + 2 + 0 = 86```. If this byte is the second of the pair, it has to be multiplied by 256 (or shifted by 8 bits). Now you have to add the first and the second integer to get the resulting integer of the little-endian pair. This results in a vector of 30050 integers from 0 to 32775. The R-code doing this is given below:
```R
file_name <- "challenge.bin"
info      <- file.info(file_name)
lbe       <- readBin(file_name, integer(), size = 2, n = info$size, endian = "little", signed = FALSE)
```
The numbers 0 to 32767 are read as a literal value. The numbers 32768 to 32775 are read as registers 1 to 8. For the observant readers: the instruction manual states registers 0 to 7. **R-objects start at index 1, where many other languages start at index 0.** lbe[1] in R is the first value of vector *lbe*, while in python lbe[1] is the second value of the vector. This makes it a bit more difficult to follow the steps sometimes, as you always have to keep this in mind when applying instructions. The registers are a storage for 8 integers. There is another storage, but this one is unbound: the stack. These two storages, combined with the vector of values (*lbe*) and the Opcodes are all the ingredients for completing this challenge. 

> Basically you are looping through the vector of values (*lbe*), which point to what Opcode to run, which on its turn change values of the registers, add or remove values from the stack, change certain values of *lbe*, output text or make you jump to certain indexes of *lbe*.

This is really all it is. But I can imagine this doesn't really make sense at this point. After you finish the challenge, read this statement again and I'm sure it will. 

The second step is to implement Opcode 0, 19 and 21, as stated in the instructions. I'm writing every Opcode as a function, which can be called when needed. All the relevant Opcodes are given in the R-scripts or in the 'arch-spec'-file. The latter also contains an example of how to read the numbers of the vector *lbe* and what actions should follow. I'm walking you through the very first steps, just for (hopefully) some clarity. 

|i   | 1 | 2 | 3 | 4 | 5 | 6 | 7|
|---|---|---|---|---|---|---|---|
|lbe | 21 | 21 | 19 | 87 | 19 | 101 | 19 |

You start with the first value of *lbe*, which is 21. This means the virtual machine (*vm*) runs Opcode 21, which is actually no operation. So the only thing changing here is that i is set to 2 (```i <<- i + 1```). It is a double arrow because it is an operation inside a function. When using just a single arrow, the incremented i only exists inside the function. Now the second number of *lbe*, lbe[2] also is 21 and the vm repeats Opcode 21 and sets i to 3. The third one is where it becomes interesting: lbe[3] is 19, which means the *vm* should display the ascii character represented by the number on the next i: lbe[4] is 87. This is a "W". Also i is incremented two times, so now i is 5. lbe[5] is also 19 and so on. Now a text message appears, containing the second code! (2/8). Go to [chapter_2.R](https://github.com/zapateros/Synacor-Challenge/blob/master/R/chapter_2.R)

In my code I added a function called '*insert_rel*', which is run every iteration before every Opcode:
```R
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
```
The reason I use this function is because values of *lbe* larger than 32767 are read as either the value of a register or the number of the register itself. Instead of changing the complete vector to the relevant values every time, I just take the values from index i to i + 3, as these include the relevant values, used in all Opcodes. It makes the code a little bit less readable, but increases the performance quite a bit. The function creates a vector *reg_nums*, where, - if present - the register number is stored, and a vector *reg_vals*, where the actual value of the relevant register is stored. For example: if ```rel_lbe = c(12, 39, 32769, 30)```, then ```reg_nums = c(12, 39, 2, 30)``` and ```reg_vals = c(12, 39, 1000, 30)``` if the second register contains the value 1000. Now the Opcode uses either *reg_vals* or *reg_nums* for its instruction, depending on what action to take of course. 


## Chapter 3: The structure
To earn the third code you have to implement all Opcodes, but 20. Now [the script](https://github.com/zapateros/Synacor-Challenge/blob/master/R/chapter_3.R) becomes more and more complete, it is time to look at the structure and methods I'm using. There are four parts:
1. Initialize
2. Opcodes
3. Functions
4. Run the vm 

**1. Initialize**<br /> 
As the title says, here is where the script initializes all objects. At this point the registers (*regs*) and the stack are added. <br /> <br /> 
**2. Opcodes**<br /> 
Here the Opcodes are set. Every Opcode is a seperate function which can be called by the virtual machine. These functions are then added to a list, called *op_functions*:
```R
op_functions <- c(set, push, pop, eq, gt, jmp, jt, jf, add, mult, mod, and, or, not, 
                  rmem, wmem, call, ret, out, opin, noop)
```
A specific Opcode is then called by ```op_functions[[x]]()``` with x the number of the Opcode. This method allows us to write the script clear and concise. <br /> <br /> 
**3. Functions**<br /> 
Here all the different functions are set. The *insert_rel* function is already explained above. However, it is the next function that is the heart of the script: *run_vm*. This is the function that runs the virtual machine. It is just a continious while-loop, until a certain Opcode is met. For Opcode 0 the script stops, probably as a result of a faulty code. When arriving at Opcode 20, it asks for a user-input. This will be treated in the next chapter.<br /> <br /> 
**4. Run the vm**<br /> 
This is the part where you start the virtual machine and, in the next chapters, add (automated) user inputs.

When you run the whole script, it is executing a self-test, where it checks if every Opcode is implemented correctly. If so, it continues to write a message and waits for user input. Also, you have now earned the third code! (3/8).

## Chapter 4: A written adventure
Up until this point it was mostly just implementing instructions but here the real fun begins. You have to implement user-input to play a text-based adventure game. Every character you write should be converted to its decimal ascii-code. One possibility is to use the standard 'readLine'-function but in my opinion, using this during a while-loop is asking for trouble. Instead I wrote a simple custom function, that could be used when the while-loop is ended/stopped. Therefore troubleshooting is easier and it also allowes us to write multiple inputs at once with just a slight modification. This will be treated in chapter 5 because the 4th code is within reach. When Opcode 20 is finally reached, and therefore waits for a user-input, the virtual machine stops. Now you have to call the function 'go' to make your choice:
```R
go <- function(input){
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
```
Basically what you are doing is call Opcode 20 manually, with your choice as the input. The function splits your input (string) and loops through the separate characters. Every character is converted to its decimal ascii code and the virtual machine is started again. To find the next code is very simple. Just pick the tablet up and open it with the following commands:
- *go("take tablet")*
- *go("use tablet")*

And there it is, code 4/8! 

## Chapter 5: Manual or automatic?
To earn the next code, you have to play a text-based adventure game. **Beware: I am not giving hints about what steps you should take; I am giving you the fastest way in completing the game straight-up.** I really advise you to just play the game, as it is quite amusing. You can just use the *go* function to input your concecutive choices. However, especially when starting over and over again, you really want to write multiple inputs at once. Therefore I add a the option to input your choices manually (one at a time) or automatic (multiple at once). The mode starts at "auto" but you can switch by calling ```set_mode("manual")```. If the mode is "auto", the function *go* eats a vector of characters, called *input_chars*. The input could be something like this:
```R
inputs <-c("doorway", "north", "north", "bridge")
input_chars <- unlist(strsplit(paste0(inputs,"0"),""))
input_chars <- gsub("0","\n", input_chars)
```
The above code merges all inputs with a separating "0", splits the string to separate characters and then replaces all zeros with "\n". The extra step is necessary because otherwise "\n" is split to two characters. The mode "auto" differs from "manual" in that the virtual machine doesn't stop everytime Opcode 20 is reached. It only stops when it has looped through all characters of the inputs. 

To find the next code you just have to take the following steps:
```R
"doorway", "north", "north", "bridge", "continue", "down", "east", "take empty lantern", "west", "west",
"passage", "ladder", "west", "south", "north"
```
And the fifth code is chiseled on the wall! (5/8)

## Chapter 6: A worthless treasure
If you continue playing the game, you eventually enter a room with a formula on the walls:
```R 
_ + _ * _^2 + _^3 - _ = 399
```
Also, near this room you can find 5 coins:
- Corroded coin
- Red coin
- Blue coin
- Concave coin
- Shiny coin

And lastly, north of the formula-room, there is a door with 5 slots where you can put the coins into. So in short: A door with five slots, five coins and a formula with five variables. Easy peasy right? For the slow ones among us: you have to insert the coins in the right order to solve the formula, after which the door opens. Every coin has its value, which you can check if you put it into the door-slot and go back to the formula-room. There the values of the concecutive inserted coins are written in the formula. The coins are (respectively to the list) worth: 3, 2, 9, 7 and 5. Now it's up to you to find the correct order, for which it solves the formula. 

I use a simple pragmatic method to find the solution to the formula with the given values. I just brute force every possible combination:
```R
possible_values <- expand.grid(rep(list(c(2, 3, 5, 7, 9)), 5))
uniq_rows       <- sapply(c(1:nrow(pos_vals)),function(x){!any(duplicated(unlist(possible_values[x,])))})
pc              <- possible_values[uniq_rows,]
func_res        <- pc[, 1] + pc[, 2] * pc[, 3] ^ 2 + pc[, 4] ^ 3 - pc[, 5] == 399
pc[func_res,]
```
This function creates a matrix of all possible combinations and then tries it on the formula. The result is 9, 2, 5, 7, 3, which translates to blue coin, red coin, shiny coin, convave coin and corroded coin in this order. In the next room you'll find a teleporter. When activating the teleporter, it (who would have thought) teleports you to new place where you'll find the next code! (6/8)

## Chapter 7: The confirmation mechanism
It is time for the hard part. When you teleport, you will find yourself in the lobby of the Synacor Headquarters and on the bookshelf there is a strange book with vague clues in it. Well, actually the clues are pretty clear, once you know what to do. If you ran the code from chapter 6, you can open the book with the following commands: ```set_mode("manual")``` and ```go("look strange book")```. In short: you have to set the eight register (manually) to a certain value and then activate the teleporter. Then a confirmation mechanism will check if the register is set to the correct value and allowes you to pass. However, this mechanism will take forever and therefore you have to reverse engineer and optimize it. In my case, multiple times. I will walk you through my thought process.

First you have to find where the confirmation mechanism starts and what the conditions are. After setting register eight to a random value, I looked at what values of *i* were used and looked for a pattern. The pattern starts when *i* is 6028 for the first time.

|i   |Opcode| action | 
|---|:---:|---|
|6028 | 7 |if reg1 == 0, go to 6031 <br /> if reg1 != 0, go to 6036>|
|6031|9|reg1 <- (reg2 + 1) %% mdl <br /> go to 6035|
|6035|18|if last value of stack is 6067 or 6047, remove it and go to 6035 <br /> if last value of stack is 6056, go to 6057 <br /> if last value of stack is neither of these, **mechanism ended**|
|6036|7|if reg2 == 0, go to 6039 <br /> if reg2 != 0, go to 6049|
|6039|9|reg1 <- (reg1 + 32767) %% mdl <br /> go to 6043|
|6043|1|reg2 <- reg8 <br /> go to 6046|
|6046|17|add 6047 to stack <br /> go to 6028|
|6049|2|add reg1 to stack <br />  go to 6051|
|6051|9|reg2 <- (reg2 + 32767) %% mdl <br /> go to 6055|
|6055|17|add 6056 to stack <br /> go to 6028|
|6057|1|reg2 <- reg1 <br /> go to 6060|
|6060|3|put last value of stack in reg1 and remove it from stack <br /> go to 6062|
|6062|9|reg1 <- (reg1 + 32767) %% mdl <br /> go to 6066|
|6066|17|add 6067 to stack <br /> go to 6028|


