// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Stream {
    uint256 public pointsPerMinute;
    uint256 public minimumPointsForWithdrawal;
    address public tokenAddress;
    address public walletAddress;

    mapping(address => uint256) public userPoints;

    constructor(address _tokenAddress, uint256 _pointsPerMinute, uint256 _minimumPointsForWithdrawal) {
        tokenAddress = _tokenAddress;
        pointsPerMinute = _pointsPerMinute;
        minimumPointsForWithdrawal = _minimumPointsForWithdrawal;
    }

    function stream(uint256 durationMinutes) public {
        require(durationMinutes > 0, "Duration must be greater than zero");

        uint256 earnedPoints = durationMinutes * pointsPerMinute;
        userPoints[msg.sender] += earnedPoints;

        emit StreamCompleted(msg.sender, earnedPoints);
    }

    function withdrawPoints() public {
        require(userPoints[msg.sender] >= minimumPointsForWithdrawal, "Insufficient points for withdrawal");

        uint256 withdrawableAmount = userPoints[msg.sender] * pointsPerMinute / 100;
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= withdrawableAmount, "Insufficient token balance"); 

        token.transfer(msg.sender, withdrawableAmount);
        userPoints[msg.sender] = 0;

        emit PointsWithdrawn(msg.sender, withdrawableAmount);
    }

    event StreamCompleted(address user, uint256 earnedPoints);
    event PointsWithdrawn(address user, uint256 withdrawnAmount);
}