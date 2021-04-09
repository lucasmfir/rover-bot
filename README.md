# rover-bot

Input data and move a rover bot over a plateau.

## Requirements

First of all, you must have Elixir instaled in your computer, if you haven't check the [official docs](https://elixir-lang.org/install.html) to how to install.

## Configure

You should configure a input file with plateau size, initial coordinates and movement instructions, or use the start file `input.txt`.

The first line of input file represents the plateau size, two numbers that represents X axis and Y axis separeted by space

The following line represents the initial coodinates: X axis, Y axis, pointed direction.

The third one represents the movement instructions.

It's possible to, in same plateau, input data to more than one rover bot. Just add more intial coordinate and movement instructions lines to the end of file.

Check the example above:

```txt
5 5
1 2 N
LMLMLMLMM
3 3 E
MMRMMRMRRM
```

### Specifications

- Both axis from plateau muts be >= 1
- Possible directions: "N", "S", "E", "W"
- Possible movements: "M", "R", "L"

## How to run

To run the script use the following command:
  
```sh
iex rover-bot.exs
```

After that you will be able to choose between:

- 1 : run script
- 2 : run tests

If you choose the option `1`, a file `output.txt` will be created showing the rovers final coordinates.
  
## Assumptions

- The rover bot can't pass plateau boundry.
