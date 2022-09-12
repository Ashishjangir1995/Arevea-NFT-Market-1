// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) 

pragma solidity ^0.8.4;

import "./ERC721.sol";
/// @title implementation of nft single contract 
/// @dev its nun-fungible token standard including ERC-721 standard
contract NFT is ERC721 {
    //Token counter variable 
    uint256 public tokenCounter;
    //Token owner address
    address public owner;
    //Mapping usedNonce as approval
    mapping(uint256 => bool) private usedNonce;
    //Mappping tokenURIs as approval
    mapping(string => bool) private tokenURIs;

    //event ownership transfered 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }
    // inilitialized constructor with token name and token symbol
    constructor (string memory tokenName, string memory tokenSymbol) ERC721 (tokenName, tokenSymbol){
        tokenCounter = 1;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
     /** @dev change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */  
    function transferOwnership(address newOwner) external onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
        return true;
    }

    /** @dev verify the tokenURI that should be verified by owner of the contract.
        *requirements: signer must be owner of the contract
        @param tokenURI string memory URI of token to be minted.
        @param sign struct combination of uint8, bytes32, bytes 32 are v, r, s.
        note : sign value must be in the order of v, r, s.

    */


    function verifySign(string memory tokenURI, address caller, Sign memory sign) internal view {
        bytes32 hash = keccak256(abi.encodePacked(this, caller, tokenURI, sign.nonce));
        require(owner == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s), "Owner sign verification failed");
    }

    
    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param tokenURI string memory URI of the token to be minted.
     * @param fee uint256 royalty of the token to be minted.
     */

    function createNFT(string memory tokenURI, uint256 fee) external returns (uint256) {
      //  require(!usedNonce[sign.nonce], "Nonce : Invalid Nonce");
        require(!tokenURIs[tokenURI],"Minting: Duplicate Minting");
      //  usedNonce[sign.nonce] = true;
        uint256 newItemId = tokenCounter;
      //  verifySign(tokenURI, msg.sender, sign);
        _safeMint(msg.sender, newItemId, fee);
        _setTokenURI(newItemId, tokenURI);
        tokenURIs[tokenURI] = true;
        tokenCounter = tokenCounter + 1;
        return newItemId;
    }
    //function to setBaseURI  
    function setBaseURI(string memory _baseURI) external onlyOwner{
        _setBaseURI(_baseURI);
    }
    //function to Brun nfts    
    function burn(uint256 tokenId) external {
        require(_exists(tokenId), "ERC721: nonexistent token");
        _burn(tokenId);
    }
}