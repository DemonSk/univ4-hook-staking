// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {FeeStakingHook} from "../src/hooks/FeeStakingHook.sol";

/// @notice Fork test skeleton for Sepolia. Requires RPC_URL env.
contract ForkSepoliaTest is Test {
    address constant POOL_MANAGER = 0xE03A1074c86CFeDd5C142C4F04F1a1536e203543;

    function setUp() public {}

    function testDeployHookAndVaultOnFork() public {
        string memory rpc = vm.envOr("RPC_URL", string(""));
        if (bytes(rpc).length == 0) return; // skip if no fork RPC
        vm.createSelectFork(rpc);

        // NOTE: This will deploy, but PoolManager will only accept hooks
        // whose addresses match permission bits (CREATE2 + HookMiner).
        StakingVault vault = new StakingVault(address(0x1), address(0x1));
        FeeStakingHook hook = new FeeStakingHook(IPoolManager(POOL_MANAGER), vault, 1);
        vault.setHook(address(hook));

        assertEq(address(hook.poolManager()), POOL_MANAGER);
    }
}
