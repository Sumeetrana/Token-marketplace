// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; // stating our version

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract TokenMarketPlace is Ownable {
    using SafeERC20 for IERC20;

    uint256 public tokenPrice = 2e16 wei; // 0.02 ether per GLD token

    uint256 public sellerCount = 1;
    uint256 public buyerCount = 1;

    IERC20 public gldToken;

    constructor(address _gldToken) Ownable(msg.sender) {
        gldToken = IERC20(_gldToken);
    }

    // Updated logic for token price calculation with safeguards
    function adjustTokenPriceBasedOnDemand() public {
        uint marketDemandRatio = (buyerCount * 1e10) / sellerCount;

        uint smoothingFactor = 1e18;

        uint adjustedRatio = (marketDemandRatio + smoothingFactor) / 2;

        uint newTokenPrice = (tokenPrice * adjustedRatio) / 1e18;

        uint minimumPrice = 2e16;

        if (newTokenPrice < minimumPrice) {
            tokenPrice = minimumPrice;
        } else {
            tokenPrice = newTokenPrice;
        }
    }

    function calculateTokenPrice(uint _amountOfToken) public {
        require(_amountOfToken > 0, "Amount of token should be greater than 0");
        adjustTokenPriceBasedOnDemand();
        uint amountToPay = (_amountOfToken * tokenPrice) / 1e18;
    }
}
