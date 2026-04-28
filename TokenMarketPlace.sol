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
    uint public prevAdjustedRation;

    IERC20 public gldToken;

    event TokenBought(
        address indexed user,
        uint256 amountOfToken,
        uint256 requiredTokenPrice
    );
    event TokenSold(
        address indexed owner,
        uint256 amountOfToken,
        uint256 totalEarned
    );
    event TokensWithdrawn(address indexed owner, uint256 amount);

    constructor(address _gldToken) Ownable(msg.sender) {
        gldToken = IERC20(_gldToken);
    }

    // Updated logic for token price calculation with safeguards
    function adjustTokenPriceBasedOnDemand() public {
        uint marketDemandRatio = (buyerCount * 1e10) / sellerCount;

        uint smoothingFactor = 1e18;

        uint adjustedRatio = (marketDemandRatio + smoothingFactor) / 2;

        if (adjustedRatio != prevAdjustedRation) {
            uint newTokenPrice = (tokenPrice * adjustedRatio) / 1e18;

            uint minimumPrice = 2e16;

            if(newTokenPrice < minimumPrice) {
                tokenPrice = minimumPrice;
            } else {
                tokenPrice = newTokenPrice;
            }
        }
    }

    function calculateTokenPrice(uint _amountOfToken) public {
        require(_amountOfToken > 0, "Amount of token should be greater than 0");
        adjustTokenPriceBasedOnDemand();
        uint amountToPay = (_amountOfToken * tokenPrice) / 1e18;
    }

    function buyGLDToken(uint256 _amountOfToken) public payable {
        require(_amountOfToken > 0, "Invalid Token amount");

        uint requiredTokenPrice = calculateTokenPrice(_amountOfToken);

        require(requiredTokenPrice == msg.value, "Incorrect token price");

        // Transfer token to the buyer address
        gldToken.safeTransfer(msg.sender, _amountOfToken);

        buyerCount += 1;

        emit TokenBought(msg.sender, _amountOfToken, requiredTokenPrice);
    }

    function sellGLDToken(uint256 _amountOfToken) public {
        require(
            gldToken.balanceOf(msg.sender) >= _amountOfToken,
            "Invalid amount of token"
        );
        uint priceToPayToUser = calculateTokenPrice(_amountOfToken);
        gldToken.safeTransferFrom(msg.sender, address(this), _amountOfToken);

        // Transfering money to the user
        (bool success, ) = payable(msg.sender).call{value: priceToPayToUser}(
            ""
        );
        require(success, "Transaction failed");

        sellerCount += 1;

        emit TokenSold(msg.sender, _amountOfToken, priceToPayToUser);
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
        require(gldToken.balanceOf(address(this)) >= amount, "Out of balance");

        gldToken.safeTransfer(msg.sender, amount);

        emit TokensWithdrawn(msg.sender, amount);
    }

    function withdrawEther(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Out of balance");
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transaction failed");
    }
}
