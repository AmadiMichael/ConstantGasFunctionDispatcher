### Constant Gas Function Dispatcher for Better Optimized Solidity External Libraries

**Unaudited.**

This eliminates the need to use of 4 byte function selectors in our external libraries and uses as low as 1 byte of calldata to identify a jumpdest in the library's runtime code to jump to

It saves a minimum of 48 gas (16 \* 3) + (22 \* n) gas where n is the index of the function if it were to be on a chronological jumptable.

Note: Due to the new code generator via_ir uses, compiling contracts that use this pattern with via_ir set to true will not have as much efficiency as ones with via_ir set to false.
This is because the new codegen uses internal IDs starting from 1 as what internal function pointers hold, then at runtime it mimics a switch statement to find the right internal function to jump to. This is essentially the same as a linear jumpdest which we are trying to avoid in the first place. So it is recommended to turn off via_ir when compiling contracts that use this pattern
