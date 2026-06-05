# The game

It is a classic battleship game with standard russian rules:

1. Each player has 10x10 field.
2. Each player has 10 ships: one 4-squared battleship, two 3-squared cruisers, three 2-squared destroyers and four 1-squared torpedo boats.
3. Ships cannot be placed adjacent to each other.
4. If hit, player continues shooting.
5. If missed, the enemy takes turn.

Player plays against the computer. There are 5 difficulty levels.

# How to run

`sed -nf battleship.sed`

Then press Enter once.

# How to play

Firstly, you need to select a difficulty level. Type a digit from `1` to `5` and press Enter.

Then, you need to place your ships. You should choose a cell to be the upper-left cell of your ship, and its orientation (horizontal or vertical). Type the coordinate and the orientation letter. Like `A5V` or `G5H` and press Enter. Repeat 10 times. You know, just try it, you'll get it in practice quicker :)

After that wait for a while: it was really hard to implement FAST ship placing on `sed`... 

Then, just input your suggestion (like `A5` or `B7`) and press Enter.

# Implementation

Yep, it is pure `sed`. PURE.

Arithmetics, random number generation, placing and shooting algorithms, validation, difficulty level tuning — every single thing was implemented without external calls, only with `sed` capabilities.

LLMs were not involved also, even for consulting. The result is a pure product of my intelligence (and a bit of stackoverflow :) )

