// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5289Library.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @dev 
 *
 *
 *
 *
 */


contract ERC5289 is IERC5289Library {

    /**
     * @dev 
     *
     *
     *
     *
     */


    struct Document {

        address signer;
        
        uint timeStamp;

        string ipfsuri;
    }

    mapping (uint16 => Document) private documents; //prev (uint => Document[])

    mapping (address => uint16) private signers;

    
    /**
     * @dev 
     *
     *
     *
     *
     */
    
    constructor () {

    }

    
    /**
     * @dev
     *
     *
     * 
     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC5289Library).interfaceId; // || super.supportsInterface(interfaceId);

    }

    /**
     * @dev
     *
     *
     *
     */

    /// @notice An immutable link to the legal document (RECOMMENDED to be hosted on IPFS). This MUST use a common file format, such as PDF, HTML, TeX, or Markdown.
    
    function legalDocument(uint16 documentId) public view returns (string calldata) {
       
        Document storage d = documents[documentId];

        return d.ipfsuri;

        //return documents[documentId].ipfsuri;
       


    }

    /**
     * @dev
     *
     *
     *
     */
    
    /// @notice Returns whether or not the given user signed the document.
    
    function documentSigned(address user, uint16 documentId) public view returns (bool signed) {
        
        Document storage d = documents[documentId]; //prev Document[] storage d = ....

        if (d.signer == user) return true;
        
        else return false;

    }

    /// @notice Returns when the the given user signed the document.
    /// @dev If the user has not signed the document, the timestamp may be anything.
    
    /**
     * @dev
     *
     *
     */
     
    function documentSignedAt(address user, uint16 documentId) public view returns (uint timestamp) {

        //if (documents[documentId].signer == user) return documents[documentId].timeStamp;


        Document storage d = documents[documentId];

        if (d.signer == user) return d.timeStamp;

        else return 0;

    }

    function signDocument(address signer, uint16 documentId, string calldata ipfsuri) public {

        Document memory d = Document(signer, block.timestamp, ipfsuri);

        documents[documentId] = d;

        signers[signer] = documentId;

        emit DocumentSigned(signer, documentId);
    }
    

    /// @notice Sign a document
    /// @dev This MUST be validated by the smart contract. This MUST emit DocumentSigned or throw.

    /**
     * @dev
     *
     */

    function signDocument(address signer, uint16 documentId) public {

        Document memory d = Document(signer, block.timestamp,  "https://ipfs.io/ipfs/Qmabcxyz123");

        
        documents[documentId] = d; //push

        signers[signer] = documentId;

        emit DocumentSigned(signer, documentId);
    }

    
    /// @notice Emitted when signDocument accepts 3 parameters

    event DocumentSignedAt(address indexed signer, uint16 indexed documentId, string uri);*/
}