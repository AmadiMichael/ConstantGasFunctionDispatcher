// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ConstantGasExternalLibrary {
    uint256 totalSupply;
    mapping(address addr => uint256 balance) _balanceOf;

    constructor(bool shouldDeploy) {
        /// if true, it deploys successfully
        /// if false, it reverts with the concatenation of the creation time and runtime jumpdests of each of the 3 functions
        ///             each jumpdest is 4 bytes so each concatenated jumpdest is 8 bytes. (each pair of creation and runtime jumpdests are stored in a word)
        if (!shouldDeploy) {
            function () internal _add = add;
            function () internal _sub = sub;
            function () internal _mul = mul;

            assembly {
                mstore(0x00, _add)
                mstore(0x20, _sub)
                mstore(0x40, _mul)
                revert(0x00, 0x60)
            }
        }
    }

    fallback() external payable {
        // first byte of calldata represents jumpdest for the operation
        // other parameters are abi encodepacked.
        function () internal action;
        assembly {
            let jumpDest := shr(248, calldataload(0x00))
            action := jumpDest
        }

        action();

        // execution will not get here.
        // i add this because without a dependence of an internal function by an external or public function, solidity will exclude it from the runtime code
        add();
        sub();
        mul();
    }

    function add() internal {
        // returns bool success

        // declare paramters
        uint256 a;
        uint256 b;

        // assign values to parameters from calldata
        assembly {
            a := calldataload(0x01)
            b := calldataload(0x21)
        }

        // some large computation here
        uint256 result = a + b;

        // return result
        assembly {
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }

    function sub() internal {
        // returns bool success

        // declare paramters
        uint256 a;
        uint256 b;

        // assign values to parameters from calldata
        assembly {
            a := calldataload(0x01)
            b := calldataload(0x21)
        }

        // some large computation here
        uint256 result = a - b;

        // return result
        assembly {
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }

    function mul() internal {
        // returns bool success

        // declare paramters
        uint256 a;
        uint256 b;

        // assign values to parameters from calldata
        assembly {
            a := calldataload(0x01)
            b := calldataload(0x21)
        }

        // some large computation here
        uint256 result = a * b;

        // return result
        assembly {
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }
}
