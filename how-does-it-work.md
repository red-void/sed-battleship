Sed Battleship by Red Void

# Introduction

In this document I’ll try to explain how this whole crap actually works — I think the comments in the code might be insufficient. There’s a more detailed description on [Habr](https://habr.com/ru/articles/1042940/), but it’s all in Russian. Maybe someday I’ll translate the entire article into English to turn it into a proper blog post.

While working on the code, I didn’t use any LLMs — neither for code generation nor for consultation. This might have made some architectural decisions a bit obscure, but that personal touch is where the art lies, right?

I assume that you know what regular expressions are and that you are familiar with the basic mechanics of `sed`.

# Functions and variables

Consider the following code snippet:
```
# some code

:func
{
    s/^$/function called/ ; p 
}

# some other code
```

We can call the function using the `b func` command, but only once: afterward, execution will proceed to the `some other code` block. We want to learn how to call the function more than once.

To achieve this, we’ll use the tools provided by sed. In sed, there are two buffers: the `pattern space` (primary) and the `hold space` (auxiliary). We can perform three operations with the hold space:
1. Completely overwrite it with the contents of the pattern space (`h`).
2. Append the contents of the pattern space to it (`H`).
3. Swap its data with the data in the pattern space (`x`).

Let’s initialize the pattern space with the string `call_stack = ,\n` and write it to the hold space. This will serve as our call stack (more precisely, a return stack):
```
s/^$/call_stack = ,\n/
h
```

Before each function call, we’ll modify the `call_stack` by appending the label to which we need to return; after the call command, we’ll set this label:
```
x ; s/\(call_stack = [^\n]*\)/\1,first_return_label/ ; x
b func
:first_return_label

x ; s/\(call_stack = [^\n]*\)/\1,second_return_label/ ; x
b func
:second_return_label
```

The function itself must also be modified to know that it needs to return somewhere:
```
:func
{
	s/^.*$/function called/ ; p
	b return
}
```

Finally, we’ll need a return handler. This is a special function that acts as a mapping table between entries in the `call_stack` and jumps to labels. Within this function, we switch to the hold space, locate the last entry in the `call_stack`, remove it, and jump to the corresponding label:
```
:return
{
	x
	/call_stack = [^\n]*,first_return_label\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b first_return_label ; }
	/call_stack = [^\n]*,second_return_label\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b second_return_label ; }
}
```

As a result, we now have a script that invokes the func function two times:
```
s/^.*$/call_stack = ,\n/
h

x ; s/\(call_stack = [^\n]*\)/\1,first_return_label/ ; x
b func
:first_return_label

x ; s/\(call_stack = [^\n]*\)/\1,second_return_label/ ; x
b func
:second_return_label

q

:func
{
	s/^.*$/function called/ ; p
	b return
}

:return
{
	x
	/call_stack = [^\n]*,first_return_label\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b first_return_label ; }
	/call_stack = [^\n]*,second_return_label\n/ { s/\(call_stack = [^\n]*\),[^\n,]*/\1/ ; x ; b second_return_label ; }
}
```

From now on, calling any function — no matter how complex — becomes straightforward: we just need to add an entry to the `call_stack`, add the appropriate label and include this entry-label mapping in the return handler table.

Throughout this process, we’ve been treating the `call_stack` entry in the hold space as a named memory area — that is, as a global variable. Similarly, we can work with other entries by viewing the hold space as a kind of RAM. To do this, we need two low‑level functions for reading and writing: `get` and `set`. Here’s how they work:
1. We take the last line of the pattern space, append a unique label to it, and move it to the beginning.
2. Then we append the contents of the pattern space to the hold space using the H command.
3. After that, we switch to the hold space and remove all unnecessary data, using the unique label as a reference.
4. Next, using regular expressions, we either overwrite the required variable (when calling `set)` or retrieve its value (when calling `get`).
5. In the latter case, we perform a similar procedure in reverse to transfer the retrieved value back to the pattern space.

```
:set
{
  s/\([^\n]*\)$/:set\n\1/
  s/^\(.*\)\(:set\n[^\n]*\)$/\2\n\1/
  s/\n$//
  H
  s/^:set\n[^\n]*\n*//
  x
  s/^\(.*\)\n:set\n\([^\n]*\).*$/\2\n\1/
  s/^\([^\n= ]*\) = \([^\n]*\)\n\(.*\)\1 = [^\n]*\(.*\)$/\3\1 = \2\4/
  x
  b return
}

:get
{
  s/\([^\n]*\)$/:get\n\1/
  s/^\(.*\)\(:get\n[^\n]*\)$/\2\n\1/
  s/\n$//
  H
  s/^:get\n[^\n]*\n*//
  x
  s/^\(.*\)\n:get\n\([^\n]*\).*$/\2\n\1/
  s/^\([^\n]*\)\n\(.*\)\1 = \([^\n]*\)/:get\n\3\n\2\1 = \3/
  H
  s/^:get\n[^\n]*\n\(.*\)$/\1/
  x
  s/^\n*\(.*\)\n:get\n\([^\n]*\).*$/\1\n\2/
  b return
}
```

Using the same principle, let's implement the `copy` function. This function takes the value stored in one variable and assigns it to another one:
```
:copy
{
  s/\([^\n]*\)$/:copy\n\1/
  s/^\(.*\)\(:copy\n[^\n]*\)$/\2\n\1/
  s/\n$//
  H
  s/^:copy\n[^\n]*\n*//
  x
  s/^\(.*\)\n:copy\n\([^\n]*\).*$/\2\n\1/
  s/^\([^ ]*\) = \([^\n]*\)\n\(.*\)\2 = \([^\n]*\)/\1 = \4\n\3\2 = \4/
  s/^\([^ ]*\) = \([^\n]*\)\n\(.*\)\1 = [^\n]*/\3\1 = \2/
  x
  b return
}
```

# Arithmetics: represent and increment
Arithmetic in the code is based on the binary representation of numbers — strings of zeros and ones. This approach eliminates the need to implement huge addition and multiplication tables and makes number comparison easier.

The maximum bit width of a number is determined by its length: to increase the maximum bit width, simply prepend the required number of leading zeros to the number. Arithmetic operations assume that operands have the same bit width.

The most important operation is the increment. For this operation, we identify the "tail" of ones in the number (which may be of zero length) and replace all the ones in the "tail" with underscores. Then, we change the zero preceding the "tail" (if it exists) to a one. The final step is to replace all underscores in the "tail" with zeros:

```
:inc {
  :loop
  s/1\(_*\)$/_\1/
  /1_*$/ b loop

  s/0\(_*\)$/1\1/

  :reverseloop
  s/_\(_*\)$/0\1/
  /_$/ b reverseloop
}
```

# Arithmetics: addition and subtraction

To add two numbers, we’ll process them from the end. If the last bit of the second operand is 0, we simply save the last bit of the first operand as the result bit and remove the last bits from both operands. If the last bit of the second operand is 1, we perform an increment on the first operand and save the last bit of the resulting number as the next result bit. We repeat this process until all bits are processed:

```
:add
{
  # Operands reading
  s/$/\nadd::first_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,add::get1/ ; x
  b get
  :add::get1

  s/$/\nadd::second_operand/
  x ; s/\(call_stack = [^\n]*\)/\1,add::get2/ ; x
  b get
  :add::get2

  # Prepare variables to add
  s/\([01]*\)\n\([01]*\)$/\1 \n\2/

  # Addition loop: add the second operand bit by bit
  :add::loop
    # Skip adding bit if it is zero
    /0$/ b add::continueloop

    # Increment procedure
    :add::_replaceloop
      s/\([01]*\)1\(_*\) \([01]*\)\n\([01]*\)$/\1_\2 \3\n\4/
      /[01]*1_* [01]*\n[01]*$/ b add::_replaceloop
    s/\([01]*\)0\(_*\) \([01]*\)\n\([01]*\)$/\11\2 \3\n\4/
    :add::_reversereplaceloop
      s/\([01]*\)_\([^\n ]*\) \([01]*\)\n\([01]*\)$/\10\2 \3\n\4/
      /[01]*_[01 _]*\n[01]*$/ b add::_reversereplaceloop
    
    :add::continueloop
    # Save the current bit
    s/\([01]*\)\([01]\) \([01]*\)\n\([01]*\).$/\1 \2\3\n\4/
  /[01]$/ b add::loop

  # Write the result
  s/ \([^\n]*\)\n$/add::result = \1/
  x ; s/\(call_stack = [^\n]*\)/\1,add::result/ ; x
  b set
  :add::result

  b return
}
```

Important note: the final bit is not carried over during the increment operation. This means that when adding `1111+0001`, we get `0000`. We may use it to perform subtraction: `x - y = x + (-y)`

If we invert all the bits of the number `y`, we obtain the number `~y`, which, when added to `y`, yields a number consisting entirely of ones. If we then add 1 to this number, the result is 0. This implies that `-y = ~y + 1`, and the final subtraction formula is the following:
```
x - y = x + (-y) = x + (~y + 1)
```

This allows us to implement the subtraction function through inversion, increment and addition. The subtraction function is called `:sub`, you may look for it in the main script. From now on, I won’t provide code snippets unless necessary.

# Arithmetics: multiplication and division

The binary multiplication algorithm is quite straightforward. We initialize the intermediate result with zero. If the last bit of the second operand is zero, we simply perform a bit shift on the first operand. If it is one, we add the first operand to the intermediate result via a call to the `add` function before the shift. The last bit of the second operand is then removed. This process repeats until the second operand has no bits left. The multiplication function is called `:mul`; you can find it in the code.

The algorithm for binary division with remainder is fully described on [Wikipedia](https://en.wikipedia.org/wiki/Division_algorithm). Of note, the result of the :div function is stored in two separate variables: `div::mod_result` and `div::div_result`. Additionally, the function does not include a check for division by zero — within the scope of the project, we control the operands and know that such a division will never occur.

# Random number generation

We use the classic linear congruential method as the random number generator. You can view its implementation in the `:rng` function. The generator is seeded with the player’s position; we will return to a detailed examination of the seeding procedure later.

# Field drawing and representation

To properly and neatly redraw the field, we use ANSI escape sequences. For example, before rendering the field, we output the sequence \c[[H\c[[J. Control sequences are also used to make text bold or colored. Look at the full implementation in the `:draw` function.

The fields themselves are stored as 100‑character arrays. There are three of them in total: the player’s field, the suggestions field, and the opponent’s field.

Additionally, there are two auxiliary variables that define the placement of the player’s and opponent’s ships. They are sequences of cell numbers (from 0 to 99) in binary form, separated by spaces. Within a single sequence, cell numbers are separated by commas.

# Player moves

To process a player’s move, we need to convert the coordinates into a field cell number. If the input is invalid and conversion is not possible, we issue a warning and prompt the player to try again. Otherwise, after conversion, the cell number is matched against the opponent’s field and the suggestions field, followed by further analysis:

1. If the cell has already been checked, we warn the player and prompt them to try again.
2. If the cell is empty, we mark it as such on the suggestions field and pass the turn to the opponent.
3. If the shot hits a ship, we mark this on the suggestions field and additionally mark the diagonally adjacent cells as empty. The hit ship is also reflected on the opponent’s field.
4. If the ship is not just hit but sunk (determined by the auxiliary variables discussed earlier), this is reflected on both the opponent’s field and the suggestions field. Additionally, all cells around the sunk ship are marked as empty.
5. As a final step, we check whether any "healthy" ship cells remain on the opponent’s field. If not, the player is awarded victory. Otherwise, the player is prompted to try again.

# Computer moves

The computer determines its move as follows. A random number is generated using the RNG, which determines whether the opponent hits or misses. This random number is then divided by the number of remaining ship‑containing or empty cells on the player’s field, respectively. The result is the final cell coordinate for the shot.

This approach allows us to tune difficulty level easily: it’s sufficient to add a hit probability modifier — "luck" — to the formula. Luck is a number from 1 to 5.

The generation procedure is the following. Let there be `N` unchecked cells on the field, of which `k` cells contain ships. The luck parameter is `L`. First, we generate a random number from `0` to `2N + kL - 1`. If it is less than `2k + kL`, we divide it by `2+L`. The resulting number is the index of a ship cell to be targeted by the computer. If the random number is greater than or equal to `2k + kL`, we subtract `2k + kL` from it and divide the result by `2`. The resulting number is the index of an empty cell to be targeted. Then, we only need to convert this number into a standard coordinate.

Thus, the probability of hitting a ship is `(2k+kL) / (2N+kL)`. The difficulty level selected at the start of the game is simply the assignment of the parameter `L`.

All the remaining logic is simply an adapted copy‑paste of the player’s move.

# Player ship placement

Ship placement validation for the player must prohibit placing ships adjacent to each other (including diagonally). To implement this, we use existing functions that outline ships when they are sunk.

When placing a new ship, we check that all its coordinates currently contain dots. After that, the ship is outlined with waves in a circular pattern. Once all ships are placed, all waves on the player’s field are replaced back with dots.

# Computer ship placement

Before the computer starts placing its ships, we must seed the random number generator. As the seed, we take the compressed layout of the player’s ships, add the difficulty level bits to it, and divide this number by the constant `M` of the linear congruential generator. Excess bits are truncated.

You may ask: why compress the data? Why not just use the full field? The answer lies in performance. The division algorithm has quadratic complexity, and while dividing an 80‑bit number is still acceptable, dividing a 100+‑bit number becomes noticeably slow.

After that, we simply generate random coordinates and orientations (vertical or horizontal) and attempt to place the next ship accordingly. The algorithm converges in a reasonable amount of time, but to keep the player engaged, I implemented kind of progress bar: after each placement attempt (successful or not), a dot is added to the log text, and the field is redrawn.

Once the process is complete, the game begins.

# Conclusion

It was not a simple project. But I stand on the shoulders of giants — thank you, [mikkun](https://github.com/mikkun), [aureliojargas](https://github.com/aureliojargas), [laurentlb](https://github.com/laurentlb), and [bolknote](https://github.com/bolknote). I’m also deeply grateful to my wife for her constant inspiration and unwavering support.
