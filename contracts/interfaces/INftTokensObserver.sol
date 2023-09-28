// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface INftTokensObserver {
    function notifyChangeOwner(uint256 _nftId, address _oldOwner, address _newOwner) external;

    function notifyOpen(uint256 _nftId) external;
}
