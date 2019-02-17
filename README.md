# Synacor-Challenge
*Synacor Challenge: Solutions in R*
- Started at 18:25, 7 January 2019
- Completed at 14:29, 7 February 2019
<p align="justify">
After completing Advent of Code 2018, I was looking for the next challenge when I stumbled upon the Synacor Challenge (https://challenge.synacor.com/). **If you don't want to see spoilers, you should now stop reading!** Basically what you have to do is create a virtual machine capable of running the included binary file. It starts out with implementing pretty basic Opcodes and it's not until you make your first mistake when you see the first signs of the true ingenuity of this challenge. The binary file talks back! Okay, no, it just gives hints about what you did wrong, but in a smart way. In total you have find eight codes to complete the challenge. Some of which are earned after just following steps and some are earned after solving some nice puzzles. And then there is this one code which is earned, only after losing a couple of nights sleep and gaining some grey hairs: code seven. I immediately knew exactly what to do, but I did it wrong anyway. When I eventually earned this code, I didn't even feel glad or relieved; I just was annoyed by the fact it took me so long. For more info about that part, see below. 
</p>
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
This function creates a matrix of all possible combinations and then tries it on the formula. The result is 9, 2, 5, 7, 3, which translates to blue coin, red coin, shiny coin, convave coin and corroded coin in this order. In the next room you'll find a teleporter. When activating the teleporter, it (who would have thought) teleports you to new place where you'll find the next code! (6/8). Note: the activation of the teleporter is already built in in the 6th script. So run this whole script and you'll end up teleported.

## Chapter 7: The confirmation mechanism
It is time for the hard part. When you teleport, you will find yourself in the lobby of the Synacor Headquarters and on the bookshelf there is a strange book with vague clues in it. Well, actually the clues are pretty clear, once you know what to do. If you ran the code from chapter 6, you can open the book with the following commands: ```set_mode("manual")``` and ```go("look strange book")```. In short: you have to set the eight register (manually) to a certain value and then activate the teleporter. Then a confirmation mechanism will check if the register is set to the correct value and allowes you to pass. However, this mechanism will take forever and therefore you have to reverse engineer and optimize it. In my case, multiple times. I will walk you through my thought process.

First you have to find where the confirmation mechanism starts and what the conditions are. After setting register eight to a random value (in this case 5), I looked at what values of *i* were used and looked for a pattern. The pattern starts when *i* is 6028 for the first time. At this point the registers and stack are respectively ``` c(4, 1, 3, 10, 101, 0, 0, 5)``` and ``` c(6080, 16, 6124, 1, 2952, 25978, 3568, 3599, 2708, 5445, 3, 5491)```. The pattern of the confirmation mechanism is given as semi-pseudocode in the next table:

|i   |Opcode| Action | 
|---|:---:|---|
|6028 | 7 |If reg1 == 0, go to 6031 <br /> If reg1 != 0, go to 6036|
|6031|9|reg1 <- (reg2 + 1) %% mdl <br /> Go to 6035|
|6035|18|If last value of stack is 6067 or 6047, remove it and go to 6035 <br /> If last value of stack is 6056, go to 6057 <br /> If last value of stack is neither of these, **mechanism ended**|
|6036|7|If reg2 == 0, go to 6039 <br /> If reg2 != 0, go to 6049|
|6039|9|reg1 <- (reg1 + 32767) %% mdl <br /> Go to 6043|
|6043|1|reg2 <- reg8 <br /> Go to 6046|
|6046|17|Add 6047 to stack <br /> Go to 6028|
|6049|2|Add reg1 to stack <br />  Go to 6051|
|6051|9|reg2 <- (reg2 + 32767) %% mdl <br /> Go to 6055|
|6055|17|Add 6056 to stack <br /> Go to 6028|
|6057|1|reg2 <- reg1 <br /> Go to 6060|
|6060|3|Put last value of stack in reg1 and remove it from stack <br /> Go to 6062|
|6062|9|reg1 <- (reg1 + 32767) %% mdl <br /> Go to 6066|
|6066|17|Add 6067 to stack <br /> Go to 6028|

You can read this table as follows: the virtual machine starts at *i* is 6028 and *reg1* is not zero. Therefore *i* jumps to 6036. *reg2* also is not zero and so *i* jumps to 6049. Now *reg1* (4) is added to the stack  and *i* jumps to 6051. The mechanism loops through these values of *i* until *i* is 6035 and the last value of the stack is something else than 6067, 6047 or 6056. We'll see later that this value turns out to be 5491. At this point it is important to note that registers 3 to 7 (and *lbe*) are not affected by the mechanism. When you write a [script](https://github.com/zapateros/Synacor-Challenge/blob/master/R/confirmation_mechanism.R) that runs this mechanism isolated, you'll see that there is an interaction between *reg1*, *reg2*, *reg8* and the *stack*. It was not until after I completed the challenge when I read that it is an adaptation of the Ackermann function, but in all honesty, I don't think knowing this would have helped me during the challenge. 

I ran the script and saved the length of the stack every iteration and I saw a wave pattern. When I looked closer to the stack I saw it was filled with threes, twos and zeros. Therefore my instinct was to count occurrences of these particular numbers and saw a pattern. At this point I started looking at the problem from a different perspective: I created six variables *a,b,c,d,e* and *f*, which represent *reg1*, *reg2* and the amount of fours, threes, twos and ones in the stack respectively. Important is to **not** count the one and three that were in the stack at the beginning. When running the script while saving these variables every iteration for a while (it will practically never end), you'll see what happens. Especially when you change register 8, you should be able to see what happens. 

I saw that the script fills *b, d, e* and *f* up to the value you have given in register 8 before running the teleporter. So the new starting point, for this second reverse engineering attempt, is ```c(0, reg8, 1, reg8, reg8, reg8)```. Note *c* is one; which means the stack starts with one four (and will never increase luckily). Now let's try running the script with a starting *reg8* of 20,000. I used this high number because there are calculations with modulus 32768 and therefore you should pick a high starting number to really see what is happening in the high regions. You could just run the script and wait a while, but because it fills the stack with 20,000 threes, twos and zeros, you could also just help it a bit and set the following starting points:
```R
reg1 <- 0
reg8 <- 20000
reg2 <- reg8
vw <- NULL
stack <- c( 6080, 16, 6124, 1, 2952, 25978, 3568, 3599, 2708, 5445, 3, 5491,
            rep(c(4,6056), 1),6067,
            rep(c(3,6056), reg8),6067,
            rep(c(2,6056), reg8),6067, 
            rep(c(1,6056), reg8),6067)
```
and put 
```R
a <- reg1
b <- reg2
c <- sum(stack==4)
d <- sum(stack==3)-1
e <- sum(stack==2)
f <- sum(stack==1)-1
vw <- rbind(vw,c(a, b, c, d, e, f)) 
``` 
in the top of the while loop to save the relevant values to a matrix (see the new script [here](https://github.com/zapateros/Synacor-Challenge/blob/master/R/Confirmation_mechanism_jump_start.R)). Let's run the script and look at *vw*. Just like I said, it starts with ``` c(0, 20000, 1, 20000, 20000, 20000)```. Now *f* decreases by one every iteration, while *b* increases by one. This goes on for a while and it gets interesting where *b* approaches the value of the modulo (*mdl* is 32768). In the following table some edgecases are shown (interpolate cells with a dot):

|a|b|c|d|e|f|
|:---:|:---:|:---:|:---:|:---:|:---:|
|0|20000|1|20000|20000|20000|
|0|20001|1|20000|20000|19999|
|0|20002|1|20000|20000|19998|
|.|.|.|.|.|.|
|0|32766|1|20000|20000|7234|
|0|32767|1|20000|20000|7233|
|0|0|1|20000|20000|7232|
|0|1|1|20000|20000|7231|
|.|.|.|.|.|.|
|0|7231|1|20000|20000|1|
|0|7232|1|20000|20000|0|
|0|7233|1|20000|19999|0|
|1|7232|1|20000|19999|1|
|1|7231|1|20000|19999|2|
|.|.|.|.|.|.|
|1|1|1|20000|19999|7232|
|1|0|1|20000|19999|7233|
|0|20000|1|20000|19999|7233|

As can be seen here is that *f* decreases by one, until it hits zero. Meanwhile, until this point, *b* increases by one and starts at zero when the value of the modulo is reached. When *f* is zero, *e* decreases by one and *b* increases by one. From this point *f* starts increasing again, while *b* is decreasing. When *b* reaches zero, it is set to the initial value of *reg8* again. From here it starts the same procedure again. So in the end (of this one procedure) *e* is decreased by one and *f* has a new starting point. If *e* is zero, *d* decreases by one and when *d* is zero, *c* decreases by one. The whole mechanism stops when values *c, d, e* and *f* are all zero. And then what? I will explain in a bit. First let's see how we can speed up this procedure a bit, step by step. 

The procedure, as shown in the above table, contains 40001 iterations (or rows). However, it is easy to see that new starting point of *f* is equivalent to:
```R
f(n+1) = (f(n) + b + 1) %% mdl
```
So everytime *e* decreases by one, the new *f* is given by this recursive formule. Now we already replaced 40001 iterations. That's a great start. However, the confirmation mechanism will now not take a billion years, but maybe a million or so. So the next step is to check what happens when *d* decreases by one (when *e* is zero). Or in other words: when you run the above recursive formula 20,000 times. There are three ways of looking what happens at this point:
- Run the isolated mechanism script for a very, very long while, until you see a decrease in *d*. It helps to choose a small *reg8* and also make sure you don't fill the matrix *vw* until this point as this will slow down the script drastically.
- Run the recursive formula 20,000 times and set a new starting point, according to how we set it earlier. You have to start the stack with 20,000 threes, 0 twos and 8256 ones. This last value is of course *f* after 20,000 repetitions of the recursive formula. I suggest you only use this method if you understand what is happening, to prevent trying to analyse a wrong output. Believe me, this happened to me multiple times already.
- The third option is to run the next [script](https://github.com/zapateros/Synacor-Challenge/blob/master/R/confirmation_mechanism_draft.R) for a while. Note that this is an optimized version of the mechanism, but isn't fully functional. Also it is not cleaned as I found it in my ugly drafts corner. However, it might help you understanding the mechanism a bit, as it shows correctly what happens when *d* is decreasing by one. 

I prefer the second method, as this will give you all the information at the lowest level. While the third method will help you find the correct values quick, it doesn't show you what is really happening (even though it is similar to what we saw earlier). For now, let's run this script (from the third method) for a while. This output will include the next table:

|a|b|c|d|e|f|
|:---:|:---:|:---:|:---:|:---:|:---:|
|0|20000|1|20000|20000|20000|
|0|20000|1|20000|19999|7233|
|0|20000|1|20000|19998|27234|
|0|20000|1|20000|19997|14467|
|.|.|.|.|.|.|
|0|20000|1|20000|0|8256|
|0|20000|1|19999|28257|20000|

Note that the second row is similar to the last row of the previous table. So the values of *f* are also given when running the recursive function. As you can see, when *e* is zero, *f* is 8256. In the next row, *d* is decreased by one and the new starting *e* is 28257. *f* starts at the *b* (or the set *reg8*) again. So our aim is to instantly calculate the new starting point of *e* when *d* is decreasing by one. In this way we bypass a half a billion loops (estimated). Given the recursive formula, we can expand to a general formula:

```R
f(1) = (f(0) + b + 1) %% mdl
f(2) = (f(1) + b + 1) %% mdl   
     = (((f(0) + b + 1) %% mdl) + b + 1) %% mdl    
     = (f(0) + b + 1 + b + 1) %% mdl   
     = (f(0) + 2*b + 2*1) %% mdl
     = (f(0) + n*b + n) %% mdl
f(n) = (f(0) + n*(b + 1)) %% mdl    #for n <= b  
```
This formula can be used to calculate *f* after *n* repetitions of the recursive formula. When filling in *n* is 20000, *f* is 8256, which agrees with our given value of *f* at *e* is zero. To calculate the next starting point of *e* is then simple:

```R
e = (b + f(20000) + 1) %% mdl
```
Which is exactly the same value as when we used the recursive formula 20,001 times or the general formula with *n* is 20,001. Therefore we can write a new 'general' formula for *e* when *d* decreases by one:

```R
e(n+1) = (b + f(e(n)) + 1) %% mdl
       = (b + (f(0) + e(n)*(b + 1)) %% mdl + 1) %% mdl
       = (b + f(0) + e(n)*(b + 1) + 1) %% mdl     #for n < d
```
Be aware of the fact that the solutions are technically not general but merely pragmatic optimizations, which could lead to a general solution. With the above formula we can calculate every next starting point of *e* when *d* decreases by one, until *d* is zero. When *d* is zero, *c* decreases by one and the new starting point of *d* is:

```R
d = (b + f(0) + e(n)*(b + 1) + 1) %% mdl 
```
Luckily *c* started at one, so this method only has to run twice. At this point we have optimized the mechanism well enough to have an acceptable runtime. There is a way of 'optimizing' it even further but you can skip this part if you want; I will not use it in the rest of the manual but it might interest you.
<details>
<summary>Finding a general solution</summary>
<br>
I'm making use of the fact that *b, d, e* and *f* all start at the same value of *reg8*; let's call it *x* for a shorter notation:

```R
e(1) = (b + f(e(0)) + 1) %% mdl
     = (b + f(0) + e(n)*(b + 1) + 1) %% mdl 
     = (x + x + x*(x + 1) + 1) %% mdl
     = ((x + 1)^2 + x) %% mdl
     
e(2) = (b + f(0) + e(1)*(b + 1) + 1) %% mdl 
     = (x + x + e(1)*(x + 1) + 1) %% mdl 
     = (x + x + (((x + 1)^2 + x) %% mdl)*(x + 1) + 1) %% mdl 
     = (x + (x + 1)*((x + 1)^2 + x) + x + 1) %% mdl
     = ((x + 1)^3 + (x + 1)^2 + x) %% mdl
     
e(3) = ((x + 1)^4 + (x + 1)^3 + (x + 1)^2 + x) %% mdl

e(n) = ((x + 1)^(n+1) + (x + 1)^n + .. + (x + 1)^2 + x) %% mdl   
```
Remember *x* is your input number *reg8*. It appears to be a summation function, which completely removes the for-loops. However, you are not there yet. Just with like our previous optimizations, when you run the function *d* + 1 times, you calculate the next starting *d*. After that, you run the function again (the new) *d* times. This is equivalent to when *c,d e* and *f* are zero and therefore the mechanism ends. Let's see it in formula- and script-form:

![alt text](https://github.com/zapateros/Synacor-Challenge/blob/master/R/other/img/general_solution_chapter_7.PNG "solution chapter seven")

```R
x   <- reg8
d_0 <- reg8
mdl <- 32768
d_1    <- (x + sum((x + 1)^(2:(d_0 + 2))) %% mdl
result <- (x + sum((x + 1)^(2:(d_1 + 2))) %% mdl
```
This is the general solution to this problem. However, standard R doesn't really work with high numbers/exponents and therefore it is sufficient to use the 'less-optimized' version. 
</details>

---

Let's walk through the script that is able to run the mechanism quickly. First a little recap, because I can imagine you lost track a bit. The confirmation mechanism is a method that loops through several Opcodes to imitate the Ackermann function. In this case this means that the stack is filled with ones, twos and threes (I'm leaving the four for what it is). The confirmation mechanism finally ends when all these numbers are removed from the stack again. The amount of ones, twos and threes that the stack starts with is depending on your input *register 8*. The removal process of these numbers is very time consuming and therefore it is necessary to decode and optimize it. Luckily most of the loops can be replaced with some relatively simple general formulas (if you understand the mechanism). A small note: it is even possible to replace all the loops but you'll end up with a summation function with high exponents, which in its turn is not efficient in R. Instead of working with an object that is filled with numbers (the stack), I isolated the problem by creating six variables *a,b,c,d,e* and *f*, which represent *reg1*, *reg2* and the amount of fours, threes, twos and ones in the stack respectively. 

Like said, the starting point is when *b,d,e* and *f* are set to your input *reg8*, which is still 20,000 in the example. Every time *d* decreases by one, the new starting point of *e* is given by (like stated earlier):

```R
e(n+1) = (b + f(0) + e(n)*(b + 1) + 1) %% mdl     #for n < d
```
So this function should be repeated *d* times for *c* to decrease by one:

```R
mdl <- 32768
reg8 <- 20000
b    <- reg8
d    <- reg8
e    <- reg8
f    <- reg8

while(d>0){
  e <- (b + ((b+1)*e + f) + 1) %% mdl
  d <- d - 1
}
```
If you run this script, *d* is now zero and then the new starting point for *d* (when *c* decreases by one) can be calculated by:

```R
d <- (b + ((b+1)*e + f) + 1) %% mdl
e <- reg8
```
Note that these functions are all discussed earlier but now implemented in R. At this point the new starting points are ``` c(a, b, c, d, e, f) == c(0, 20000, 0, 1665, 20000, 20000) ```. Now *d,e* and *f* have to be eliminated by following the same procedure (the loop over *d*). At this point you'll end up with ``` c(0, 20000, 0, 0, 31969, 20000) ```. Now to eliminate *e* we run the function (again as discussed earlier):

```R
f(e(0)) = (f(0) + e(0)*(b + 1)) %% mdl == 29985
```
So at this point we are left with ``` c(0, 20000, 0, 0, 0, 29985) ``` and we are almost there! Remember what is happening now? Everytime *f* decreases by one, *b* increases by one. Keeping in mind the modulo, when *f* is zero, *b* ends at 17217. And we're done! Almost. At this point the stack is exactly the same as where it started and *register b* is 17217. Now here's the misleading part: it looks like *register 1* (or *reg1* or *a*) is zero, but that is because we set the saving point at a spot everytime *i* is 6028. However, you can see in the last loop before it ends,``` reg1 <- (reg2 + 1) %% mdl``` and therefore in reality *register 1* is actually 17218. Now *i* is 5492, as it is set to the last value of the stack plus one, and this runs Opcode 4. This checks the value of *register 1* is equal to 6. This turned out to be the magic number where the *vm* continues on the right path. So this is the last ingredient to solve the puzzle! 

We have to find the correct value of *register 8* which leads to a *register 1* of six. Reverse the calculation and start at six is not possible, so we have to run the optimized mechanism with different input values until we find an output of six. I also tried to completely bypass the confirmation mechanism and set *register 1* to six and start the *vm* behind this mechanism again. However, not much later it also checks the value of *register 8*. Therefore it is the combination of register 1 and 8 that should be correct, for the teleporter to run smoothly. I know what you are probably thinking: instead of puzzling out the confirmation mechanism, you could just try to force every value of register 8 and check when you get a different outcome (or a code). Well, I have news for you buddy: I tried. And it didn't work because obviously the creator also thought of it. For every register 8 you'll set, the outcome is exactly the same, with one small difference: every time you get another code. The only way to find out if your code is correct, is to manually fill it in at the synacor website. So there is no other way than solving the mechanism. Luckily we already have solved it! See [script](https://github.com/zapateros/Synacor-Challenge/blob/master/R/confirmation_mechanism_final.R). 

This code will run in about 15 minutes on my computer but translating it to C# sped it up to about 15 seconds. The output is 25734 and this is the value *register 8* should be set for the teleporter to function correctly. To continue the *vm*, while bypassing the confirmation mechanism, we just have to set the *stack*, the *registers* and *i* to the correct values and run the *vm* again:

```R
stack <- c(6080, 16, 6124, 1, 2952, 25978, 3568, 3599, 2708, 5445, 3)
regs <-  c(6, 5, 3, 10, 101, 0, 0, reg8)
i <-5492
run_vm()
```
Note that the stack is set to the starting stack (before the mechanism) minus 5491 as this one is removed as the last step of the mechanism. In the *registers* just *reg1* and *reg2* are changed to the output of the mechanism. When you run the whole [script](https://github.com/zapateros/Synacor-Challenge/blob/master/R/chapter_7.R), you earn the seventh code! (7/8)


## Chapter 8:
To earn the last code you have to continue the text-based game again. The steps you have to follow to find the last puzzle are:
```R
c("west", "north", "north", "north", "north", "north", "north", "north", "east", "take journal",
           "west", "north", "north", "take orb")
```
At this point you're in possession of a journal, which you can open with ``` set_mode("manual") ``` and ``` go("look journal")```. This journal contains a couple of hints to solve the puzzle but in my opinion it was pretty straightforward. You are standing in a room, which is part of a 4x4 grid of rooms. You have an orb in your hand and the number 22 is carved on the orb's pedestal. If you walk through the rooms you'll find either a number or a minus-, plus- or a multiplication-sign. When you walk through the rooms you'll add or remove weight of the orb, according to your taken path. On the topright corner of the grid there is a door where you'll find the number 30 carved into it. So the objective of this puzzle is to walk through the grid, starting with a weight of 22 and end up at the door with a weight of 30. The grid is given below:

![alt text](https://github.com/zapateros/Synacor-Challenge/blob/master/R/other/img/grid_chapter_8.PNG "grid chapter eight")




