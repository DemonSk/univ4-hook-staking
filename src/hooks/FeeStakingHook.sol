// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseHook} from "../lib/v4-periphery/contracts/base/BaseHook.sol";
import {Hooks} from "../lib/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "../lib/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "../lib/v4-core/contracts/types/PoolKey.sol";
import {BalanceDelta} from "../lib/v4-core/contracts/types/BalanceDelta.sol";
import {Currency, CurrencyLibrary} from "../lib/v4-core/contracts/types/Currency.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {StakingVault} from "../StakingVault.sol";

/// @notice Example Uniswap v4 hook: collects a flat fee in token0 and deposits into vault.
/// @dev For demo only. Requires users to approve this hook to pull token0 fees.
contract FeeStakingHook is BaseHook {
    using CurrencyLibrary for Currency;

    StakingVault public immutable vault;
    uint256 public feeAmount; // flat fee in token0 units

    event FeeCollected(address indexed sender, uint256 feeAmount);

    constructor(IPoolManager manager, StakingVault _vault, uint256 _feeAmount) BaseHook(manager) {
        vault = _vault;
        feeAmount = _feeAmount;
    }

    function setFeeAmount(uint256 newFee) external {
        // simplified admin, demo only
        feeAmount = newFee;
    }

    // Hook permissions: afterSwap only
    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override returns (bytes4, int128) {
        // Collect flat fee in token0 (ERC20 only)
        address token0 = Currency.unwrap(key.currency0);
        if (token0 != address(0) && feeAmount > 0) {
            IERC20(token0).transferFrom(sender, address(vault), feeAmount);
            vault.notifyReward(feeAmount);
            emit FeeCollected(sender, feeAmount);
        }
        return (this.afterSwap.selector, 0);
    }
}
