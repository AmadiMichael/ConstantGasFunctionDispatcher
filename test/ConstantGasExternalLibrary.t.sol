// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ConstantGasExternalLibrary} from "../src/ConstantGasExternalLibrary.sol";
import {NonConstantGasExternalLibrary} from "../src/NonConstantGasExternalLibrary.sol";

contract ConstantGasExternalLibraryTest is Test {
    address public constantGas;
    address public nonConstantGas;
    uint8 ADD_JUMPDEST;
    uint8 SUB_JUMPDEST;
    uint8 MUL_JUMPDEST;

    function setUp() public {
        // get the jumpdests of the functions you need by passing in false which makes it revert with bytes of all the function's jumpdest abi.encoded
        // use try catch to prevent revert
        try new ConstantGasExternalLibrary(false) {}
        catch {
            uint8 mint_jumpdest;
            uint8 burn_jumpdest;
            uint8 transfer_jumpdest;

            // the returned jumpdests are 8 bytes, 4 bytes for the creation time jumpdest of the function and 4 bytes for the runtime jumpdest of the function
            // we only need the runtime jumpdest, so we cast it into a uint8 (1 byte). our contract is small so this is okay.
            assembly {
                let fmp := mload(0x40)
                returndatacopy(fmp, 0x00, 0x60)
                mint_jumpdest := mload(fmp)
                burn_jumpdest := mload(add(0x20, fmp))
                transfer_jumpdest := mload(add(0x40, fmp))
                mstore(0x40, add(fmp, 0x60))
            }

            // store it in storage
            ADD_JUMPDEST = mint_jumpdest;
            SUB_JUMPDEST = burn_jumpdest;
            MUL_JUMPDEST = transfer_jumpdest;

            // deploy the contract, true makes the deployment succcessful
            constantGas = address(new ConstantGasExternalLibrary(true));
            // console2.logBytes(abi.encodePacked(ADD_JUMPDEST, uint256(1000), uint256(2000)));
            // console2.logBytes(constantGas.code);
        }

        nonConstantGas = address(new NonConstantGasExternalLibrary());

        // console2.log("Jumpdest below:");
        // console2.logBytes1(bytes1(ADD_JUMPDEST));
        // console2.logBytes1(bytes1(SUB_JUMPDEST));
        // console2.logBytes1(bytes1(MUL_JUMPDEST));
    }

    function test_ConstantGas() public {
        (bool success, bytes memory data) =
            constantGas.staticcall(abi.encodePacked(ADD_JUMPDEST, uint256(1000), uint256(2000)));
        assertEq(abi.decode(data, (uint256)), 3000);

        (success, data) = constantGas.staticcall(abi.encodePacked(SUB_JUMPDEST, uint256(2000), uint256(1000)));
        assertEq(abi.decode(data, (uint256)), 1000);

        (success, data) = constantGas.staticcall(abi.encodePacked(MUL_JUMPDEST, uint256(1000), uint256(2000)));
        assertEq(abi.decode(data, (uint256)), 2000000);
    }

    function test_NonConstantGas() public {
        (bool success, bytes memory data) = nonConstantGas.staticcall(
            abi.encodePacked(NonConstantGasExternalLibrary.add.selector, uint256(1000), uint256(2000))
        );
        assertEq(abi.decode(data, (uint256)), 3000);

        (success, data) = nonConstantGas.staticcall(
            abi.encodePacked(NonConstantGasExternalLibrary.sub.selector, uint256(2000), uint256(1000))
        );
        assertEq(abi.decode(data, (uint256)), 1000);

        (success, data) = nonConstantGas.staticcall(
            abi.encodePacked(NonConstantGasExternalLibrary.mul.selector, uint256(1000), uint256(2000))
        );
        assertEq(abi.decode(data, (uint256)), 2000000);
    }
}
