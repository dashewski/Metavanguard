// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

interface IAddressBook {
    function enforceIsProductOwner(address _account) external view;

    function enforceIsProductOwnerMarketplace(address _account) external view;

    function enforceIsPayToken(address _token) external view;

    function enforceIsNftTokenContract(address _contract) external view;

    function enforceIsNftTokensFactory(address _account) external view;

    function treasury() external view returns (address);

    function nftTokensFactory() external view returns (address);

    function nftTokensObserver() external view returns (address);

    function productOwner() external view returns (address);

    function productOwnerMarketplace() external view returns (address);

    function nftTokens(address _nftToken) external view returns (bool);

    function payTokens(address _token) external view returns (bool);
}
