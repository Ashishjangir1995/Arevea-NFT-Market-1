// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 /**
     * @dev importing IERC721 interface,IERC721Receiver,IERC20,Safemath,IERC20
     */
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// NFTSingleMarketplace contract inherits ERC721 and  above imports 
contract NFTSingleMarketplace {
    using SafeMath for uint256;
    //define Auction for single nft market 
    struct Auction {
        uint256 auctionStart;
        uint256 auctionEnd;
        uint256 minPrice;
        uint256 nftHighestBid;
        address nftHighestBidder;
        address nftSeller;
        address erc20;
    }
    //define struct for Fixed sale 
    struct FixedSale {
        address nftSeller;
        address nftBuyer;
        address erc20;
        uint256 salePrice;
    }
    //define struct for SaleInfo
    struct SaleInfo {
        address _nftContractAddress;
        uint256 _tokenID;
    }
    //mapping address to FixedSale for nftContractFixedSale
    mapping(address => mapping(uint256 => FixedSale)) nftContractFixedSale;
    //mapping address to Auction for nftContractAuctionSale
    mapping(address => mapping(uint256 => Auction)) nftContractAuctionSale;
    //mapping address for uint variable nftSaleStatus
    mapping(address => mapping(uint256 => uint256)) public nftSaleStatus;
    //mapping address for userBidPriceOnNFT
    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public userBidPriceOnNFT;
    //mapping address for indexFixedSaleNFT
    mapping(address => mapping(uint256 => uint256)) indexFixedSaleNFT;
    //mapping address for indexAuctionSaleNFT
    mapping(address => mapping(uint256 => uint256)) indexAuctionSaleNFT;

    SaleInfo[] fixedSaleNFT;
    SaleInfo[] auctionSaleNFT;
    //Event NftFixedSale
    event NftFixedSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 tokenId,
        uint256 salePrice,
        uint256 timeOfSale
    );
    //Event CancelNFTFixedSale
    event CancelNftFixedSale(
        address nftContractAddress,
        address nftSeller,
        uint256 tokenId
    );
    //Event NftFixedSalePriceUpdated
    event NftFixedSalePriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 updateSalePrice
    );
    //Event NftBuyFromFixedSale
    event NftBuyFromFixedSale(
        address nftContractAddress,
        address nftBuyer,
        uint256 tokenId,
        uint256 nftBuyPrice
    );
    //Event NftAuctionSale
    event NftAuctionSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 tokenId,
        uint256 auctionStart,
        uint256 auctionEnd,
        uint256 minPrice
    );
    //Event NftBidPrice 
    event NftBidPrice(
        address nftContractAddress,
        uint256 tokenId,
        uint256 bidPrice,
        address nftBidder
    );
    //Event NftAuctionBidPriceUpdate
    event NftAuctionBidPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 finalBidPrice,
        address nftBidder
    );
    //Event CancelINftAuctionSale
    event CancelNftAuctionSale(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller
    );
    //Event NftBuyNowPriceUpdate
    event NftBuyNowPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 updateBuyNowPrice,
        address nftOwner
    );
    //Event NftAuctionSettle
    event NftAuctionSettle(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder,
        uint256 nftHighestBid,
        address nftSeller
    );
    //Event withdrawNftBid
    event withdrawNftBid(
        address nftContractAddress,
        uint256 tokenId,
        address bidClaimer
    );
    //Check if NFT in Sale or not 
    modifier isNftAlreadyInSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 0,
            "Nft already in sale"
        );
        _;
    }
    //Check if NFT in Fixed sale or not
    modifier isNftInFixedSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 1,
            "Nft not in fixed sale"
        );
        _;
    }
    //Check if NfT in Auction Sale or not 
    modifier isNftInAuctionSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 2,
            "Nft not in auction sale"
        );
        _;
    }
    //Check the owner of NFT 
    modifier isSaleStartByOwner(address _nftContractAddress, uint256 _tokenId) {
        require(
            msg.sender == IERC721(_nftContractAddress).ownerOf(_tokenId),
            "You are not nft owner"
        );
        _;
    }
     //Check the owner of NFT 
    modifier isSaleResetByOwner(address _nftContractAddress, uint256 _tokenId) {
        require(
            msg.sender ==
                nftContractFixedSale[_nftContractAddress][_tokenId].nftSeller,
            "You are not nft owner"
        );
        _;
    }
    //Check the Approval is given or not 
    modifier isContractApprove(address _nftContractAddress, uint256 _tokenId) {
        require(
            IERC721(_nftContractAddress).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Nft not approved to contract"
        );
        _;
    }
    //Check if Aucton is ended
    modifier isAuctionOver(address _nftContractAddress, uint256 _tokenId) {
        require(
            block.timestamp >
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .auctionEnd,
            "Auction not end"
        );
        _;
    }
    //Check Highest bid 
    modifier islatestBidGreaterPreviousOne(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice,
        uint256 _bidPrice1
    ) {
        if (
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20 ==
            address(0)
        ) {
            require(
                _bidPrice >
                    nftContractAuctionSale[_nftContractAddress][_tokenId]
                        .nftHighestBid,
                "Bid Greater than Previous Bid"
            );
        } else {
            require(
                _bidPrice1 >
                    nftContractAuctionSale[_nftContractAddress][_tokenId]
                        .nftHighestBid,
                "Bid Greater than Previous Bid"
            );
        }

        _;
    }
    //Check Auction is continuing 
    modifier isAuctionOngoing(address _nftContractAddress, uint256 _tokenId) {
        require(
            block.timestamp <
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .auctionEnd,
            "Auction end"
        );
        _;
    }
    //Check if NFT Auction reset parameter
    modifier isAuctionResetByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        require(
            msg.sender ==
                nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller,
            "not nft owner"
        );
        _;
    }
    //Check updated Bid Price 
    modifier isUpdatedBidGreaterPreviousOne(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateBidPrice,
        uint256 _updateBidPrice1
    ) {
        uint256 _finalBidPrice;
        if (
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20 ==
            address(0)
        ) {
            _finalBidPrice = userBidPriceOnNFT[_nftContractAddress][_tokenId][
                msg.sender
            ].add(_updateBidPrice);
        } else {
            _finalBidPrice = userBidPriceOnNFT[_nftContractAddress][_tokenId][
                msg.sender
            ].add(_updateBidPrice1);
        }
        require(
            _finalBidPrice >
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .nftHighestBid,
            "Bid Greater than Previous Bid"
        );
        _;
    }
    //Check Bid make 
    modifier isbidNotMakeTillNow(
        address _nftContractAddress,
        uint256 _tokenId
    ) {
        require(
            address(0) ==
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .nftHighestBidder,
            "bid make"
        );
        _;
    }
    //Check buying and selling price 
    modifier buyPriceMeetSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _buyPrice
    ) {
        require(
            _buyPrice >=
                nftContractFixedSale[_nftContractAddress][_tokenId].salePrice,
            "buy Price not enough"
        );
        _;
    }
    //Check if price is greater than zero
    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }
    //Function to buyAreveaToken from Arevea token owner a required amount 
    function buyAreveaToken(address _erc20_contract, address _buyer, uint256 _amount) public returns (bool){
      address  ERC20_contract= _erc20_contract;
      IERC20(ERC20_contract).transferFrom(0x2258c5b9C82ff0Fa923756ED3FD2aCb5616dF57c,_buyer, _amount);
    return(true);

   }
   //Function to SellAreveaToken 
    function Sell_AreveaToken(address _erc20_contract, address seller, uint256 _amount) public returns (bool){
      address  ERC20_contract= _erc20_contract;
      IERC20(ERC20_contract).transferFrom(seller, 0x2258c5b9C82ff0Fa923756ED3FD2aCb5616dF57c, _amount);
      return(true);

   }

    // NFT FIXED SALE Function 

    function nftFixedSale(
        address _nftContractAddress,
        address _erc20,
        uint256 _tokenId,
        uint256 _salePrice
    )
        external
        isSaleStartByOwner(_nftContractAddress, _tokenId)
        isNftAlreadyInSale(_nftContractAddress, _tokenId)
        isContractApprove(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_salePrice)
    {
        nftContractFixedSale[_nftContractAddress][_tokenId] = FixedSale(
            msg.sender,
            address(0),
            _erc20,
            _salePrice
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 1;

        indexFixedSaleNFT[_nftContractAddress][_tokenId] = fixedSaleNFT.length;
        fixedSaleNFT.push(SaleInfo(_nftContractAddress, _tokenId));

        IERC721(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        emit NftFixedSale(
            _nftContractAddress,
            msg.sender,
            _erc20,
            _tokenId,
            _salePrice,
            block.timestamp
        );
    }
    //Functon to Cancel Fixedsale
    function cancelFixedsale(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInFixedSale(_nftContractAddress, _tokenId)
        isSaleResetByOwner(_nftContractAddress, _tokenId)
    {
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        delete fixedSaleNFT[(indexFixedSaleNFT[_nftContractAddress][_tokenId])];

        emit CancelNftFixedSale(_nftContractAddress, msg.sender, _tokenId);
    }
    //Function on update sale price 
    function updateFixedSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateSalePrice
    )
        external
        isNftInFixedSale(_nftContractAddress, _tokenId)
        isSaleResetByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_updateSalePrice)
    {
        nftContractFixedSale[_nftContractAddress][_tokenId]
            .salePrice = _updateSalePrice;

        emit NftFixedSalePriceUpdated(
            _nftContractAddress,
            _tokenId,
            _updateSalePrice
        );
    }
    //Function to buy from fixedsale
    function buyFromFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount
    )
        external
        payable
        isNftInFixedSale(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_amount)
        buyPriceMeetSalePrice(_nftContractAddress, _tokenId, _amount)
    {
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;
        delete fixedSaleNFT[(indexFixedSaleNFT[_nftContractAddress][_tokenId])];

        nftContractFixedSale[_nftContractAddress][_tokenId].nftBuyer = msg
            .sender;

        _isTokenOrCoin(
            nftContractFixedSale[_nftContractAddress][_tokenId].nftSeller,
            nftContractFixedSale[_nftContractAddress][_tokenId].erc20,
            nftContractFixedSale[_nftContractAddress][_tokenId].salePrice
        );

        emit NftBuyFromFixedSale(
            _nftContractAddress,
            msg.sender,
            _tokenId,
            _amount
        );
    }

    // NFT AUCTION SALE FUNCTION

    function createNftAuctionSale(
        address _nftContractAddress,
        address _erc20,
        uint256 _tokenId,
        uint256 _auctionStart,
        uint256 _auctionEnd,
        uint256 _minPrice
    )
        external
        isSaleStartByOwner(_nftContractAddress, _tokenId)
        isNftAlreadyInSale(_nftContractAddress, _tokenId)
        isContractApprove(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
    {
        _storedNftAuctionDetails(
            _nftContractAddress,
            _erc20,
            _tokenId,
            _auctionStart,
            _auctionEnd,
            _minPrice
        );

        indexAuctionSaleNFT[_nftContractAddress][_tokenId] = auctionSaleNFT
            .length;
        auctionSaleNFT.push(SaleInfo(_nftContractAddress, _tokenId));

        emit NftAuctionSale(
            _nftContractAddress,
            msg.sender,
            _erc20,
            _tokenId,
            _auctionStart,
            _auctionEnd,
            _minPrice
        );
    }
    //Function to make bid 
    function makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice
    )
        external
        payable
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_bidPrice)
        islatestBidGreaterPreviousOne(
            _nftContractAddress,
            _tokenId,
            msg.value,
            _bidPrice
        )
    {
        if (
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20 !=
            address(0)
        ) {
            _bidAmountTransfer(
                _bidPrice,
                nftContractAuctionSale[_nftContractAddress][_tokenId].erc20
            );
        }

        nftContractAuctionSale[_nftContractAddress][_tokenId]
            .nftHighestBid = _bidPrice;
        nftContractAuctionSale[_nftContractAddress][_tokenId]
            .nftHighestBidder = msg.sender;

        userBidPriceOnNFT[_nftContractAddress][_tokenId][
            msg.sender
        ] = _bidPrice;

        emit NftBidPrice(_nftContractAddress, _tokenId, _bidPrice, msg.sender);
    }
    //Function to update Bid Price 
    function updateTheBidPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateBidPrice
    )
        external
        payable
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        priceGreaterThanZero(msg.value)
        isUpdatedBidGreaterPreviousOne(
            _nftContractAddress,
            _tokenId,
            msg.value,
            _updateBidPrice
        )
    {
        address nftContractAddress = _nftContractAddress;
        uint256 tokenId = _tokenId;
        uint256 finalBidPrice = userBidPriceOnNFT[nftContractAddress][tokenId][
            msg.sender
        ].add(_updateBidPrice);

        if (
            nftContractAuctionSale[nftContractAddress][tokenId].erc20 !=
            address(0)
        ) {
            _bidAmountTransfer(
                _updateBidPrice,
                nftContractAuctionSale[nftContractAddress][tokenId].erc20
            );
        }

        nftContractAuctionSale[nftContractAddress][tokenId]
            .nftHighestBid = finalBidPrice;
        nftContractAuctionSale[nftContractAddress][tokenId]
            .nftHighestBidder = msg.sender;

        userBidPriceOnNFT[nftContractAddress][tokenId][
            msg.sender
        ] = finalBidPrice;

        emit NftAuctionBidPriceUpdate(
            nftContractAddress,
            tokenId,
            finalBidPrice,
            msg.sender
        );
    }
    //Functino to Cancel Auction sell 
    function _cancelAuctionSale(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionResetByOwner(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        isbidNotMakeTillNow(_nftContractAddress, _tokenId)
    {
        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        delete auctionSaleNFT[
            (indexAuctionSaleNFT[_nftContractAddress][_tokenId])
        ];

        emit CancelNftAuctionSale(_nftContractAddress, _tokenId, msg.sender);
    }
    //Function to settle Auction 
    function settleAuction(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOver(_nftContractAddress, _tokenId)
    {
        address nftBuyer = nftContractAuctionSale[_nftContractAddress][_tokenId]
            .nftHighestBidder;

        _transferNftAndPaySeller(
            _nftContractAddress,
            _tokenId,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftHighestBid,
            nftBuyer
        );

        userBidPriceOnNFT[_nftContractAddress][_tokenId][nftBuyer] = 0;
        delete auctionSaleNFT[
            (indexAuctionSaleNFT[_nftContractAddress][_tokenId])
        ];

        emit NftAuctionSettle(
            _nftContractAddress,
            _tokenId,
            nftBuyer,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftHighestBid,
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller
        );
    }
    //Functino to withDraw Bid money
    function withdrawBid(address _nftContractAddress, uint256 _tokenId)
        external
        isAuctionOver(_nftContractAddress, _tokenId)
    {
        require(
            msg.sender !=
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .nftHighestBidder,
            "You are highest bidder"
        );
        require(
            userBidPriceOnNFT[_nftContractAddress][_tokenId][msg.sender] > 0,
            "nothing to withdraw"
        );

        //_amountTransfer(msg.sender,userBidPriceOnNFT[_nftContractAddress][_tokenId][msg.sender]);

        userBidPriceOnNFT[_nftContractAddress][_tokenId][msg.sender] = 0;

        emit withdrawNftBid(_nftContractAddress, _tokenId, msg.sender);
    }
    //Functon to get NFT Aucttion Sale Details
    function getNftAuctionSaleDetails(
        address _nftContractAddress,
        uint256 _tokenId
    ) external view returns (Auction memory) {
        return nftContractAuctionSale[_nftContractAddress][_tokenId];
    }
    //Function to View getAuctionSale Details
    function getAuctionSaleNFT() external view returns (SaleInfo[] memory) {
        return auctionSaleNFT;
    }
    //Function to View getFixedSale
    function getFixedSaleNFT() external view returns (SaleInfo[] memory) {
        return fixedSaleNFT;
    }
    //Function to View Fixed Sale 
    function getFixedSale(address _nftContractAddress, uint256 _tokenId)
        external
        view
        returns (FixedSale memory)
    {
        return nftContractFixedSale[_nftContractAddress][_tokenId];
    }
    //Internal Function to Receive NFT
    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
    //Intenal Function to NFT Transfer and payment to seller 
    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice,
        address _nftBuyer
    ) internal {
        IERC721(_nftContractAddress).safeTransferFrom(
            address(this),
            _nftBuyer,
            _tokenId
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        _isTokenOrCoin(
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller,
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20,
            _bidPrice
        );
    }
    //Internal Function to token amount transfer 
    function _tokenAmountTransfer(
        address _nftSeller,
        address _erc20,
        uint256 _buyAmount
    ) internal {
        require(
            IERC20(_erc20).transferFrom(msg.sender, address(this), _buyAmount),
            "allowance not enough"
        );
        IERC20(_erc20).transfer(_nftSeller, _buyAmount);
    }
    //Internal function to amount transfer
    function _nativeAmountTransfer(address _nftSeller, uint256 _buyAmount)
        internal
    {
        (bool success, ) = _nftSeller.call{value: _buyAmount}("");
        require(success, "refund failed");
    }
    // Internal function to storeAuctionDetails 
    function _storedNftAuctionDetails(
        address _nftContractAddress,
        address _erc20,
        uint256 _tokenId,
        uint256 _auctionStart,
        uint256 _auctionEnd,
        uint256 _minPrice
    ) internal {
        nftContractAuctionSale[_nftContractAddress][_tokenId] = Auction(
            _auctionStart,
            _auctionEnd,
            _minPrice,
            _minPrice,
            address(0),
            msg.sender,
            _erc20
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 2;

        IERC721(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );
    }
    
    function _isTokenOrCoin(
        address _nftSeller,
        address _erc20,
        uint256 _buyAmount
    ) internal {
        if (_erc20 != address(0)) {
            _tokenAmountTransfer(_nftSeller, _erc20, _buyAmount);
        } else {
            _nativeAmountTransfer(_nftSeller, _buyAmount);
        }
    }

    function _bidAmountTransfer(uint256 _buyAmount, address _erc20) internal {
        require(
            IERC20(_erc20).transferFrom(msg.sender, address(this), _buyAmount),
            "allowance not enough"
        );
    }

    receive() external payable {}
}