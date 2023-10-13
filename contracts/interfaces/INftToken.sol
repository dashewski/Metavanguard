// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface INftToken {
    function mint(address _recipient) external returns (uint256 tokenId_);

    function isOpened(uint256 _tokenId) external view returns (bool);

    function enforceIsOpen(uint256 _nftId) external view;

    function enforceIsNotOpen(uint256 _nftId) external view;
}
