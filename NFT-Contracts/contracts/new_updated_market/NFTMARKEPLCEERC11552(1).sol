// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTMarketplace1155 {
    using SafeMath for uint256;

    struct FixedSale {
        address nftSeller;
        address nftBuyer;
        address erc20;
        uint256 amount;
        uint256 salePrice;
    }

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

    struct SaleInfo {
        address _nftContractAddress;
        uint256 _tokenID;
    }

    mapping(address => mapping(uint256 => mapping(uint256 => FixedSale))) nftContractFixedSale;
    mapping(address => mapping(uint256 => uint256)) public nftSaleStatus;
    mapping(address => mapping(uint256 => uint256)) indexFixedSaleNFT;

    mapping(address => mapping(uint256 => Auction)) nftContractAuctionSale;
    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public userBidPriceOnNFT;
    mapping(address => mapping(uint256 => uint256)) indexAuctionSaleNFT;

    mapping(address => mapping(address => mapping(uint256 => uint256)))
        public inSale;
    mapping(address => mapping(uint256 => uint256)) totalAmountInSale;

    SaleInfo[] fixedSaleNFT;
    SaleInfo[] auctionSaleNFT;

    bytes4 public constant IID_IERC1155 = type(IERC1155).interfaceId;

    event NftFixedSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 amount,
        uint256 tokenId,
        uint256 salePrice,
        uint256 timeOfSale
    );

    event CancelNftFixedSale(
        address nftContractAddress,
        address nftSeller,
        uint256 tokenId
    );

    event NftFixedSalePriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 updateSalePrice
    );

    event NftBuyFromFixedSale(
        address nftContractAddress,
        address nftBuyer,
        uint256 amount,
        uint256 tokenId,
        uint256 nftBuyPrice
    );

    event NftAuctionSale(
        address nftContractAddress,
        address nftSeller,
        address erc20,
        uint256 tokenId,
        uint256 auctionStart,
        uint256 auctionEnd,
        uint256 minPrice
    );

    event NftBidPrice(
        address nftContractAddress,
        uint256 tokenId,
        uint256 bidPrice,
        address nftBidder
    );

    event NftAuctionBidPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 finalBidPrice,
        address nftBidder
    );

    event CancelNftAuctionSale(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller
    );

    event NftBuyNowPriceUpdate(
        address nftContractAddress,
        uint256 tokenId,
        uint256 updateBuyNowPrice,
        address nftOwner
    );

    event NftAuctionSettle(
        address nftContractAddress,
        uint256 tokenId,
        address nftHighestBidder,
        uint256 nftHighestBid,
        address nftSeller
    );

    event withdrawNftBid(
        address nftContractAddress,
        uint256 tokenId,
        address bidClaimer
    );

    modifier isAmountAvaible(
        address _nftContractAddress,
        uint256 _amount,
        uint256 _tokenId
    ) {
        require(
            isAmountExist(_nftContractAddress, _tokenId, _amount),
            "copies not enough"
        );
        _;
    }

    modifier isNftAlreadyInSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 0,
            "Nft already in sale"
        );
        _;
    }

    modifier isNftInFixedSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 1,
            "Nft not in fixed sale"
        );
        _;
    }

    modifier isSaleStartByOwner(address _nftContractAddress, uint256 _tokenId) {
        require(
            _ownerOf(_nftContractAddress, _tokenId),
            "You are not nft owner"
        );
        _;
    }

    modifier isSaleResetByOwner(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) {
        require(
            msg.sender ==
                nftContractFixedSale[_nftContractAddress][_tokenId][_amount]
                    .nftSeller,
            "You are not nft owner"
        );
        _;
    }

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

    modifier buyPriceMeetSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _buyPrice,
        uint256 _amount,
        uint256 _leftAmount
    ) {
        require(
            _buyPrice >=
                (
                    nftContractFixedSale[_nftContractAddress][_tokenId][_amount]
                        .salePrice
                ) *
                    _leftAmount,
            "buy Price not enough"
        );
        _;
    }

    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price cannot be 0");
        _;
    }

    modifier isNftInAuctionSale(address _nftContractAddress, uint256 _tokenId) {
        require(
            nftSaleStatus[_nftContractAddress][_tokenId] == 2,
            "Nft not in auction sale"
        );
        _;
    }

    modifier isNftAmountInSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) {
        require(
            inSale[msg.sender][_nftContractAddress][_tokenId] >= _amount,
            "amount not in sale"
        );
        _;
    }

    modifier isAuctionOver(address _nftContractAddress, uint256 _tokenId) {
        require(
            block.timestamp >
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .auctionEnd,
            "Auction not end"
        );
        _;
    }

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

    modifier isAuctionOngoing(address _nftContractAddress, uint256 _tokenId) {
        require(
            block.timestamp <
                nftContractAuctionSale[_nftContractAddress][_tokenId]
                    .auctionEnd,
            "Auction end"
        );
        _;
    }

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
        isContractApprove(_nftContractAddress, _tokenId)
        isAmountAvaible(_nftContractAddress, _amount, _tokenId)
        priceGreaterThanZero(_salePrice)
    {
        address nftContractAddress = _nftContractAddress;
        address erc20 = _erc20;
        uint256 tokenID = _tokenId;
        uint256 amount = _amount;
        uint256 salePrice = _salePrice;
        bytes memory data = _data;

        nftContractFixedSale[nftContractAddress][tokenID][amount] = FixedSale(
            msg.sender,
            address(0),
            erc20,
            amount,
            salePrice
        );

        indexFixedSaleNFT[nftContractAddress][tokenID] = fixedSaleNFT.length;
        fixedSaleNFT.push(SaleInfo(nftContractAddress, tokenID));

        IERC1155(nftContractAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID,
            amount,
            data
        );

        inSale[msg.sender][nftContractAddress][tokenID] += amount;
        totalAmountInSale[nftContractAddress][tokenID] += amount;

        emit NftFixedSale(
            nftContractAddress,
            msg.sender,
            erc20,
            tokenID,
            amount,
            salePrice,
            block.timestamp
        );
    }

    function cancelFixedsale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _leftAmount,
        bytes memory _data
    )
        external
        isNftAmountInSale(_nftContractAddress, _tokenId, _amount)
        isSaleResetByOwner(_nftContractAddress, _tokenId, _amount)
    {
        require(
            nftContractFixedSale[_nftContractAddress][_tokenId][_amount]
                .amount >= _leftAmount,
            "nft amount not exist"
        );
        address nftSeller = nftContractFixedSale[_nftContractAddress][_tokenId][
            _amount
        ].nftSeller;
        IERC1155(_nftContractAddress).safeTransferFrom(
            address(this),
            nftSeller,
            _tokenId,
            _leftAmount,
            _data
        );

        nftContractFixedSale[_nftContractAddress][_tokenId][_amount]
            .amount -= _leftAmount;

        inSale[msg.sender][_nftContractAddress][_tokenId] -= _leftAmount;
        totalAmountInSale[_nftContractAddress][_tokenId] -= _leftAmount;

        if (totalAmountInSale[_nftContractAddress][_tokenId] == 0) {
            delete fixedSaleNFT[
                (indexFixedSaleNFT[_nftContractAddress][_tokenId])
            ];
        }

        emit CancelNftFixedSale(_nftContractAddress, msg.sender, _tokenId);
    }

    function updateFixedSalePrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateSalePrice,
        uint256 _amount
    )
        external
        isNftAmountInSale(_nftContractAddress, _tokenId, _amount)
        isSaleResetByOwner(_nftContractAddress, _tokenId, _amount)
        priceGreaterThanZero(_updateSalePrice)
    {
        require(
            nftContractFixedSale[_nftContractAddress][_tokenId][_amount]
                .salePrice != 0,
            "not exist"
        );

        nftContractFixedSale[_nftContractAddress][_tokenId][_amount]
            .salePrice = _updateSalePrice;

        emit NftFixedSalePriceUpdated(
            _nftContractAddress,
            _tokenId,
            _updateSalePrice
        );
    }

    function buyFromFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _nftAmount,
        uint256 _leftAmount,
        bytes memory _data
    )
        external
        payable
        priceGreaterThanZero(_amount)
        buyPriceMeetSalePrice(
            _nftContractAddress,
            _tokenId,
            _amount,
            _nftAmount,
            _leftAmount
        )
    {
        require(
            nftContractFixedSale[_nftContractAddress][_tokenId][_nftAmount]
                .amount >= _leftAmount,
            "nft amount not exist"
        );
        require(_nftAmount != 0, "non-zero value or amount not greater");

        require(
            nftContractFixedSale[_nftContractAddress][_tokenId][_nftAmount]
                .salePrice != 0,
            "not exist"
        );

        address nftContractAddress = _nftContractAddress;
        uint256 tokenID = _tokenId;
        uint256 nftAmount = _nftAmount;
        bytes memory data = _data;
        uint256 amount = _amount;
        uint256 leftAmount = _leftAmount;

        IERC1155(nftContractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenID,
            leftAmount,
            data
        );

        nftContractFixedSale[nftContractAddress][tokenID][nftAmount]
            .amount -= leftAmount;

        _checkFixedSale(nftContractAddress, tokenID, nftAmount, leftAmount);

        _isTokenOrCoin(
            nftContractFixedSale[nftContractAddress][tokenID][nftAmount]
                .nftSeller,
            nftContractFixedSale[nftContractAddress][tokenID][nftAmount].erc20,
            nftContractFixedSale[nftContractAddress][tokenID][nftAmount]
                .salePrice * leftAmount,
            false
        );

        emit NftBuyFromFixedSale(
            nftContractAddress,
            msg.sender,
            tokenID,
            amount,
            nftAmount
        );
    }

    // NFT AUCTION SALE

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
        require(_nftAmount != 0, "zero invalid");

        address nftContractAddress = _nftContractAddress;
        address erc20 = _erc20;
        uint256 tokenId = _tokenId;
        uint256 auctionStart = _auctionStart;
        uint256 auctionEnd = _auctionEnd;
        uint256 minPrice = _minPrice;
        uint256 nftAmount = _nftAmount;
        bytes memory data = _data;

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

        indexAuctionSaleNFT[nftContractAddress][tokenId] = auctionSaleNFT
            .length;
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

    function updateTheBidPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _updateBidPrice
    )
        external
        payable
        isNftInAuctionSale(_nftContractAddress, _tokenId)
        isAuctionOngoing(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_updateBidPrice)
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

    function getNftAuctionSaleDetails(
        address _nftContractAddress,
        uint256 _tokenId
    ) external view returns (Auction memory) {
        return nftContractAuctionSale[_nftContractAddress][_tokenId];
    }

    function getAuctionSaleNFT() external view returns (SaleInfo[] memory) {
        return auctionSaleNFT;
    }

    function getFixedSaleNFT() external view returns (SaleInfo[] memory) {
        return fixedSaleNFT;
    }

    function getFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (FixedSale memory) {
        return nftContractFixedSale[_nftContractAddress][_tokenId][_amount];
    }

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external pure returns (bytes4) {
        return 0xbc197c81;
    }

    function _isTokenOrCoin(
        address _nftSeller,
        address _erc20,
        uint256 _buyAmount,
        bool auction
    ) internal {
        if (_erc20 != address(0)) {
            if (auction) {
                IERC20(_erc20).transfer(_nftSeller, _buyAmount);
            } else {
                _tokenAmountTransfer(_nftSeller, _erc20, _buyAmount);
            }
        } else {
            _nativeAmountTransfer(_nftSeller, _buyAmount);
        }
    }

    function isAmountExist(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) internal view returns (bool) {
        uint256 _balance = IERC1155(_nftContractAddress).balanceOf(
            msg.sender,
            _tokenId
        );
        return _balance >= _amount ? true : false;
    }

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

    function _nativeAmountTransfer(address _nftSeller, uint256 _buyAmount)
        internal
    {
        (bool success, ) = _nftSeller.call{value: _buyAmount}("");
        require(success, "refund failed");
    }

    function _checkFixedSale(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _nftAmount,
        uint256 _leftAmount
    ) internal {
        address nftSeller = nftContractFixedSale[_nftContractAddress][_tokenId][
            _nftAmount
        ].nftSeller;
        inSale[nftSeller][_nftContractAddress][_tokenId] -= _leftAmount;
        totalAmountInSale[_nftContractAddress][_tokenId] -= _leftAmount;

        if (totalAmountInSale[_nftContractAddress][_tokenId] == 0) {
            delete fixedSaleNFT[
                (indexFixedSaleNFT[_nftContractAddress][_tokenId])
            ];
        }

        nftContractFixedSale[_nftContractAddress][_tokenId][_nftAmount]
            .nftBuyer = msg.sender;
    }

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
            _bidPrice,
            true
        );
    }

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
