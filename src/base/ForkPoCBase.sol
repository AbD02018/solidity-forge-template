// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";

/// @title ForkPoCBase
/// @notice Base contract for fork-based Proof of Concepts.
/// @dev Handles mainnet fork setup, common test addresses, and state diff utilities.
abstract contract ForkPoCBase is Test {
    /// @dev Common mainnet addresses
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    /// @dev Default test accounts
    address attacker = makeAddr("attacker");
    address victim = makeAddr("victim");

    /// @dev Common cheatcode wrappers
    function _deal(address token, address to, uint256 amount) internal {
        deal(token, to, amount);
    }

    function _warp(uint256 timestamp) internal {
        vm.warp(timestamp);
    }

    function _roll(uint256 blockNumber) internal {
        vm.roll(blockNumber);
    }
}
