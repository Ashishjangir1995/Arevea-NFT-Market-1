//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./AVERAEC20.sol";
import "./MultipleNFT.sol";
import "./NFT.sol";

contract MarketPlace {
    
    using SafeMath for uint256;
    
    AREVEAToken token;
    NFT nft;
    MultipleNFT MNFT;
    uint plateformFee= 0;

    //keep the record for tokenID is listed on sale or not
    mapping(uint256 => bool) public tokenIdForSale;

    mapping(uint256 => uint256) public tokenprice;
    
    mapping(uint256 => address) private nftowner;
 
 address public contractaddress= payable(address(this));
    
enum nftBuy{erc721, erc1155}
nftBuy selection;

function putNftOnSale (uint256 _tokenId, uint256 _tokenprice, uint256 quantity) external payable{
       require(msg.sender == nft.ownerOf(_tokenId),"Only owners can sell this NFT");
       if(quantity ==1)
       {
        tokenprice[_tokenId] = _tokenprice;
        nftowner[_tokenId] = payable(msg.sender);

        //token.transferFrom(msg.sender, address(this), plateformFee);// transfer token to marketplace for selling NFT
        nft.transferFrom(msg.sender, address(this), _tokenId); // transfer NFT to marketplace
       }
        if (quantity>1)
        {
        tokenprice[_tokenId] = _tokenprice;
        nftowner[_tokenId] = msg.sender;
        
        require(MNFT.balanceOf(msg.sender, _tokenId) >= quantity, "insufficient balance");
        MNFT.safeTransferFrom(msg.sender, address(this), _tokenId, quantity, "0x00");
        token.transferFrom(msg.sender, address(this), plateformFee);
    }    
}

function BuyNFT(uint256 _tokenId, uint _selection) public payable {

    //    if(selection =nftBuy.erc721)

    if (_selection==1){

       

        uint nftPrice = tokenprice[_tokenId]+plateformFee;

        require(msg.sender!=nftowner[_tokenId], "You already have this NFT");

        require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");

        require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");

        token.transferFrom(msg.sender,nftowner[_tokenId], tokenprice[_tokenId]);

        //oken.transferFrom(address(this), nft.ownerOf(_tokenId), tokenprice[_tokenId]);

        nft.transferFrom(nftowner[_tokenId], msg.sender, _tokenId);

       }
 
}


}