// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../ethernaut/MagicNumber.sol";

// We want to do return 42 but using opcodes regardless of which function is called.
// The idea is work our way backwards to return 42
// return expects data to be written to memory
// return takes memory start position  and memory size as input from the stack
// mstore collects memory start position and value from stack
// PUSH1 collects next byte from code. Hence the push value needs to be be written to the bytecode

// start by writing 42 to the stack
// PUSH1 2a (2a is 42 in hexadecimal)
// PUSH1 00 (memory offset for mstore. Write at the 0 location)
// MSTORE (store 42 to memory at location 0)
// PUSH1 20 (32 (0x2a) bytes is the size of the data written to memory)
// PUSH1 00 (memory start position)
// RETURN

// OPCODES
// PUSH1 - 0x60
// MSTORE - 0x52
// RETURN - 0xf3
// The above code in hex resolves to
// 0x602a60005260206000f3

contract ExploitSolver {
    constructor() {
        assembly {
            // write the bytecode to memory in the constructor
            // so that it is stored as code by the EVM
            mstore(0, 0x602a60005260206000f3)
            // The code will be left padded with 22 bytes of 0s
            // 00000000000000000000000000000000000000000000602a60005260206000f3
            // offset by 22 bytes so that the padded 0s are not stored as code
            return(22, 10)
        }
    }
}


interface Solver {
  function whatIsTheMeaningOfLife() external view returns (uint);
}

contract TestMagicNumber is Test {
    ExploitSolver exploitSolver;
    Solver solver;
    MagicNumber magicNumber;

    function setUp() external {
        exploitSolver = new ExploitSolver();
        magicNumber = new MagicNumber();
        magicNumber.setSolver(address(exploitSolver));
    }

    function testExploit() external {
        address _exploitSolver = magicNumber.solver();
        solver = Solver(magicNumber.solver());
        uint num = solver.whatIsTheMeaningOfLife();
        assertTrue(_exploitSolver.code.length <= 10);
        assertEq(num, 42);
    }
}
