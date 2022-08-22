// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) 

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}