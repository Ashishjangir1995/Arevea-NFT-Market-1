// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) 

pragma solidity ^0.8.4;

import "./ERC1155.sol";
/// @title implementation of nft multiple contract 
/// @dev its nun-fungible token standard including ERC-1155 standard
contract MultipleNFT is ERC1155 {
    //Itemid variable  
    uint256 newItemId = 1;
     //Token owner address
    address public owner;
     //Mapping usedNonce as approval
    mapping(uint256 => bool) private usedNonce;
    //event ownership transfered 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }
    // inilitialized constructor with token name and token symbol
    constructor (string memory name, string memory symbol) ERC1155 (name, symbol) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /** @dev change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */    

    function transferOwnership(address newOwner) public onlyOwner returns(bool){
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner,newOwner);
        owner = newOwner;
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

    function createMultiple(string memory uri, uint256 supply, uint256 fee)  public {
        //require(!usedNonce[sign.nonce],"Nonce : Invalid Nonce");
        //usedNonce[sign.nonce] = true;
        //verifySign(uri, msg.sender, sign);
        _mint(newItemId, supply, uri,fee);
        newItemId = newItemId+1;

    }
    //function to setBaseURI  
    function setBaseURI(string memory _baseURI) public onlyOwner{
         _setTokenURIPrefix(_baseURI);
    }
    //function to Brun nfts  
    function burn(uint256 tokenId, uint256 supply) public {
        _burn(msg.sender, tokenId, supply);
    }
    //function to BrunBatch nfts token   
    function burnBatch(uint256[] memory tokenIds, uint256[] memory amounts) public {
        _burnBatch(msg.sender, tokenIds, amounts);
    }
    //function to MintBatch nfts token
    function mintBatch(address to, uint256[] memory tokenIds, uint256[] memory amounts, bytes memory data) public {
        _mintBatch(msg.sender, tokenIds, amounts, data);
    }


    
}