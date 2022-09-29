// SPDX-License-Identifier:UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity ^0.8.4;
import "./External/IERC165.sol";
import "./External/IERC721.sol";
import "./External/IERC1155.sol";
import "./IERC20.sol";
import "./External/Ownable.sol";
 contract MarketPlace is Ownable{
    enum BuyType {ERC1155, ERC721}
    event BuyAsset(address indexed Owner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event ExecuteBid(address indexed Owner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    uint8 private buyerFee;
    uint8 private sellerFee;
    address public Owner;
    struct Fee {
        uint platformFee;
        uint assetFee;
        uint royaltyFee;
        uint price;
        address tokenCreator;
    }
  
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
    
    constructor (uint8 _buyerFee, uint8 _sellerFee) {
        buyerFee = _buyerFee;
        sellerFee = _sellerFee;
    }
    function buyerServiceFee() external view virtual returns (uint8) {
        return buyerFee;
    }
    function sellerServiceFee() external view virtual returns (uint8) {
        return sellerFee;
    }
    function setBuyerServiceFee(uint8 _buyerFee) onlyOwner external  returns(bool) {
        buyerFee = _buyerFee;
        return true;
    }
    function setSellerServiceFee(uint8 _sellerFee) onlyOwner external  returns(bool) {
        sellerFee = _sellerFee;
        return true;
    }
   
    
function Sell(Trade calldata trade, Fee memory fee, address buyer, address seller) public {
      if(trade.nftType == BuyType.ERC721) {
            IERC721(trade.nftAddress).safeTransferFrom(seller, buyer, trade.tokenId);
        }
        if(trade.nftType == BuyType.ERC1155)  {
            IERC1155(trade.nftAddress).safeTransferFrom(seller, buyer, trade.tokenId, trade.qty, "");
        }
        if(fee.platformFee > 0) {
            IERC20(trade.erc20Address).transferFrom(buyer, Owner, fee.platformFee);
        }
        if(fee.royaltyFee > 0) {
            IERC20(trade.erc20Address).transferFrom(buyer, fee.tokenCreator, fee.royaltyFee);
        }
        IERC20(trade.erc20Address).transferFrom(buyer, seller, fee.assetFee);
    }


function getFees(uint _amount, BuyType buytype, address _nftAddress, uint _tokenId )public view returns(Fee memory) {
    Trade memory trade;
         
            uint platformFee = (25*(trade.unitPrice))/1000;
            uint assetFee =(trade.unitPrice);
            uint royaltyFee = (10*(trade.unitPrice)/100);
            uint price =  platformFee + buyerFee+ (trade.unitPrice * trade.qty);
         //   uint _amount= price+ assetFee;
        address tokenCreator;
           if(buytype == BuyType.ERC721) {
            tokenCreator= IERC721(_nftAddress).getCreator(_tokenId);
        }
        if(buytype == BuyType.ERC1155) {
        tokenCreator= IERC1155(_nftAddress).getCreator(_tokenId);
        }
            return Fee(platformFee,assetFee,royaltyFee,price,tokenCreator);
          
          
   }   


    function buyAsset(Trade calldata trade) external returns(bool) {
       Fee memory fee  = getFees(trade.amount, trade.nftType, trade.nftAddress, trade.tokenId);
      require((fee.price >= trade.unitPrice * trade.qty), "Paid invalid amount");
        address buyer = msg.sender;
        Sell(trade, fee, buyer, trade.seller);
        emit BuyAsset(trade.seller, trade.tokenId, trade.qty, msg.sender);
        return true;
    }
   

}