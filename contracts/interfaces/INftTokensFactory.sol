// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface INftTokensFactory {
    function regularMint(address _nftToken, address _recipient) external returns (uint256 tokenId_);

    function discountedMint(
        address _nftToken,
        address _recipient
    ) external returns (uint256 tokenId_);

    // function creditMint(address _nftToken, address _recipient) external returns (uint256 tokenId_);
}
