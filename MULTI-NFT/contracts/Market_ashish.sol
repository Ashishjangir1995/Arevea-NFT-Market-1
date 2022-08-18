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
    //create a struct for all detals of nft type 
    //keep the record for tokenID is listed on sale or not
    mapping(uint256 => bool) public tokenIdForSale;

    mapping(uint256 => uint256) public tokenprice;
    
    mapping(uint256 => address) private nftonwer;

  
    
    
         address public contractaddress= address(this);
    
    enum nftBuy{erc721,erc1155} 
    nftBuy public selection;

function nftSale(uint256 _tokenId,uint256 _tokenprice, bool forSale) external {
       require(msg.sender == nft.ownerOf(_tokenId),"Only owners can change this status");
        
        tokenIdForSale[_tokenId] = forSale;
        tokenprice[_tokenId] = _tokenprice;
        nftonwer[_tokenId] = (msg.sender);
        
    }    
   // user input variable nf
    function buySingleNft(uint256 _tokenId) public {
       // if(selection = nftBuy.erc721)
        require(tokenIdForSale[_tokenId],"Token must be on sale first");

        address nftowner=nftonwer[_tokenId];
        uint nftPrice = tokenprice[_tokenId];
        require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");
        require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");
        
        token.transferFrom(msg.sender, nft.ownerOf(_tokenId), nftPrice);
        nft.transferFrom(nftowner, msg.sender, _tokenId);
        //if (selection = nftBuy.erc1155)
    //     require(tokenIdForSale[_tokenId],"Token must be on sale first");

    //     //address nftowner=nftonwer[_tokenId];
    //    // uint nftPrice = tokenprice[_tokenId];
    //     require(token.allowance(msg.sender, address(this)) >= nftPrice, "Insufficient allowance.");
    //     require(token.balanceOf(msg.sender) >= nftPrice, "Insufficient balance.");
        
    //     token.transferFrom(msg.sender, MNFT.ownerOf(_tokenId), nftPrice);
    //     MNFT.transferFrom(nftowner, msg.sender, _tokenId);

    }

    function buyMultiNFT(uint256 _tokenId, uint256 _amount) public payable {
        address owner = nftonwer[_tokenId];
        uint256 price = tokenprice[_tokenId];
        uint256  amount = _amount;
        require(tokenIdForSale[_tokenId],"Token must be on sale first");

        require(price * _amount == msg.value, "Send value is not equal to NFT price");

        require(owner != msg.sender, "NFT already yours");

        uint256 royalty = amount * price * (MNFT.royaltyFee(_tokenId) / 100);

        address minter = MNFT.getCreator(_tokenId);

        payable(minter).transfer(royalty);

        payable(owner).transfer((price * _amount) - royalty);

        MNFT.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "0x00");

   

    }


    
event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);

uint public nftId;

    address payable public seller;
    uint public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;

function startAuction(uint _tokenId ,uint _startingBid, uint _amount ) external {
        require(!started, "started");
        require(msg.sender == nft.ownerOf(_tokenId)||msg.sender== MNFT.getCreator(_tokenId), "Not owner of the NFT");
        if (_amount ==1){ 
        nft.transferFrom(msg.sender, address(this),_tokenId);
        }
        if (_amount >1) {
        MNFT.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "0x00");
        }
        started = true;
        endAt = block.timestamp + 7 days;
        highestBid = _startingBid;
        emit Start();
    }
 function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    function withdrawBidAmount() external {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    function endAuction() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }




}