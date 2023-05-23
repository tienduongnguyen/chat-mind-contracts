// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ChatMindReward is Ownable, ReentrancyGuard {
    event ClaimReward(address indexed account, uint256 amount);
    event UpdateActiveReward(address[] indexed accounts, uint256[] amounts);
    event UpdateAdmin(address indexed admin);
    event UpdateTotalReward(uint256 indexed totalReward);
    event BlockUser(address indexed account);
    event UnblockUser(address indexed account);

    mapping(address => uint256) private _activeReward;
    mapping(address => bool) private _isBlocked;

    uint256 private _totalReward;
    uint256 private _lastUpdate;
    uint256 private _oneDay = 86400;

    address private _admin;
    ERC20 private _chatMind;

    constructor(address chatMind, address admin) {
        _admin = admin;
        _chatMind = ERC20(chatMind);
        _lastUpdate = block.timestamp;
    }

    function claimReward() external nonReentrant {
        require(!isBlocked(msg.sender), "User is blocked");
        require(getActiveReward(msg.sender) > 0, "No reward to claim");
        uint256 reward = getActiveReward(msg.sender);
        require(balanceOfPool() >= reward, "Pool is exhausted");
        _chatMind.transferFrom(_admin, msg.sender, reward);
        resetActiveReward(msg.sender);

        emit ClaimReward(msg.sender, reward);
    }

    function balanceOfPool() public view returns (uint256) {
        return _chatMind.balanceOf(_admin);
    }

    function setNewAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0), "New admin is the zero address");
        _admin = newAdmin;

        emit UpdateAdmin(newAdmin);
    }

    function setTotalReward(uint256 totalReward) public onlyOwner {
        _totalReward = totalReward;
        emit UpdateTotalReward(totalReward);
    }

    function getTotalReward() public view returns (uint256) {
        return _totalReward;
    }

    function increaseActiveReward(address account, uint256 amount) internal {
        _activeReward[account] += amount;
    }

    function resetActiveReward(address account) internal {
        _activeReward[account] = 0;
    }

    function getActiveReward(address account) public view returns (uint256) {
        return _activeReward[account];
    }

    function increaseBatch(
        address[] memory accounts,
        uint256[] memory activePoints
    ) public onlyOwner {
        require(
            accounts.length == activePoints.length,
            "Array length mismatch"
        );
        require(block.timestamp - _lastUpdate >= _oneDay, "Already icreased");
        _lastUpdate = block.timestamp;

        uint256 totalPoint = 0;

        for (uint256 i = 0; i < activePoints.length; i++) {
            totalPoint += activePoints[i];
        }

        uint256 totalReward = getTotalReward();
        uint256 rewardEachPoint = totalReward / totalPoint;
        uint256[] memory activeRewards = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; i++) {
            uint256 activeReward = rewardEachPoint * activePoints[i];
            increaseActiveReward(accounts[i], activeReward);
            activeRewards[i] = activeReward;
        }

        emit UpdateActiveReward(accounts, activeRewards);
    }

    function blockUser(address account) public onlyOwner {
        require(!isBlocked(account), "User is already blocked");
        _isBlocked[account] = true;

        emit BlockUser(account);
    }

    function unblockUser(address account) public onlyOwner {
        require(isBlocked(account), "User is not blocked");
        _isBlocked[account] = false;

        emit UnblockUser(account);
    }

    function isBlocked(address account) public view returns (bool) {
        return _isBlocked[account];
    }
}
