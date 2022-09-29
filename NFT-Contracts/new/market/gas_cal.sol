// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Test {

    // reverts
    function test() external {
        address payable addr = payable(msg.sender);
        addr.transfer(tx.gasprice);
    }
    // works
    function test1() external {
        address payable addr = payable(msg.sender);
        addr.transfer(1000000000); // 1gwei
    }

    receive() external payable {}
}