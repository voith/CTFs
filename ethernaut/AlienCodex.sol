//pragma solidity ^0.5.0;
//
//import '../helpers/Ownable-05.sol';
//
//contract AlienCodex is Ownable {
//
//  bool public contact;
//  bytes32[] public codex;
//
//  modifier contacted() {
//    assert(contact);
//    _;
//  }
//
//  function make_contact() public {
//    contact = true;
//  }
//
//  function record(bytes32 _content) contacted public {
//    codex.push(_content);
//  }
//
//  function retract() contacted public {
//    codex.length--;
//  }
//
//  function revise(uint i, bytes32 _content) contacted public {
//    codex[i] = _content;
//  }
//}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'openzeppelin-contracts/access/Ownable.sol';


interface AlienCodex {

  function owner() external view returns (address);

  function transferOwnership(address newOwner) external;

  function contact() external returns (bool);

  function make_contact() external;

  function record(bytes32) external;

  function retract() external;

  function revise(uint, bytes32) external;
}
