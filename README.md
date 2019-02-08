# Synacor-Challenge
Synacor Challenge: Solutions in R

Started at 18:25, 7 January 2019

Completed at 14:29, 7 February 2019

After completing Advent of Code 2018, I was looking for the next challenge when I stumbled upon the Synacor Challenge (https://challenge.synacor.com/). **If you don't want to see spoilers, you should now stop reading!** Basically what you have to do is create a virtual machine capable of running the included binary file. It starts out with implementing pretty basic Opcodes and it's not until you make your first mistake when you see the first signs of the true ingenuity of this challenge. The binary file talks back! Okay, no, it just gives hints about what you did wrong, but in a smart way. In total you have find eight codes to complete the challenge. Some of which are earned after just following steps and some are earned after solving some nice puzzles. And then there is this one code which is earned, only after losing a couple of nights sleep and gaining some grey hairs: code seven. I immediately knew exactly what to do, but I did it wrong anyway. When I eventually earned this code, I didn't even feel glad or relieved; I just was annoyed by the fact it took me so long. For more info about that part, see below. 

I'm writing this readme as a manual/blog, or at least how I solved the problems, but I will probably transfer it to a website someday. I completed the challenge completely in R, but there are some calculations which could be sped up with python or even faster with C# (from 15 minutes to 15 seconds). The manual contains 8 chapters, one for each code obviously. In the map 'R' the script is given per chapter/code. *An important note* is that the script works on my input files. With a different input file (bin-file) it is possible you have to change the order of some parts (as explained in the chapters below). 

## Chapter 1: A jump start
Finding the first code is easy. Just download the files from the website (the given link). The file 'arch-spec' contains the instructions to get you going and 'challenge.bin' obviously is the input binary file. The first file also contains your first code (1/8). Now you can't stop anymore.

## Chapter 2: Little endian
Your *first step* is to convert the binary file to a vector of readable numbers (for us). Each number is composed of a 16-bit litle-endian pair, which basically means that every 16 bits (or two bytes of 8 bits each) represent an integer. The term little-endian pair means that the first byte (read from left to right) is the small one, and so the second the large one. Each byte is read from right to left by standard means, so 01010110 is equivalent to 0 + 64 + 0 + 16 + 0 + 4 + 2 + 0 = 86. If this byte is the second of the pair, it has to be multiplied by 256 (or shifted by 8 bits). Now you have to add the first and the second integer to get the resulting integer of the little-endian pair. This results in a vector of 30050 integers from 0 to 32775. The R-code doing this is given below:
```R
file_name <- "challenge.bin"
info      <- file.info(file_name)
lbe       <- readBin(file_name, integer(), size = 2, n = info$size, endian = "little", signed = FALSE)
```
The numbers 0 to 32767 are read as a literal value. The numbers 32768 to 32775 are read as registers 1 to 8. For the observant viewers: the instruction manual states registers 0 to 7. **R-objects start at index 1, where many other languages start at index 0.** lbe[1] in R is the first value of vector lbe, while in python lbe[1] is the second value of the vector. This makes it a bit more difficult to follow the steps sometimes, as you always have to keep this in mind when applying instructions. The registers are a storage for 8 integers. There is another storage, but this one is unbound: the stack. These two storages, combined with the vector of values and the Opcodes are all the ingredients for completing this challenge. 

> Basically you are looping through the vector of values (lbe), which point to what Opcode to run, which on its turn change values of the registers, add or remove values from the stack, change certain values of lbe, output text or make you jump to certain indexes of lbe.

This is really all it is. But I can imagine this doesn't really make sense at this point. After you finish the challenge, read this statement again and I'm sure it will. 

The *second step* is to implement Opcode 0, 19 and 21, as stated in the instructions. I'm writing every Opcode as a function, which can be called when needed. All the relevant Opcodes are given in the R-scripts or in the 'arch-spec'-file. The latter also contains an example of how to read the numbers of the vector lbe and what actions should follow. I'm walking you through the very first steps, just for (hopefully) some clarity. 
<br/>

|i   | 1 | 2 | 3 | 4 | 5 | 6 | 7|
|---|---|---|---|---|---|---|---|
|lbe | 21 | 21 | 19 | 87 | 19 | 101 | 19 |


You start with the first value of lbe (i=1, lbe[i]), which is 21. This means the virtual machine (vm) runs Opcode 21, which is actually no operation. So the only thing changing here is that i is set to 2 (i <<- i + 1). It is a double arrow because it is an operation inside a function. When using just a single arrow, the incremented i only exists inside the function. Now the second number of lbe, lbe[2] also is 21 and the vm repeats Opcode 21 and sets i to 3. The third one is where it becomes interesting: lbe[3] = 19, which means the vm should display the ascii character represented by the number on the next i: lbe[4] = 87. This is a "W". Also i is incremented two times, so now i = 5. lbe[5] is also 19 and so on. Now a text message appears, containing the second code! (2/8). [Go to R-script](https://github.com/zapateros/Synacor-Challenge/blob/master/R/chapter_2.R)

## Chapter 3:
