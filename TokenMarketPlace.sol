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
}
