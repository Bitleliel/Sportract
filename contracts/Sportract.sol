// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Contract to collect athletes' performance data
 *
 * This contract provides a storage to the athlete's profile 
 * information, such as name, age, country or gender.
 *
 * Moreover, it colletcs data for every sport event in which the athlete competes, 
 * producing value and burning tokens in case of high performances
 * or inflating value, therefore minting tokens in case of low performances.
 * 
 */


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ERC5289.sol";

contract Sportract is ERC20, ERC20Burnable, Ownable {

    
    // The following variables store user data 
    // Data is public on the blockchain, so it is editable outside the contract

    string ownername;
    string country;
    string gender;
    uint256 yearofbirth;

    // Index of the total sport events attended
    
    uint256 private contestIndex = 0;

    // Data structure containing the scores of every event

    mapping (uint256 => uint256) Contests;

    
    // The following variables set the bounds that trigger the minting/burning

    uint256 private scorelimitup = 6;
    uint256 private scorelimitdown = 4;

    // Share is the amount of tokens to mint/burn

    uint256 private share = 500;

   /**
    * @dev The constructor initializes the contract
    *
    */

    constructor() ERC20("MyToken", "MTK") {    }


   /**
    * @dev Sets the value for ownername, country, gender, yearofbirth
    *
    * Each of these variables are editable in the future
    *
    */

    function setUserData (
        string calldata _ownername, 
        string calldata _gender, 
        string calldata _country, 
        uint _yearofbirth
        ) public {
        setName(_ownername);
        setCountry(_country);
        setGender(_gender);
        setYearofbirth(_yearofbirth);
    }
    
    
   /**
    * @dev Returns the value of ownername
    *
    */

    function getName() public view returns (string memory) {
        return ownername;
    }

   /**
    * @dev Returns the value of country
    *
    */

    function getCountry() public view returns (string memory) {
        return country;
    }
    
   /**
    * @dev Returns the value of gender
    *
    */

    function getGender() public view returns (string memory) {
        return gender;
    }
    
   /**
    * @dev Returns the value of yearofbirth
    *
    */

    function getYearOfBirth() public view returns (uint256) {
        return yearofbirth;
    }

   /**
    * @dev Sets the value for ownername
    *
    */

    function setName (string calldata _ownername) public {
        ownername = _ownername;
    }

    
   /**
    * @dev Sets the value for country
    *
    */

    function setCountry (string calldata _country) public {
        country = _country;
    }

    
   /**
    * @dev Sets the value for gender
    *
    */

    function setGender (string calldata _gender) public {
        gender = _gender;
    }
    
   /**
    * @dev Sets the value for yearofbirth
    *
    */

    function setYearofbirth (uint256 _yearofbirth) public {
        yearofbirth = _yearofbirth;
    }


   /**
    * @dev Sets the bounds that trigger burning/minting (1 to 10) and the amount to burn/mint 
    *
    * Only the owner of the contract is allowed to modify this values.
    * The bounds of the scores, as the scores themselves, are between 1 and 10
    */

    function setValueOptions(uint256 _scorelimitup, uint256 _scorelimitdown, uint256 _share) public onlyOwner {
        
        // It is required that both bounds are between 1 and 10
        
        require(_scorelimitup < 10 && _scorelimitdown < _scorelimitup && 1 < scorelimitdown);

        scorelimitup = _scorelimitup;
        scorelimitdown = _scorelimitdown;
        share = _share;
    }

    /**
    * @dev Returns the value of limitscoreup
    *
    */

    function getscorelimitup() public view returns (uint256) {
        return scorelimitup;
    }

    /**
    * @dev Returns the value of limitscoredown
    *
    */

    function getscorelimitdown() public view returns (uint256) {
        return scorelimitdown;
    }
    
    /**
    * @dev Returns the value of share
    *
    */

    function getShare() public view returns (uint256) {
        return share;
    }

    /**
    * @dev Mints or burns the number of tokens stored in share, based on input
    *
    * This function compares the value of score with the bounds
    * if the score is greater than the upper bound, tokens are burned
    * if the score is smaller than the lower bound, tokens are minted
    */

    function scoreValue (uint256 _score) private {
        if (_score > scorelimitup) burn(share);
        if (_score < scorelimitdown) mint(owner(), share);
    }

    /**
    * @dev Collects and evaluates score data of a new contest, updates the number of events stored 
    *
    */

    function registerNewContest(uint256 score) public {

        // The score of every game is bounded by the contract between 1 and 10
        
        require(score > 0 && score < 11);

        Contests[contestIndex] = score;
        contestIndex = contestIndex + 1;
        scoreValue(score);
    }

    function mint(address to, uint256 amount) private {
        _mint(to, amount);
    }
}