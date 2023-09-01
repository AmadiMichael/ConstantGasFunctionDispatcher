// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract NonConstantGasExternalLibrary {
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        uint256 result = a + b;

        // return true
        assembly {
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }

    function sub(uint256 a, uint256 b) external pure returns (uint256) {
        uint256 result = a - b;

        // return true
        assembly {
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }

    function mul(uint256 a, uint256 b) external pure returns (uint256) {
        uint256 result = a * b;

        // return true
        assembly {
            mstore(0x00, result)
            return(0x00, 0x20)
        }
    }
}
