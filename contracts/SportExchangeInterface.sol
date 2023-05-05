// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of the Exchange Contract for Sportract
 */
interface SportExchangeInterface is IERC20 {

    /**
     * @dev Emitted when the Exchange is funded
     */

    event AddLiquidity(address indexed provider, uint liquidity);

    /**
     * @dev Emitted when funds are retrieved from the exchange
     */

    event RemoveLiquidity(address indexed provider, uint liquidity);

    /**
     * @dev Emitted when tokens are exchanged for ether
     */

    event TokenPurchase(address indexed buyer, uint eth_sold, uint tokens_bought);

    /**
     * @dev Emitted when ether is exchanged for the tokens
     */

    event EthPurchase(address indexed seller, uint tokens_sold, uint eth_bought);


    // Provide Liquidity

    function addLiquidity(uint min_liquidity, uint max_tokens) external payable returns (uint);
    function removeLiquidity(uint amount, uint min_eth, uint min_tokens) external returns (uint, uint);


    // Get Prices

    function getEthToTokenInputPrice(uint eth_sold) external view returns (uint tokens_bought);

    function getEthToTokenOutputPrice(uint tokens_bought) external view returns (uint eth_sold);
    
    function getTokenToEthInputPrice(uint tokens_sold) external view returns (uint eth_bought);
    
    function getTokenToEthOutputPrice(uint eth_bought) external view returns (uint tokens_sold);


    // Trade ETH to ERC20

    function ethToTokenSwapInput(uint min_tokens) external payable returns (uint  tokens_bought);
    
    function ethToTokenTransferInput(uint min_tokens, address recipient) external payable returns (uint  tokens_bought);
    
    function ethToTokenSwapOutput(uint tokens_bought) external payable returns (uint  eth_sold);
    
    function ethToTokenTransferOutput(uint tokens_bought, address recipient) external payable returns (uint  eth_sold);
    
    
    // Trade ERC20 to ETH

    function tokenToEthSwapInput(uint tokens_sold, uint min_eth) external returns (uint  eth_bought);
    
    function tokenToEthTransferInput(uint tokens_sold, uint min_eth, address recipient) external returns (uint  eth_bought);
    
    function tokenToEthSwapOutput(uint eth_bought, uint max_tokens) external returns (uint  tokens_sold);
    
    function tokenToEthTransferOutput(uint eth_bought, uint max_tokens, address recipient) external returns (uint  tokens_sold);
    

    
    
}
