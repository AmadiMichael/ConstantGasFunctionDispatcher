### Constant Gas Function Dispatcher for Better Optimized Solidity External Libraries

This eliminates the need to use of 4 byte function selectors in our external libraries and uses as low as 1 byte of calldata to identify a jumpdest in the library's runtime code to jump to

It saves a minimum of 48 gas (16 \* 3) + (22 \* n) gas where n is the index of the function if it were to be on a chronological jumptable.
