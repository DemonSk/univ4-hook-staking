// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IPoolManager} from "../lib/v4-core/contracts/interfaces/IPoolManager.sol";
import {FeeStakingHook} from "../src/hooks/FeeStakingHook.sol";
import {StakingVault} from "../src/StakingVault.sol";

/// @notice Deploys StakingVault + Hook on Sepolia.
/// NOTE: For real v4 hooks, you MUST deploy with CREATE2 using HookMiner
/// so the address matches hook permission bits. This script is a placeholder.
contract DeployHook is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address poolManager = vm.envAddress("POOL_MANAGER");
        address stakeToken = vm.envAddress("STAKE_TOKEN");
        address rewardToken = vm.envAddress("REWARD_TOKEN");
        uint256 feeAmount = vm.envUint("FEE_AMOUNT");

        vm.startBroadcast(pk);

        StakingVault vault = new StakingVault(stakeToken, rewardToken);
        FeeStakingHook hook = new FeeStakingHook(IPoolManager(poolManager), vault, feeAmount);
        vault.setHook(address(hook));

        vm.stopBroadcast();
    }
}
