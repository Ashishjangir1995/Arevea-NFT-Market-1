# AREVEA-NFT Marketplace Documentation
## Table of contents
### Brief summary decentralized marketplace 
### Arevea Token and NFT Contract .sol files details
### Smart Contract Functionality in brief
### Disclaimer 


# Arevea-NFT-Market Place 
The Arevea marketplace mainly focuses upon the utilization of the Etherium network namely ERC721 for single NFT and ERC1155 for multiple NFT. This is also compatibleble with EVM aka ethereum virtual machine and innumerable other smart chain networks such as 1. Rinkeby Network 2. Ropsten amonst others. The main purpose of this project is to provide a Blockchain based online market place for the sale and purchase of NFT's both Single and Multiple using AREVEA tokens(ERC20,Criptocurrency). Arevea tokens may also be utilized for other transactions Thus we may conclude that there is a large scope of growth present permitting us to move forward with this initiation.  

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

| 1) Srial no                         | contract        | function                               | parameter                                                                                                            |
| ----------------------------------- | --------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| 1                                   | 721 SINGLE-NFT | approve                                | 1st - Contract adress , 2nd tokenid                                                                                  |
|                                     |                 | Burn                                   | tokenid                                                                                                              |
|                                     |                 | createNFT                              | 1st -TokenURI , 2nd Fee                                                                                              |
|                                     |                 | safeTransferFrom                       | 1st From -address 2nd -To Address 3rd -tokenid                                                                       |
|                                     |                 | safeTransferFrom                       | 1st From -address 2nd -To Address 3rd -tokenid 4th data                                                              |
|                                     |                 | setApproveforAll                       | 1st - operator adddress ,2nd Approve bool                                                                            |
|                                     |                 | setBaseURI                             | 1st Base uri                                                                                                         |
|                                     |                 | TransferFrom                           | 1st From -address 2nd -To Address 3rd -tokenid                                                                       |
|                                     |                 | TransferOwnsership                     | New owner address                                                                                                    |
|                                     |                 |                                        |                                                                                                                      |
|                                     |                 | Balance of address of owner and others |
|                                     |                 | GetApproved                            | tokenid                                                                                                              |
|                                     |                 | GetCreator                             | tokenid                                                                                                              |
|                                     |                 | ISApproveforAll                        | 1st - operator adddress ,2nd Approve bool                                                                            |
|                                     |                 | ownerof                                | tokenid                                                                                                              |
|                                     |                 | royaltyfee                             | tokenid                                                                                                              |
|                                     |                 | supportsinterface                      | byres4                                                                                                               |
|                                     |                 | tokenbyIndex                           | index                                                                                                                |
|                                     |                 | tokenbyownerbyindex                    | owner index                                                                                                          |
|                                     |                 | tokenURI                               | tokenid                                                                                                              |
|                                     |                 |                                        |                                                                                                                      |
| 2                                   | 1155 MULTINFT      | burn                                   | 1)tokenid 2) supply in unit                                                                                          |
|                                     |                 | burnBatch                              | 1)tokenid 2) amount                                                                                                  |
|                                     |                 | createMultiple                         | 1)uri2)Supplier3)Fee in amount                                                                                       |
|                                     |                 | safeBatchTransferFrom                  | 1)from address2)to address3) tokenid 4)amount 5)data                                                                 |
|                                     |                 | safeBatchTransferFrom                  | 1)from address2)to address3) tokenid 4)amount 5)data                                                                 |
|                                     |                 | setApproveforAll                       | 1st - operator adddress ,2nd Approve bool                                                                            |
|                                     |                 | setBaseURI                             | baseURI                                                                                                              |
|                                     |                 | TransferOwnsership                     | New owner address                                                                                                    |
|                                     |                 | balanceOf                              | 1)account 2) tokenid                                                                                                 |
|                                     |                 | balanceOfBatch                         | 1)accunts 2)ids                                                                                                      |
|                                     |                 | getCreator                             | tokenid                                                                                                              |
|                                     |                 | ISApproveforAll                        |                                                                                                                      |
|                                     |                 | Royaltyfee                             | tokenid                                                                                                              |
|                                     |                 | supportsInterface                      | bytes                                                                                                                |
|                                     |                 | tokenURI                               | tokenid                                                                                                              |
|                                     |                 |                                        |                                                                                                                      |
| 3                                   | ERC20           | approve                                | 1)spender address 2) amount                                                                                          |
|                                     |                 | burn                                   | 1)amount                                                                                                             |
|                                     |                 | burnfrom                               | 1)address2)amount                                                                                                    |
|                                     |                 | decreaseAllowance                      | 1)spender address 2) substractedValue                                                                                |
|                                     |                 | increaseAllowance                      | 1)spender2)AddedValue                                                                                                |
|                                     |                 | mint                                   | 1)account 2)amount                                                                                                   |
|                                     |                 | renounce owner                         | to cancel ownership                                                                                                  |
|                                     |                 | transfer                               | 1)to address 2)amount                                                                                                |
|                                     |                 | setApproveforAll                       | 1st - operator adddress ,2nd Approve bool                                                                            |
|                                     |                 | transferOwnership                      | New owner address                                                                                                    |
|                                     |                 | allowance                              | 1)owner 2)spender                                                                                                    |
|                                     |                 | balancof                               | accont address                                                                                                       |
| 4                                   | NFT Market 721  | buyFromFixedSale                       | 1)nft contract address 2)tokenid 3)amount                                                                            |
|                                     |                 | cancelFixedsale                        | 1)nft contract address 2)tokenid                                                                                     |
|                                     |                 | nftFixedSale                           | 1)nft contract address 2)erc20 3)tokenid 4)saleprice                                                                 |
|                                     |                 | updateFixedSalePrice                   | 1)nft contact address 2)token id 3) updated sale price                                                               |
|                                     |                 | nftSaleStatus                          | 1)address2)amount                                                                                                    |
|                                     |                 | onERC721Received                       | 1)address2)address3)unit4)bytes                                                                                      |
|                                     |                 | \_cancelAuctionSale                    | 1)\_nftContractAddress: 2) \_tokenId:                                                                                |
|                                     |                 | createNftAuctionSale                   | 1) \_nftContractAddress: 2) \_erc20: Address 3)\_tokenId: 4)\_auctionStart5) \_auctionEnd:<br>6\_minPrice:<br><br>   |
|                                     |                 | makeBid                                | 1)\_nftContractAddress:2) \_tokenId:<br>3)\_bidPrice                                                                 |
|                                     |                 | settleAuction                          |      1)_nftContractAddress 2)_tokenId:                                                   | 
|   |                 | updateTheBidPrice        | 1)\_nftContractAddress: 2) \_tokenId:3) \_updateBidPrice:<br>                                      |                                                             |  |  |  |  |  |  |  |  |  |
| - | --------------- | ------------------------ | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |  |  |  |  |  |  |  |  |  |
|   |                 | withdrawBid              | 1)\_nftContractAddress: 2) \_tokenId:<br>                                                          |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | getFixedSale             | 1) \_nftContractAddress:2)\_tokenId:<br>                                                           |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | getNftAuctionSaleDetails | 1)\_nftContractAddress2)\_tokenId:                                                                 |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | nftSaleStatus            | 1)Address 2)units                                                                                  |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | userBidPriceOnNFT        | 1)Address2)units3)Address                                                                          |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 |                          |                                                                                                    |                                                             |  |  |  |  |  |  |  |  |  |
| 5 | NFT Market 1155 | buyFromFixedSale         | 1)nft contract address 2)tokenid 3)amount 4)NftAmount5)data                                        |                                                             |  |  |  |  |  |  |  |  |
|   |                 | cancelFixedsale          | 1)nft contract address 2)tokenid 3)amount 4))data                                                  |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | nftFixedSale             | 1)nft contract address 2)ERC20 3)tokenid 4)amount 5)SalePrice5)data                                |                                                             |  |  |  |  |  |  |  |
|   |                 | updateFixedSalePrice     | 1)nft contact address 2)token id 3) updated sale price                                             |                                                             |  |  |  |  |  |  |  |  |
|   |                 | nftSaleStatus            | 1)address2)amount                                                                                  |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | onERC721Received         | 1)address2)address3)unit4)bytes                                                                    |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | \_cancelAuctionSale      | 1)\_nftContractAddress: 2) \_tokenId:                                                              |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | createNftAuctionSale     | 1)nft contract address 2)ERC20 3)Tokenid 4)auctionStart 5)AuctionEnd 6)MinPrice 7)Nftamount 8)data | 1)nft contract address 2)tokenid 3)amount 4)NftAmount5)data |
|   |                 | makeBid                  | 1)Nft contract address 2)Tokenid 2)BidPrice                                                        |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | settleAuction            | 1)\_nftContractAddress 2)\_tokenId:                                                                |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | updateTheBidPrice        | 1)nft contract address 2)tokenid 3)updateBid price                                                 |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 |                          |                                                                                                    |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | withdrawBid              | 1)Nft Contract address 2)Token id                                                                  |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | getFixedSale             |                                                                                                    |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | getNftAuctionSaleDetails | 1)\_nftContractAddress2)\_tokenId:                                                                 |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | nftSaleStatus            | 1)Address 2)units                                                                                  |                                                             |  |  |  |  |  |  |  |  |  |
|   | 1155            | userBidPriceOnNFT        | 1)Address2)units3)Address                                                                          |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | IID\_IERC1155            |                                                                                                    |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | isERC1155                | \_nftContractAddress:                                                                              |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | onERC1155BatchReceived   | 1)Operator address 2) from address 3)ids 4\_values 5)data bytes                                    |                                                             |  |  |  |  |  |  |  |  |  |
|   |                 | onERC1155Received        | 1)Operator address 2) from address 3)ids 4\_values 5)data bytes                                    |                                                             |  |  |  |  |  |  |  |  |  |
| Lazy mint | Approve               | 1)address 2toeknid                                   |
| --------- | --------------------- | ---------------------------------------------------- |
|           | grantRole             | 1)role 2)Account                                     |
|           | redeem                | 1)Reedeemer 2)v units 3)r bytes 4)s bytes 5) voucher |
|           | renounceRole          | 1) role 2) account address                           |
|           | revokeRole            | 1) role 2) account address                           |
|           | safeTransferFrom      | 1)from address 2) to address 3)tokenid               |
|           | safeTransferFrom      | 1)from address 2) to address 3)tokenid 4)data        |
|           | setApproveforAll      | 1st - operator adddress ,2nd Approve bool            |
|           | TransferFrom          | 1st From -address 2nd -To Address 3rd -tokenid       |
|           | withdraw              |                                                      |
|           | available to withdraw |                                                      |
|           | balanceOf             | owner address                                        |
|           | chainid               |                                                      |
|           | Default admin role    |                                                      |
|           | get approved          | token id                                             |
|           | get chain id          |                                                      |
|           | getRoleAdimin         | role                                                 |
|           | hasRole               | 1) role 2) account address                           |
|           | ISApproveforAll       | 1)owner 2)operator                                   |
|           | Minter role           |                                                      |
|           | Owner of              | token id                                             |
|           | supportsinferface     | interfaceId                                          |
|           | tokenuri              | token id                                             |

Sources and Address:<br>

AreveaToken, SingleNFT &amp; Multiple NFT with Market and Bid functions 
link to Arevea ERC20 REadme - https://github.com/Tapas15/ERC20/blob/main/README.md

json Market file- link https://github.com/Tapas15/Arevea-NFT-Market/blob/main/MULTI-NFT/contracts/artifacts/MarketPlace.json

market place link - https://github.com/Tapas15/Arevea-NFT-Market/blob/main/MULTI-NFT/contracts/MarketPlace.sol

market place contract link- https://rinkeby.etherscan.io/address/0x92dcd49991cd55ab039abd077e0f97573378d89d

market contract address- 0x92dCD49991CD55ab039aBd077e0F97573378D89D


### Disclaimer 
