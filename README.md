# AREVEA-NFT Marketplace Documentation
## Table of contents
### Brief summary decentralized marketplace 
### Arevea Token and NFT Contract .sol files details
### Smart Contract Functionality in brief
### Disclaimer 


# Arevea-NFT-Market Place 
This documentation of Arevea marketplace in Etherium network ERC721 and ERC1155 multiple token standard.it is also compatable on EVM and other smart chain network. The purpose of this project is to make a online market place is to purchase and sell of NFT - Single and Multiple using AREVEA token and make Voucher related transactions, so that this market place project is initated.  

### Brief summary decentralized marketplace 
NFT or Non-Fungible Tokens are cryptographic assets that are created on blockchain technology, and have unique identification codes and meta-data, which makes them distinguishable, distinct, and completely unique. 
NFTs can be traded with other NFTs or sold/bought via the NFT marketplace, which is a decentralized platform.
This marketplace is like an eCommerce platform, say Amazon or eBay where different products are listed by sellers, and buyers can buy them.

### Arevea Token and NFT Contract .sol files details
Structure- 
All contracts and tests are in the NFT-Contracts folder. There are multiple implementations and you can select in between 

NFT.sol: This is the base ERC-721 token implementation (with support for ERC-165).

MultipleNFT.sol :This is the base ERC1155 token implementation for multiple copies and multiple at same time with reduced gas fees. 

finalMarket_single.sol is the marketplace for Single NFT for buy sell and auction in marketplace 

final_market_Multi_nft.sol for Multiple nft buy sell and auction in multinft marketplace

lazymint.sol is for lazyminting to NFT for future transaction to pass the burden from creater to purchase (gass fees)

### Smart Contract Functionality in brief
From the Above Smart contract one is for Single NFT and another is for Multiple NFT , from single NFT we can create Single in Blockchain and that can be buy  sell and trade in NFT market place, for creating single nft in one id is excess amount of gas use so that using one id we can have multiple nfts at one plase , multiple has 2 features one is creating multiple copies and another is creating different items under one id as multiple is called as multiple batch of different nft  at one place. 

Both Single and Multiple has Separate Marketplace to buy sell and trade nft in marketplace. 

Lazy minting is different where the NFT is once minted all creatrion and transaction cost of Blockchain is burn by the buyer itself. 

| Category  | Attribute              | Description                   | Values                                                                                      |
| --------- | ---------------------- | ----------------------------- | ------------------------------------------------------------------------------------------- |
| font      | `data-f-name`          | Font name                     | "Calibri" ,"Arial" etc.                                                                     |
|           | `data-f-sz`            | Font size                     | "11" // font size in points                                                                 |
|           | `data-f-color`         | Font color                    | A hex ARGB value. Eg: FFFFOOOO for opaque red.                                              |
|           | `data-f-bold`          | Bold                          | `true` or `false`                                                                           |
|           | `data-f-italic`        | Italic                        | `true` or `false`                                                                           |
|           | `data-underline`       | Underline                     | `true` or `false`                                                                           |
|           | `data-f-strike`        | Strike                        | `true` or `false`                                                                           |
| Alignment | `data-a-h`             | Horizontal alignment          | `left`, `center`, `right`, `fill`, `justify`, `centerContinuous`, `distributed`             |
|           | `data-a-v`             | Vertical alignment            | `bottom`, `middle`, `top`, `distributed`, `justify`                                         |
|           | `data-a-wrap`          | Wrap text                     | `true` or `false`                                                                           |
|           | `data-a-indent`        | Indent                        | Integer                                                                                     |
|           | `data-a-rtl`           | Text direction: Right to Left | `true` or `false`                                                                           |
|           | `data-a-text-rotation` | Text rotation                 | 0 to 90                                                                                     |
|           |                        |                               | -1 to -90                                                                                   |
|           |                        |                               | vertical                                                                                    |
| Border    | `data-b-a-s`           | Border style (all borders)    | Refer `BORDER_STYLES`                                                                       |
|           | `data-b-t-s`           | Border top style              | Refer `BORDER_STYLES`                                                                       |
|           | `data-b-b-s`           | Border bottom style           | Refer `BORDER_STYLES`                                                                       |
|           | `data-b-l-s`           | Border left style             | Refer `BORDER_STYLES`                                                                       |
|           | `data-b-r-s`           | Border right style            | Refer `BORDER_STYLES`                                                                       |
|           | `data-b-a-c`           | Border color (all borders)    | A hex ARGB value. Eg: FFFFOOOO for opaque red.                                              |
|           | `data-b-t-c`           | Border top color              | A hex ARGB value.                                                                           |
|           | `data-b-b-c`           | Border bottom color           | A hex ARGB value.                                                                           |
|           | `data-b-l-c`           | Border left color             | A hex ARGB value.                                                                           |
|           | `data-b-r-c`           | Border right color            | A hex ARGB value.                                                                           |
| Fill      | `data-fill-color`      | Cell background color         | A hex ARGB value.                                                                           |
| numFmt    | `data-num-fmt`         | Number Format                 | "0"                                                                                         |
|           |                        |                               | "0.00%"                                                                                     |
|           |                        |                               | "0.0%" // string specifying a custom format                                                 |
|           |                        |                               | "0.00%;\\(0.00%\\);\\-;@" // string specifying a custom format, escaping special characters |


Sources and Address:<br>

AreveaToken, SingleNFT &amp; Multiple NFT with Market and Bid functions 
link to Arevea ERC20 REadme - https://github.com/Tapas15/ERC20/blob/main/README.md

json Market file- link https://github.com/Tapas15/Arevea-NFT-Market/blob/main/MULTI-NFT/contracts/artifacts/MarketPlace.json

market place link - https://github.com/Tapas15/Arevea-NFT-Market/blob/main/MULTI-NFT/contracts/MarketPlace.sol

market place contract link- https://rinkeby.etherscan.io/address/0x92dcd49991cd55ab039abd077e0f97573378d89d

market contract address- 0x92dCD49991CD55ab039aBd077e0F97573378D89D


### Disclaimer 
