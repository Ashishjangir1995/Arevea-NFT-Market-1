// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./AREVEAToken.sol";
import "./NFT.sol";
import "./MultipleNFT.sol";

contract NFTMarketPlace {
    ERC20 token;
    ERC721 NFT;
  ERC1155 MultiNFT;


//keep the record for tokenID is listed on sale or not
    mapping(uint256 => bool) public tokenIdForSale;

    mapping(uint256 => uint256) public tokenprice;

   mapping(uint256 => address) private nftonwer;
    uint auctionEndTime;

constructor ( address NFTAddress, address tokenAddress, address MultiNFTaddress)  {
        token = ERC20(tokenAddress);  
        NFT = ERC721(NFTAddress); 
        MultiNFT = MultipleNFT(MultiNFTaddress); 
//auctionEndTime= block.timestamp+ biddingTime;
    }



address public contractaddress= address(this);

    function nftSale(uint256 _tokenId,uint256 _tokenprice, uint qty, bool forSale) external {
        require(msg.sender == NFT.ownerOf(_tokenId),"Only owners can change this status");
        tokenIdForSale[_tokenId] = forSale;
        tokenprice[_tokenId] = _tokenprice*qty;
        nftonwer[_tokenId] = msg.sender;
        
    }


    function nftBuy(uint256 _tokenId) public payable {
    require(tokenIdForSale[_tokenId],"Token must be on sale first");

        address nftowner=nftonwer[_tokenId];
        uint nftPrice = tokenprice[_tokenId];
        require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");
       require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");
        token.transferFrom(msg.sender, NFT.ownerOf(_tokenId), nftPrice);

        NFT.transferFrom(nftowner, msg.sender, _tokenId);

    }

function MultiNFTBuy(uint256 _tokenId, uint qty) public {
    require(tokenIdForSale[_tokenId],"Token must be on sale first");

        address nftowner=nftonwer[_tokenId];
        uint nftPrice = tokenprice[_tokenId]*qty;
        require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");
       require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");
        token.transferFrom(msg.sender, MultiNFT.getCreator(_tokenId), nftPrice);

        MultiNFT.safeTransferFrom( nftowner, msg.sender, _tokenId, qty, "");       

}



}