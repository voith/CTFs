// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
// https://ethernaut.openzeppelin.com/level/0x573eAaf1C1c2521e671534FAA525fAAf0894eCEb

contract Reentrance {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      // This contract was originally written in solc 0.6
      // added unchecked for it to be to be compatible with the older version
      unchecked {
        balances[msg.sender] -= _amount;
      }
    }
  }

  receive() external payable {}
}
