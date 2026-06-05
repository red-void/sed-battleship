# The game

This is a classic battleship game with standard Russian rules:

1. Each player has a 10×10 grid.
2. Each player has 10 ships: one 4‑square battleship, two 3‑square cruisers, three 2‑square destroyers, and four 1‑square torpedo boats.
3. Ships cannot be placed adjacent to each other (diagonally or orthogonally).
4. If a player hits an enemy ship, they continue shooting.
5. If a player misses, the turn passes to the opponent.

The player competes against the computer. There are five difficulty levels.

# How to run

`sed -nf battleship.sed`

Then press Enter once.

# How to play

First, you need to select a difficulty level. Type a digit from 1 to 5 and press Enter.

Next, you need to place your ships. You should choose a cell to be the upper‑left corner of your ship and specify its orientation (horizontal or vertical). Enter the coordinate and the orientation letter (for example, A5V or G5H) and press Enter. Repeat this step 10 times. You know, just try it, you'll get the hang of it in practice quicker :)

After that, please wait for a while: it was really hard to implement FAST ship placement using `sed`…

Then, simply enter your guess (for example, A5 or B7) and press Enter.

# Implementation

Yep, it is pure `sed`. PURE.

Arithmetics, random number generation, placing and shooting algorithms, validation, difficulty level tuning — everything was built from scratch using only `sed`, without a single external call.

LLMs were not involved also, even for consulting. The result is a pure product of my intelligence (with a bit of help from stackoverflow :) )
