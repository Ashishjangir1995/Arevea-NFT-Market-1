// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

pragma experimental ABIEncoderV2;

contract Tree{
enum BuyType {ERC1155, ERC721}
   struct Trade {
        address seller;
        address buyer;
        address erc20Address;
        address nftAddress;
        BuyType nftType;
        uint unitPrice;
        uint amount;
        uint tokenId;
        uint qty;
    }
    
    mapping (uint256 => Trade) public trade;
    
    function set(Trade memory trade) public returns (bool){
        return true;
    }
}