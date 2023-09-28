// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface INftToken {
    function mint(address _recipient) external returns (uint256 tokenId_);
}
