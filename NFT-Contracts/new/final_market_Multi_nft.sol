// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
     /**
     * @dev importing IERC165,IERC1155,ERC165Checker,IERC20,Safemath,IERC20
     */

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// NFTSingleMarketplace contract inherits ERC1155 and  above imports 
contract NFTMultiMarketplace {
    using SafeMath for uint256;
 //define struct for Fixed sale 
    struct FixedSale {
        address nftSeller;
        address nftBuyer;
        address erc20;
        uint256 amount;
        uint256 salePrice;
    }
//define Auction for multi nft market 
    struct Auction {
        uint256 auctionStart;
        uint256 auctionEnd;
        uint256 minPrice;
        uint256 nftHighestBid;
        uint256 nftAmount;
        address nftHighestBidder;
        address nftSeller;
        address erc20;
    }
    //define struct for SaleInfo
    struct SaleInfo {
        address _nftContractAddress;
        uint256 _tokenID;
    }
     //mapping address to FixedSale for nftContractFixedSale
    mapping(address => mapping(uint256 => FixedSale)) nftContractFixedSale;
     //mapping address for uint variable nftSaleStatus
    mapping(address => mapping(uint256 => uint256)) public nftSaleStatus;
    //mapping address for uint variable indexFixedSaleNFT
    mapping(address => mapping(uint256 => uint256)) indexFixedSaleNFT;
    //mapping address for uint variable nftContractAuctionSale
    mapping(address => mapping(uint256 => Auction)) nftContractAuctionSale;
    //mapping address for uint variable userBidPriceOnNFT
    mapping(address => mapping(uint256 => mapping(address => uint256))) public userBidPriceOnNFT;
    //mapping address for uint variable indexAuctionSaleNFT
    mapping(address => mapping(uint256 => uint256)) indexAuctionSaleNFT;

    SaleInfo[] fixedSaleNFT;
    SaleInfo[] auctionSaleNFT;

    bytes4 public constant IID_IERC1155 = type(IERC1155).interfaceId;
     //Event NftFixedSale
    event NftFixedSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 amount,
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
    );
    //Event NftBuyFromFixedSale
    event NftBuyFromFixedSale(
        address nftContractAddress,
        address nftBuyer,
        uint256 amount,
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
    //Event NftAuctionSale
    event NftBidPrice(
        address nftContractAddress,
        uint256 tokenId,
        uint256 bidPrice,
        address nftBidder
    );
    //Event NftBidPrice 
    event NftAuctionBidPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 finalBidPrice,
        address nftBidder
    );
    //Event CancelNftAuctionSale
    event CancelNftAuctionSale(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller
    );
    //Event NftAuctionBidPriceUpdate
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
    //Check the owner of NFT 
    modifier isSaleStartByOwner(address _nftContractAddress, uint256 _tokenId) {
        require(
            _ownerOf(_nftContractAddress, _tokenId),
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
            IERC1155(_nftContractAddress).isApprovedForAll(
                msg.sender,
                address(this)
            ),
            "Nft not approved to contract"
        );
        _;
    }
    //Check buying and selling price 
    modifier buyPriceMeetSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _buyPrice,
        uint256 _amount
    ) {
        require(
            _buyPrice >=
                (
                    nftContractFixedSale[_nftContractAddress][_tokenId]
                        .salePrice
                ) *
                    _amount,
            "buy Price not enough"
        );
        _;
    }
     //Check if price is greater than zero
    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
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
    // Check if auction is Reset by the owner 
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
    //Check if Bid is Greater 
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
    //Check if bid is made or not    
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

    // NFT FIXED SALE

    function nftFixedSale(
        address _nftContractAddress,
        address _erc20,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _salePrice,
        bytes memory _data
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
            _amount,
            _salePrice
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 1;

        indexFixedSaleNFT[_nftContractAddress][_tokenId] = fixedSaleNFT.length;
        fixedSaleNFT.push(SaleInfo(_nftContractAddress, _tokenId));

        IERC1155(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            _data
        );
    
        emit NftFixedSale(
            _nftContractAddress,
            msg.sender,
            _erc20,
            _tokenId,
            _amount,
            _salePrice,
            block.timestamp
        );
    }
    //Function to CancelFixedSale
    function cancelFixedsale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount,
        bytes memory _data
    )
        external
        isNftInFixedSale(_nftContractAddress, _tokenId)
        isSaleResetByOwner(_nftContractAddress, _tokenId)
    {
        IERC1155(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _amount,
            _data
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        delete fixedSaleNFT[(indexFixedSaleNFT[_nftContractAddress][_tokenId])];

        emit CancelNftFixedSale(_nftContractAddress, msg.sender, _tokenId);
    }
    //Function to updateFixedSalePrice
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
    //Function to buyFromFixedSale
    function buyFromFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _nftAmount,
        bytes memory _data
    )
        external
        payable
        isNftInFixedSale(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_amount)
        buyPriceMeetSalePrice(
            _nftContractAddress,
            _tokenId,
            _amount,
            _nftAmount
        )
    {
        require(
            _nftAmount != 0 &&
                nftContractFixedSale[_nftContractAddress][_tokenId].amount >=
                _nftAmount,
            "non-zero value or amount not greater"
        );

        address nftContractAddress = _nftContractAddress;
        uint256 tokenID = _tokenId;

        IERC1155(nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenID,
            _nftAmount,
            _data
        );

        _checkFixedSale(nftContractAddress, tokenID, _nftAmount);

        _isTokenOrCoin(
            nftContractFixedSale[nftContractAddress][tokenID].nftSeller,
            nftContractFixedSale[nftContractAddress][tokenID].erc20,
            nftContractFixedSale[nftContractAddress][tokenID].salePrice*_nftAmount
        );

        emit NftBuyFromFixedSale(
            nftContractAddress,
            msg.sender,
            tokenID,
            _amount,
            _nftAmount
        );
    }

    // NFT AUCTION SALE Function

    function createNftAuctionSale(
        address _nftContractAddress,
        address _erc20,
        uint256 _tokenId,
        uint256 _auctionStart,
        uint256 _auctionEnd,
        uint256 _minPrice,
        uint256 _nftAmount,
        bytes memory _data
    )
        external
        isSaleStartByOwner(_nftContractAddress, _tokenId)
        isNftAlreadyInSale(_nftContractAddress, _tokenId)
        isContractApprove(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
    {
        require(_nftAmount!=0,"zero invalid");
        
        address nftContractAddress = _nftContractAddress;
        address erc20 = _erc20; 
        uint256 tokenId = _tokenId;
        uint256 auctionStart = _auctionStart;   
        uint256 auctionEnd  = _auctionEnd;    
        uint256 minPrice    = _minPrice;    
        uint256 nftAmount   = _nftAmount;     
        bytes memory data        = _data;         

        _storedNftAuctionDetails(
            nftContractAddress,
            erc20,
            tokenId,
            auctionStart,
            auctionEnd,
            minPrice,
            nftAmount,
            data
        );

        indexAuctionSaleNFT[nftContractAddress][tokenId] = auctionSaleNFT.length;
        auctionSaleNFT.push(SaleInfo(nftContractAddress, tokenId));

        emit NftAuctionSale(
            nftContractAddress,
            msg.sender,
            erc20,
            tokenId,
            auctionStart,
            auctionEnd,
            minPrice
        );
    }
    //Function to makeBid
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
    //Function to cancelAuctionSale
    function _cancelAuctionSale(address _nftContractAddress, uint256 _tokenId)
        external
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionResetByOwner(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        isbidNotMakeTillNow(_nftContractAddress, _tokenId)
    {
        address nftContractAddress = _nftContractAddress;
        uint256 tokenId = _tokenId;

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        IERC1155(_nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId,
        nftContractAuctionSale[nftContractAddress][tokenId].nftAmount,
            ""
        );

        delete auctionSaleNFT[
            (indexAuctionSaleNFT[_nftContractAddress][_tokenId])
        ];

        emit CancelNftAuctionSale(_nftContractAddress, _tokenId, msg.sender);
    }
    //Function to settelAuction
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
    //Function to withdrawBid
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
    //Function to View getNFTAuctionSaleDetails
    function getNftAuctionSaleDetails(
        address _nftContractAddress,
        uint256 _tokenId
    ) external view returns (Auction memory) {
        return nftContractAuctionSale[_nftContractAddress][_tokenId];
    }
    //Function to view getAuctionSaleNfT
    function getAuctionSaleNFT() external view returns (SaleInfo[] memory) {
        return auctionSaleNFT;
    }

    //Function to view getFixedSaleNfT
    function getFixedSaleNFT() external view returns (SaleInfo[] memory) {
        return fixedSaleNFT;
    }
    //Function to view getFixedSale
    function getFixedSale(address _nftContractAddress, uint256 _tokenId)
        external
        view
        returns (FixedSale memory)
    {
        return nftContractFixedSale[_nftContractAddress][_tokenId];
    }
    //Function on ERC1155 Received
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return 0xf23a6e61;
    }
    //Function to Batch Received
    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return 0xbc197c81;
    }
    //internal function to check token or coin 
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
     //Internal Function to token amount transfer 
    function _tokenAmountTransfer(
        address _nftSeller,
        address _erc20,
        uint256 _buyAmount
    ) internal {
        require(
            IERC20(_erc20).transferFrom(msg.sender, _nftSeller, _buyAmount),
            "allowance not enough"
        );
    }
    //Internal function to amount transfer
    function _nativeAmountTransfer(address _nftSeller, uint256 _buyAmount)
        internal
    {
        (bool success, ) = _nftSeller.call{value: _buyAmount}("");
        require(success, "refund failed");
    }
    //internal function to checkFixedSale
    function _checkFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _nftAmount
    ) internal {
        if (
            nftContractFixedSale[_nftContractAddress][_tokenId].amount ==
            _nftAmount
        ) {
            nftSaleStatus[_nftContractAddress][_tokenId] = 0;
            delete fixedSaleNFT[
                (indexFixedSaleNFT[_nftContractAddress][_tokenId])
            ];

            nftContractFixedSale[_nftContractAddress][_tokenId].nftBuyer = msg
                .sender;
        } else {
            nftContractFixedSale[_nftContractAddress][_tokenId].amount =
                nftContractFixedSale[_nftContractAddress][_tokenId].amount -
                _nftAmount;
            nftContractFixedSale[_nftContractAddress][_tokenId].nftBuyer = msg
                .sender;
        }
    }
    //Internal Function to Transfer and PaySeller
    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _bidPrice,
        address _nftBuyer
    ) internal {

        IERC1155(_nftContractAddress).safeTransferFrom(
            address(this),
            _nftBuyer,
            _tokenId,
        nftContractAuctionSale[_nftContractAddress][_tokenId].nftAmount,
            ""
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 0;

        _isTokenOrCoin(
            nftContractAuctionSale[_nftContractAddress][_tokenId].nftSeller,
            nftContractAuctionSale[_nftContractAddress][_tokenId].erc20,
            _bidPrice
        );
    }
    //Internal Function to storeNFT AuctionDetails
    function _storedNftAuctionDetails(
        address _nftContractAddress,
        address _erc20,
        uint256 _tokenId,
        uint256 _auctionStart,
        uint256 _auctionEnd,
        uint256 _minPrice,
        uint256 _nftAmount,
        bytes memory _data
    ) internal {
        nftContractAuctionSale[_nftContractAddress][_tokenId] = Auction(
            _auctionStart,
            _auctionEnd,
            _minPrice,
            _minPrice,
            _nftAmount,
            address(0),
            msg.sender,
            _erc20
        );

        nftSaleStatus[_nftContractAddress][_tokenId] = 2;

        IERC1155(_nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            _nftAmount,
            _data
        );
    }
    //internal Function to 
    function _bidAmountTransfer(uint256 _buyAmount, address _erc20) internal {
        require(
            IERC20(_erc20).transferFrom(msg.sender, address(this), _buyAmount),
            "allowance not enough"
        );
    }
    
    function _ownerOf(address _nftContractAddress, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return
            IERC1155(_nftContractAddress).balanceOf(msg.sender, tokenId) != 0;
    }

    function isERC1155(address _nftContractAddress)
        external
        view
        returns (bool)
    {
        return IERC1155(_nftContractAddress).supportsInterface(IID_IERC1155);
    }

    receive() external payable {}
}