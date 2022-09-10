//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;
pragma abicoder v2; // required to accept structs as function parameters


import "@openzeppelin/contracts@4.4.1/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.1/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.1/utils/Counters.sol";
import "@openzeppelin/contracts@4.4.1/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts@4.4.1/utils/cryptography/draft-EIP712.sol";

contract Mytoken is ERC721 , EIP712 ,Ownable{
using Counters for Counters.Counter;

      Counters.Counter private _tokenIdCounter;
      string private constant SIGNIN_DOMAIN = "WEB3CLUB";
      string private constant SIGNATURE_VERSION = "1";

      constructor() ERC721("Mytoken","MTK")EIP712(SIGNIN_DOMAIN,SIGNATURE_VERSION){}
      
      function safeMint(address to,string memory name, uint256 id, bytes memory signature) public {
        require(check(id,name,signature) == owner(),"Voucher invalid");
          _tokenIdCounter.increment();
          uint256 tokenId = _tokenIdCounter.current();
          _safeMint(to, tokenId);
      }

      function check(uint256 id,string memory name, bytes memory signature) public view returns(address){
          return _veryfy(id,name,signature);
      }


       function  _veryfy(uint256 id, string memory name, bytes memory signature) internal  view returns(address){
          bytes32 digest = _hash(id,name);
          return ECDSA.recover(digest,signature);
      }

      function  _hash(uint256 id, string memory name) internal  view returns(bytes32){
      return _hashTypedDataV4(keccak256(abi.encode(
          keccak256("Web3Struct(uint256 id, string name)"),
          id,
          keccak256(bytes(name))
      )));
      
      }


}



