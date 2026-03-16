// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./interfaces/IERC20.sol";

/// @notice Simple staking vault for rewards in a single ERC20.
contract StakingVault {
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;
    address public hook;

    uint256 public totalStaked;
    mapping(address => uint256) public balanceOf;

    uint256 public accRewardPerShare; // scaled by 1e18
    mapping(address => uint256) public rewardDebt;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event HookSet(address hook);

    modifier onlyHook() {
        require(msg.sender == hook, "ONLY_HOOK");
        _;
    }

    constructor(address _stakeToken, address _rewardToken) {
        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
    }

    function setHook(address _hook) external {
        require(hook == address(0), "HOOK_SET");
        hook = _hook;
        emit HookSet(_hook);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "ZERO");
        _updateRewards(msg.sender);
        require(stakeToken.transferFrom(msg.sender, address(this), amount), "TRANSFER_FROM");
        balanceOf[msg.sender] += amount;
        totalStaked += amount;
        rewardDebt[msg.sender] = (balanceOf[msg.sender] * accRewardPerShare) / 1e18;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "ZERO");
        _updateRewards(msg.sender);
        balanceOf[msg.sender] -= amount;
        totalStaked -= amount;
        rewardDebt[msg.sender] = (balanceOf[msg.sender] * accRewardPerShare) / 1e18;
        require(stakeToken.transfer(msg.sender, amount), "TRANSFER");
        emit Unstake(msg.sender, amount);
    }

    function claim() external {
        _updateRewards(msg.sender);
        uint256 owed = (balanceOf[msg.sender] * accRewardPerShare) / 1e18 - rewardDebt[msg.sender];
        rewardDebt[msg.sender] = (balanceOf[msg.sender] * accRewardPerShare) / 1e18;
        require(rewardToken.transfer(msg.sender, owed), "TRANSFER");
        emit Claim(msg.sender, owed);
    }

    /// @notice Called by hook when it collects fees. Adds to reward pool.
    function notifyReward(uint256 amount) external onlyHook {
        if (totalStaked == 0 || amount == 0) return;
        accRewardPerShare += (amount * 1e18) / totalStaked;
    }

    function _updateRewards(address user) internal {
        if (balanceOf[user] == 0) return;
        uint256 owed = (balanceOf[user] * accRewardPerShare) / 1e18 - rewardDebt[user];
        if (owed > 0) {
            require(rewardToken.transfer(user, owed), "TRANSFER");
        }
    }
}
