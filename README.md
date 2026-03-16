# Uniswap v4 Hook + Staking (Sepolia)

## What it is
A minimal demo of a **Uniswap v4 hook** that collects a flat fee on swaps (token0) and forwards it to a **staking vault**. Stakers earn those fees.

> This is a learning demo. The hook uses a flat fee in token0 and requires user approval to pull fees. For production, implement proper hook fee logic + secure access control.

## Sepolia v4 addresses
- PoolManager: `0xE03A1074c86CFeDd5C142C4F04F1a1536e203543`
- PositionManager: `0x429ba70129df741B2Ca2a85BC3A2a3328e5c09b4`
- Universal Router: `0x3A9D48AB9751398BbFa63ad67599Bb04e4BdF98b`
- StateView: `0xe1dd9c3fa50edb962e442f60dfbc432e24537e4c`
- Quoter: `0x61b3f2011a92d183c7dbadbda940a7555ccf9227`

Source: https://docs.uniswap.org/contracts/v4/deployments

## Key contracts
- `FeeStakingHook.sol` — hook that collects token0 fee after swap
- `StakingVault.sol` — staking vault, distributes rewards

## How it works
1. User stakes `stakeToken` in the vault.
2. On swap, the hook pulls `feeAmount` of token0 from the swap sender and deposits to the vault.
3. Vault updates rewards; stakers can claim.

## Deploy (Sepolia)
> **Important:** v4 hooks require the contract address to match permission bits.
> Use **HookMiner** (v4-periphery test utils) + CREATE2 to deploy a valid hook address.
> The deploy script here is a placeholder and will revert on real PoolManager initialization
> unless the hook address is valid.

### Env
```
export PRIVATE_KEY=
export POOL_MANAGER=0xE03A1074c86CFeDd5C142C4F04F1a1536e203543
export STAKE_TOKEN=<ERC20>
export REWARD_TOKEN=<ERC20>
export FEE_AMOUNT=<flat fee in token0 units>
```

### Deploy
```bash
forge script script/DeployHook.s.sol --rpc-url $RPC_URL --broadcast
```

## Next upgrades
- Use HookMiner + CREATE2 (valid hook address)
- Replace flat fee with real hook fee math
- Pool initialization + UI
