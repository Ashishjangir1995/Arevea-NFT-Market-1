// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


import "./AVERAEC20.sol";
import "./MultipleNFT.sol";
import "./NFT.sol";


contract MarketPlace {
   
    //using SafeMath for uint256;
   
    AREVEAToken token;
    NFT nft;
    MultipleNFT MNFT;


    uint256 public sellId = 1;
    uint256 public tradeId = 1;
    uint256 public plateformFee=5;
 

    mapping(uint256 => Trade) public tradeHistory;
    mapping(uint256 => Sell) public saleList;
   
    mapping(uint256 => bool) public isTokenTraded;
    mapping(address => uint256) public userSaleCounter;
    mapping(address => uint256) public userTradeCounter;
   

   

    struct Sell {
        uint256 tokenId;
        uint256 price;
        uint256 timestamp;
        uint256 amount;
        uint256 sold;
        address owner;
    }

    struct Trade {
        uint256 tokenId;
        address seller;
        address buyer;
        uint256 price;
        uint256 amount;
        uint256 sellId;
    }

   

    struct SellView {
        uint256 sellId;
        uint256 tokenId;
        uint256 price;
        uint256 timestamp;
        uint256 amount;
        uint256 sold;
        address owner;
    }

    struct TradeView {
        uint256 tradeId;
        uint256 tokenId;
        address seller;
        address buyer;
        uint256 price;
        uint256 amount;
        uint256 sellId;
    }

   

    // Events
    event PutOnSale(uint256 tokenId, uint256 price, uint256 sellId);

   


    // ----------------------------------------------------------------------------------------------------------------
    // CALLS ----------------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------------
    function getListedItems() public view returns (SellView[] memory) {
        SellView[] memory listedItems = new SellView[](sellId - 1);
        for (uint256 i = 1; i <= sellId - 1; i++) {
            Sell memory list = saleList[i];
            listedItems[i - 1] = SellView(
                i,
                list.tokenId,
                list.price,
                list.timestamp,
                list.amount,
                list.sold,
                list.owner
            );
        }
        return listedItems;
    }

    function getUserListedItems(address _user) public view returns (SellView[] memory) {
        uint256 size = userSaleCounter[_user];
        SellView[] memory listedItems = new SellView[](size);
        uint256 counter = 0;
        for (uint256 i = 1; i <= sellId; i++) {
            if (saleList[i].owner == _user) {
                Sell memory list = saleList[i];
                listedItems[counter] = SellView(
                  i,
                    list.tokenId,
                    list.price,
                    list.timestamp,
                    list.amount,
                    list.sold,
                    list.owner
                );
                counter++;
            }
        }
        return listedItems;
    }

    function getTrades() public view returns (TradeView[] memory) {
        TradeView[] memory tradedItems = new TradeView[](tradeId - 1);
        for (uint256 i = 1; i <= tradeId - 1; i++) {
            Trade memory trade = tradeHistory[i];
            tradedItems[i - 1] = TradeView(
                i,
                trade.tokenId,
                trade.seller,
                trade.buyer,
                trade.price,
                trade.amount,
                trade.sellId
            );
        }
        return tradedItems;
    }

    function getUserTrades(address _user) public view returns (TradeView[] memory) {
        uint256 size = userTradeCounter[_user];
        TradeView[] memory userTrades = new TradeView[](size);
        uint256 counter = 0;
        for (uint256 i = 1; i <= tradeId; i++) {
            if (tradeHistory[i].seller == _user || tradeHistory[i].buyer == _user) {
                Trade memory trade = tradeHistory[i];
                userTrades[counter] = TradeView(
                    i,
                    trade.tokenId,
                    trade.seller,
                    trade.buyer,
                    trade.price,
                    trade.amount,
                    trade.sellId
                );
                counter++;
            }
        }
        return userTrades;
    }

   

    function getTokenSaleList(uint256 _tokenId) public view returns (SellView[] memory) {
        uint256 arraySize = 0;
        for (uint256 i = 1; i < sellId; i++) {
            if (saleList[i].tokenId == _tokenId && saleList[i].amount > saleList[i].sold) {
                arraySize++;
            }
        }

        SellView[] memory listedItems = new SellView[](arraySize);
        uint256 index = 0;
        for (uint256 i = 1; i < sellId; i++) {
            if (saleList[i].tokenId == _tokenId && saleList[i].amount > saleList[i].sold) {
                Sell memory list = saleList[i];
                listedItems[index] = SellView(
                    i,
                    list.tokenId,
                    list.price,
                    list.timestamp,
                    list.amount,
                    list.sold,
                    list.owner
                );
                index++;
            }
        }
        return listedItems;
    }

 


    // ----------------------------------------------------------------------------------------------------------------
    // SENDS ----------------------------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------------------------------
    function putNftOnSale( uint256 _tokenId,  uint256 _price, uint256 _amount) external payable {
        require(MNFT.balanceOf(msg.sender, _tokenId) >= _amount, "insufficient balance");
        MNFT.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
        token.transferFrom(msg.sender, address(this), plateformFee);
        saleList[sellId] = Sell(_tokenId, _price, block.timestamp, _amount, 0, msg.sender);
        userSaleCounter[msg.sender]++;
        emit PutOnSale(_tokenId, _price, sellId);
        sellId++;
    }

    function removeFromSellingList(
        uint256 _tokenId,
        uint256 _sellId,
        uint256 _amount
    ) public payable {
        require(saleList[_sellId].amount >= _amount, "amount specified is higher than available NFT amount");
        require(saleList[_sellId].tokenId == _tokenId, "tokenId doesn't belong to this sale");
        require(saleList[_sellId].owner == msg.sender, "caller is not token owner");

        MNFT.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "0x00");
        saleList[_sellId].amount = saleList[_sellId].amount - _amount;
    }

    function buyNFT(uint256 _sellId, uint256 _amount) public payable {
        address owner = saleList[_sellId].owner;
        uint256 price = saleList[_sellId].price+plateformFee;
        uint256 amount = saleList[_sellId].amount;
        uint256 tokenId = saleList[_sellId].tokenId;
        require(amount >= _amount && _amount > 0, "amount specified is higher than available NFT amount");
        require((price *_amount)+plateformFee<= msg.value , "Send value is not equal to NFT price");
        require(owner != msg.sender, "NFT already yours");

        tradeHistory[tradeId] = Trade(tokenId, owner, msg.sender, price, _amount, _sellId);
        isTokenTraded[tokenId] = true;

        saleList[_sellId].amount = saleList[_sellId].amount - _amount;
        saleList[_sellId].sold = saleList[_sellId].sold + _amount;

        userTradeCounter[msg.sender]++;
        userTradeCounter[owner]++;

        require(token.allowance(msg.sender, address(this)) >= price, "Insufficient allowance.");
        require(token.balanceOf(msg.sender) >= price, "Insufficient balance.");

        token.transferFrom(msg.sender, MNFT.getCreator(tokenId),price); 
        MNFT.safeTransferFrom(address(this), msg.sender, tokenId, _amount, "0x00");

        uint256 royalty = _amount * price * (MNFT.royaltyFee(tokenId) / 100);
        address minter = MNFT.getCreator(tokenId);

        payable(minter).transfer(royalty);
        payable(owner).transfer((price * _amount) - royalty);
        tradeId++;
    }

   
}