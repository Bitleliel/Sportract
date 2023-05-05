// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import "./SportExchangeInterface.sol";
import "./Sportract.sol";


/////////// AGGIUNGERE GLI EVENTI ////////////////////


/**
 * @dev Implementation of SportExchangeInterface 
 *
 * This contract works as an exchange for the tokens of Sportract
 */

contract SportExchange is ERC20, Ownable, SportExchangeInterface {

    Sportract private sportract;

    enum State {Created, Inactive, Funded}
    State public state;



    constructor(address _sportractaddress) ERC20("","") {

        assert (_sportractaddress != address(0));
        
        sportract = Sportract(_sportractaddress);
    }

    function burn(address _account, uint _amount) private returns (bool) {

        _burn(_account, _amount);
        return true;
    }

    function mint(address _account, uint _amount) private returns (bool) {

        _mint(_account, _amount);
        return true;        
    }

    /**
     * @dev Adds liquidity to the pool 
     *  
     */

    function addLiquidity(uint min_liquidity, uint max_tokens) external payable returns (uint) {
        
        
        require(max_tokens > 0 && msg.value > 0);

        if (totalSupply() > 0) {

            require(min_liquidity > 0);

            uint token_amount = (msg.value * sportract.balanceOf(this)) / (address(this).balance - msg.value) + 1;//+1??

            uint liquidity_minted = (msg.value * totalSupply()) / (address(this).balnce - msg.value);

            require (max_tokens >= token_amount && liquidity_minted >= min_liquidity);

            require (mint(_msgSender(), liquidity_minted));

            sportract.transferFrom(_msgSender(), address(this), token_amount);

            emit SportExchangeInterface.AddLiquidity(_msgSender(), liquidity_minted);

            return liquidity_minted;

        } else {

            require(msg.value >= 1000000000);

            uint initial_liquidity = this.balance * max_tokens; //riga 68

            require (mint(_msgSender(), initial_liquidity));

            sportract.transferFrom(_msgSender(), address(this), max_tokens);

            return initial_liquidity;
        }

    }

    /**
     # @dev Burn UNI tokens to withdraw ETH and Tokens at current ratio.
     # @param amount Amount of UNI burned.
     # @param min_eth Minimum ETH withdrawn.
     # @param min_tokens Minimum Tokens withdrawn.
     # @return The amount of ETH and Tokens withdrawn.
     */

    function removeLiquidity(uint amount, uint min_eth, uint min_tokens) returns(uint, uint) {

        require(totalSupply() > 0 && amount > 0 && min_eth > 0 && min_tokens > 0); //riga 84

        uint eth_amount = amount * this.balance / totalSupply();
        uint token_amount = amount * sportract.balanceOf(address(this)) / totalSupply();

        require(eth_amount >= min_eth && token_amount >= min_tokens);

        burn(_msgSender(), amount);
        
        send(_msgSender(), eth_amount);
        
        sportract.transferFrom(address(this), _msgSender(), token_amount);

        return (eth_amount, token_amount);
    }

    /**
     # @dev Pricing function for converting between ETH and Tokens.
     # @param input_amount Amount of ETH or Tokens being sold.
     # @param input_reserve Amount of ETH or Tokens (input type) in exchange reserves.
     # @param output_reserve Amount of ETH or Tokens (output type) in exchange reserves.
     # @return Amount of ETH or Tokens bought.
     */

    function getInputPrice(uint input_amount, uint input_reserve, uint output_reserve) private returns (uint) {

        require(input_reserve > 0 && output_reserve > 0);

        uint input_amount_fee = input_amount * 997;
        uint numerator = input_amount_fee * output_reserve;
        uint denominator = (input_reserve * 1000) + input_amount_fee;

        return numerator / denominator;
        
    } 

    /**
     # @dev Pricing function for converting between ETH and Tokens.
     # @param output_amount Amount of ETH or Tokens being bought.
     # @param input_reserve Amount of ETH or Tokens (input type) in exchange reserves.
     # @param output_reserve Amount of ETH or Tokens (output type) in exchange reserves.
     # @return Amount of ETH or Tokens sold.
     */


    function getOutupPrice(uint output_amount, uint input_reserve, uint output_reserve) private returns (uint) {

        require(input_reserve > 0 && output_reserve > 0);

        uint numerator = input_reserve * output_amount * 1000;
        uint denominator = (output_reserve - output_amount) * 997;

        return numerator / denominator + 1;

    }


/////////////////////////////////////////////////////////////////////////////////////////////////////////

    function ethToTokenInput(uint eth_sold, uint min_tokens, address buyer, address recipient) private returns (uint) {

        require (eth_sold > 0 && min_tokens > 0);
        
        uint token_reserve = sportract.balanceOf(address(this));
        uint tokens_bought = getInputPrice(eth_sold, (address(this).balance - eth_sold), token_reserve);

        require (tokens_bought > min_tokens);

        require(sportract.transferFrom(address(this), _msgSender(), tokens_bought));

        return tokens_bought;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////

    fallback() external payable {
        ethToTokenInput(mas.value, 1, _msgSender(), _msgSender());
    }


    /**
     # @notice Convert ETH to Tokens.
     # @dev User specifies exact input (msg.value) and minimum output.
     # @param min_tokens Minimum Tokens bought.
     # @return Amount of Tokens bought.
     */


    function ethToTokenSwapInput(uint min_tokens) public payable returns (uint) {
        return ethToTokenInput(msg.value, min_tokens, _msgSender(), _msgSender());
    }


    /**
     # @notice Convert ETH to Tokens and transfers Tokens to recipient.
     # @dev User specifies exact input (msg.value) and minimum output
     # @param min_tokens Minimum Tokens bought.
     # @param recipient The address that receives output Tokens.
     # @return Amount of Tokens bought. 
     */

    function ethToTokenTransferInput(uint min_tokens, address recipient) public payable returns (uint) {

        require (recipient != address(this) && recipient != address(0));
        
        return ethToTokenInput(msg.value, min_tokens, _msgSender(), recipient);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////

    function ethToTokenOutput(uint tokens_bought, uint max_eth, address buyer, address recipient) private returns (uint) {
        
        require (tokens_bought > 0 && max_eth > 0);

        /////////////// CONTROLLARE STA FUNZIONE //////////////////////////

        uint token_reserve = sportract.balanceOf(address(this));
        uint eth_sold = getOutupPrice(tokens_bought, (this.balance - max_eth), token_reserve);

        require (max_eth > eth_sold);

        require(sportract.transferFrom(address(this), recipient, tokens_bought)); /// riga 173

        send(buyer, /* covert to wei  */ (max_eth - eth_sold));

        return eth_sold;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     # @notice Convert ETH to Tokens.
     # @dev User specifies maximum input (msg.value) and exact output.
     # @param tokens_bought Amount of tokens bought.
     # @param deadline Time after which this transaction can no longer be executed.
     # @return Amount of ETH sold.
     */

    function ethToTokenSwapOutput(uint tokens_bought) public payable returns (uint) {
        return ethToTokenOutput(tokens_bought, msg.value, _msgSender(), _msgSender());
    }


    /**
     # @notice Convert ETH to Tokens and transfers Tokens to recipient.
     # @dev User specifies maximum input (msg.value) and exact output.
     # @param tokens_bought Amount of tokens bought.
     # @param deadline Time after which this transaction can no longer be executed.
     # @param recipient The address that receives output Tokens.
     # @return Amount of ETH sold.
     */

    function ethToTokenTransferOutput(uint tokens_bought, address recipient) public payable returns (uint) {

        require(recipient != address(this) && recipient != address(0));

        return ethToTokenOutput(tokens_bought, msg.value, _msgSender(), recipient);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////

    function tokenToEthInput (uint tokens_sold, uint min_eth, address buyer, address recipient) private returns (uint) {

        require(tokens_sold > 0 && min_eth > 0);

        uint token_reserve = sportract.balanceOf(address(this));
        uint eth_bought = getInputPrice(tokens_sold, token_reserve, address(this).balance);

        /// convert to wei //////

        require(eth_bought >= min_eth);

        send(recipient, eth_bought);

        require (sportract.transferFrom(buyer, address(this), tokens_sold));

        return eth_bought;

    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////


    /**
     # @notice Convert Tokens to ETH.
     # @dev User specifies exact input and minimum output.
     # @param tokens_sold Amount of Tokens sold.
     # @param min_eth Minimum ETH purchased.
     # @return Amount of ETH bought.
     */

    function tokenToEthSwapInput(uint tokens_sold, uint min_eth) public returns (uint) {
        return tokenToEthInput(tokens_sold, min_eth, _msgSender(), _msgSender());
    }
    


    /**
     # @notice Convert Tokens to ETH and transfers ETH to recipient.
     # @dev User specifies exact input and minimum output.
     # @param tokens_sold Amount of Tokens sold.
     # @param min_eth Minimum ETH purchased.
     # @param recipient The address that receives output ETH.
     # @return Amount of ETH bought.
     */

    function tokenToEthTransferInput(uint tokens_sold, uint min_eth, uint recipient) public returns (uint) {

        require(recipient != address(this) && recipient != address(0));

        return tokenToEthInput(tokens_sold, min_eth, _msgSender(), recipient);
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    function tokenToEthOutput (uint eth_bought, uint max_tokens, address buyer, address recipient) private returns (uint) {

        require(eth_bought > 0 /***/ && max_tokens > 0 /***/); //riga 238

        uint token_reserve = sportract.balanceOf(address(this));
        uint tokens_sold = getOutupPrice(eth_bought, token_reserve, address(this).balance);

        require(max_tokens >= tokens_sold);

        require(sportract.transferFrom(buyer, address(this), tokens_sold));
        send(recipient, eth_bought);

        return tokens_sold;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    /**
     # @notice Convert Tokens to ETH.
     # @dev User specifies maximum input and exact output.
     # @param eth_bought Amount of ETH purchased.
     # @param max_tokens Maximum Tokens sold.
     # @return Amount of Tokens sold.
     */

    function tokenToEthSwapOutput(uint eth_bought, uint max_tokens) public returns (uint) {
        return tokenToEthOutput(eth_bought, max_tokens, _msgSender(), _msgSender());
    }


    /**
     # @notice Convert Tokens to ETH and transfers ETH to recipient.
     # @dev User specifies maximum input and exact output.
     # @param eth_bought Amount of ETH purchased.
     # @param max_tokens Maximum Tokens sold.
     # @param recipient The address that receives output ETH.
     # @return Amount of Tokens sold.
     */

    function tokenToEthTransferOutput(uint eth_bought, uint max_tokens, address recipient) public returns (uint) {
        
        require(recipient != address(this) && recipient != address(0));

        return tokenToEthOutput(eth_bought, max_tokens, _msgSender(), recipient);
    }


    /**
     # @notice Public price function for ETH to Token trades with an exact input.
     # @param eth_sold Amount of ETH sold.
     # @return Amount of Tokens that can be bought with input ETH.
     */

    function getEthToTokenInputPrice(uint eth_sold) public returns (uint) {

        require(eth_sold > 0);

        uint token_reserve = sportract.balanceOf(address(this));

        getInputPrice(eth_sold, this.balance, sportract.balanceOf(this));
    }

    /**
     # @notice Public price function for ETH to Token trades with an exact output.
     # @param tokens_bought Amount of Tokens bought.
     # @return Amount of ETH needed to buy output Tokens.
     */

    function getEthToTokenOutputPrice(uint tokens_bought) public returns (uint) {
        
        require(tokens_bought > 0);

        uint token_reserve = sportract.balanceOf(address(this));
        uint eth_sold = getOutupPrice(output_amount, input_reserve, output_reserve);

        return eth_sold;
    }


    /**
     # @notice Public price function for Token to ETH trades with an exact input.
     # @param tokens_sold Amount of Tokens sold.
     # @return Amount of ETH that can be bought with input Tokens.
     */

    function getTokenToEthInputPrice(uint tokens_sold) public returns (uint) {

        require(tokens_sold > 0);

        uint token_reserve = sportract.balanceOf(address(this));
        return getInputPrice(tokens_sold, token_reserve, address(this).balance);       
    }


    /**
     # @notice Public price function for Token to ETH trades with an exact output.
     # @param eth_bought Amount of output ETH.
     # @return Amount of Tokens needed to buy output ETH.
     */

    function getTokenToEthOutputPrice(uint eth_bought) public returns (uint) {

        require(eth_bought > 0);

        uint token_reserve = sportract.balanceOf(address(this));

        return getOutupPrice(eth_bought, token_reserve, address(this).balance);
    }
}
