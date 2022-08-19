//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./AVERAEC20.sol";
import "./MultipleNFT.sol";
import "./NFT.sol";


contract MarketPlace {
    
    
    
    AREVEAToken token;
    NFT nft;
    MultipleNFT MNFT;

    uint plateformFee= 5;

    //keep the record for tokenID is listed on sale or not
    mapping(uint256 => bool) public tokenIdForSale;

    mapping(uint256 => uint256) public tokenprice;
    
    mapping(uint256 => address) private nftowner;
 
 address public contractaddress= address(this);
    
enum nftBuy{erc721, erc1155}
nftBuy selection;

function putNftOnSale (uint256 _tokenId, uint256 _tokenprice, uint256 quantity, bool sale) external {
      
       if(quantity ==1)
       {
        tokenprice[_tokenId] = _tokenprice;
        nftowner[_tokenId] = msg.sender;
        tokenIdForSale[_tokenId] = sale;
        // require(msg.sender == nft.ownerOf(_tokenId),"Only owners can sell this NFT");
        //token.transferFrom(msg.sender,  plateformFee);// transfer token to marketplace for selling NFT
       
       }
        if (quantity>1)
        {
        tokenprice[_tokenId] = _tokenprice;
        nftowner[_tokenId] = msg.sender;
        tokenIdForSale[_tokenId] = sale;
        require(msg.sender == MNFT.getCreator(_tokenId),"Only owners can sell this NFT");
       // MNFT.safeTransferFrom(msg.sender, address(this), _tokenId, quantity, "0x00");
       // token.transferFrom(msg.sender, address(this), plateformFee);
    }    
}
   


function BuyNFT(uint256 _tokenId, uint _selection) public payable {
    //    if(selection =nftBuy.erc721)
    if (_selection==1){
       
        uint nftPrice = tokenprice[_tokenId];
        require(msg.sender!=nftowner[_tokenId], "You already have this NFT");
        require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");
        require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");
       
        token.transferFrom(msg.sender,nftowner[_tokenId], tokenprice[_tokenId]);
        nft.safeTransferFrom(nftowner[_tokenId], msg.sender, _tokenId);
       }

    // if (selection == nftBuy.erc1155)
    if (_selection>1){
        uint256  quantity = _selection;
        uint nftPrice = tokenprice[_tokenId];
        require(msg.sender!=nftowner[_tokenId], "You already have this NFT");
        require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");
        require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");
        
        token.transferFrom(msg.sender,MNFT.getCreator(_tokenId), nftPrice);
        //token.transferFrom(ad,MNFT.getCreator(_tokenId), nftPrice);
         uint256 royalty = quantity * nftPrice * (MNFT.royaltyFee(_tokenId) / 100);
        address minter = MNFT.getCreator(_tokenId);
        payable(minter).transfer(royalty);
        payable(nftowner[_tokenId]).transfer((nftPrice * quantity) - royalty);
        MNFT.safeTransferFrom(MNFT.getCreator(_tokenId), msg.sender, _tokenId, quantity, "tranfered successfully");
        }

    }


   
    
// event Start();
//     event Bid(address indexed sender, uint amount);
//     event Withdraw(address indexed bidder, uint amount);
//     event End(address winner, uint amount);

//     uint public nftId;
//     address payable public seller;
//     uint public endAt;
//     bool public started;
//     bool public ended;

//     address public highestBidder;
//     uint public highestBid;
//     mapping(address => uint) public bids;

// function startAuction(uint _tokenId ,uint _startingBid, uint _amount,uint256 _biddingTime_Sec ) external payable {
//         require(!started, "started");
//         require(msg.sender == nft.ownerOf(_tokenId)||msg.sender== MNFT.getCreator(_tokenId), "Not owner of the NFT");
        
//         started = true;
//         endAt = block.timestamp + _biddingTime_Sec;
//         highestBid = _startingBid;
//         emit Start();
//     }
//  function bid() external payable {
//         require(started, "not started");
//         require(block.timestamp < endAt, "ended");
//         require(msg.value > highestBid, "value < highest");

//         if (highestBidder != address(0)) {
//             bids[highestBidder] += highestBid;
//         }

//         highestBidder = msg.sender;
//         highestBid = msg.value;

//         emit Bid(msg.sender, msg.value);
//     }

//     function withdrawBidAmount() external {
//         uint bal = bids[msg.sender];
//         bids[msg.sender] = 0;
//         token.transferFrom(msg.sender, address(this), bal);
//         payable(msg.sender).transfer(bal);

//         emit Withdraw(msg.sender, bal);
//     }

//     function endAuction() external {
//         require(started, "not started");
//         require(block.timestamp >= endAt, "not ended");
//         require(!ended, "ended");

//         ended = true;
//         if (highestBidder != address(0)) {
//             nft.safeTransferFrom(address(this), highestBidder, nftId);
//             seller.transfer(highestBid);
//         } else {
//             nft.safeTransferFrom(address(this), seller, nftId);
//         }

//         emit End(highestBidder, highestBid);

//     }

}