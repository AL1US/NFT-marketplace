// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IXcoin {
    function balanceOf(address _account) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) external;
    function approve(address _account, uint256 _value) external;
}

