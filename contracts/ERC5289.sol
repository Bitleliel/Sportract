// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5289Library.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";




/*contract ImageInfo {
   mapping (address=>Image[]) private images;
   struct Image {
      string imageHash;
      string ipfsInfo;
   }
   function uploadImage (string hash, string ipfs) public {
       images[msg.sender].push(Image(hash,ipfs)); //
   }
}

contract ImageHash is ERC1155 {
    constructor () ERC1155 ("URI") {}
}*/


contract ERC5289 is IERC5289Library {


    struct Document {

        address signer;
        
        uint64 timeStamp;

        string ipfsuri;
    }

    mapping (uint16 => Document[]) private documents;

    mapping (address => uint16) private signers;

    

    constructor () {

    }

    
    /**
     *  @dev 
     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC5289Library).interfaceId; // || super.supportsInterface(interfaceId);

    }

    /// @notice An immutable link to the legal document (RECOMMENDED to be hosted on IPFS). This MUST use a common file format, such as PDF, HTML, TeX, or Markdown.
    
    function legalDocument(uint16 documentId) external view returns (string memory) {
       
        Document[] storage d = documents[documentId];

        return d[documentId].ipfsuri;

        //return documents[documentId].ipfsuri;
       


    }
    
    /// @notice Returns whether or not the given user signed the document.
    
    function documentSigned(address user, uint16 documentId) external view returns (bool signed) {
        
        Document[] storage d = documents[documentId];

        if (d[documentId].signer == user) return true;
        
        else return false;

    }

    /// @notice Returns when the the given user signed the document.
    /// @dev If the user has not signed the document, the timestamp may be anything.
    
    function documentSignedAt(address user, uint16 documentId) external view returns (uint64 timestamp) {

        Document[] storage d = documents[documentId];

        if (d[documentId].signer == user) return d[documentId].timeStamp;

        else return 0;

    }
    

    /// @notice Sign a document
    /// @dev This MUST be validated by the smart contract. This MUST emit DocumentSigned or throw.
    function signDocument(address signer, uint16 documentId) external {
        
        documents[documentId].push(Document(signer, block.timestamp, "noURI"));

        signers[signer] = documentId;

        emit DocumentSigned(signer, documentId);
    }



    function signDocument(address signer, uint16 documentId, string memory uri) external {

        documents[documentId].push(Document(signer, block.timestamp, uri));

        signers[signer] = documentId;
        
        emit DocumentSignedAt(signer, documentId, uri);
    }


    
    /// @notice Emitted when signDocument accepts 3 parameters

    event DocumentSignedAt(address indexed signer, uint16 indexed documentId, string uri);
}