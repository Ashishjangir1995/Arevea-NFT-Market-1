// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC1155/extensions/ERC1155Supply.sol";

contract MultipleNFT is ERC1155 {
    address owner;
    mapping(uint256 => uint256) nftType;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    event MintNFT(
        address to,
        uint256 _id,
        uint256 amount,
        bytes data
    );
    event MintBatchNFT(
        address to,
        uint256[] ids,
        uint256[] amounts,
        bytes data
    );

    constructor(address _owner, string memory _url) ERC1155(_url) {
        require(bytes(_url).length > 0, "empty string not allowed");
        owner = _owner;
    }

    function mintNFT(
        address to,
        uint256 _id,
        uint256 amount,
        bytes memory data
    ) external  
    {
        _mint(to, _id, amount, data);
        emit MintNFT(to, _id, amount, data);
    }

    function mintBatchNFT(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external 
    {

        _mintBatch(to, ids, amounts, data);

        emit MintBatchNFT(to, ids, amounts, data);
    }
    
    

}