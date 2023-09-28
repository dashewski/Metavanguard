// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { IAddressBook } from "../interfaces/IAddressBook.sol";

contract AddressBook is IAddressBook, UUPSUpgradeable {
    // ------------------------------------------------------------------------------------
    // ----- STORAGE ----------------------------------------------------------------------
    // ------------------------------------------------------------------------------------

    address public productOwner;
    address public productOwnerMarketplace;
    address public treasury;
    address public nftTokensFactory;
    address public nftTokensObserver;
    mapping(address => bool) public nftTokens;
    mapping(address => bool) public payTokens;

    // ------------------------------------------------------------------------------------
    // ----- DEPLOY & UPGRADE  ------------------------------------------------------------
    // ------------------------------------------------------------------------------------

    function initialize(address _prodcutOwner) public initializer {
        productOwner = _prodcutOwner;
    }

    function _authorizeUpgrade(address) internal view override {
        enforceIsProductOwner(msg.sender);
    }

    // ------------------------------------------------------------------------------------
    // ----- PRODUCT OWNER ACTIONS  -------------------------------------------------------
    // ------------------------------------------------------------------------------------

    function setProductOwner(address _newProductOwner) external {
        enforceIsProductOwner(msg.sender);
        productOwner = _newProductOwner;
    }

    function setNftToken(address _nftToken, bool _value) external {
        enforceIsProductOwner(msg.sender);
        nftTokens[_nftToken] = _value;
    }

    function setNftTokensFactory(address _nftTokensFactory) external {
        enforceIsProductOwner(msg.sender);
        require(nftTokensObserver == address(0), "nftTokensFactory already setted!");

        nftTokensFactory = _nftTokensFactory;
    }

    function setNftTokensObserver(address _nftTokensObserver) external {
        enforceIsProductOwner(msg.sender);
        require(nftTokensObserver == address(0), "nftTokensObserver already setted!");

        nftTokensObserver = _nftTokensObserver;
    }

    function setTreasury(address _treasury) external {
        enforceIsProductOwner(msg.sender);
        require(treasury == address(0), "treasury already setted!");

        treasury = _treasury;
    }

    function setProductOwnerMarketplace(address _productOwnerMarketplace) external {
        enforceIsProductOwner(msg.sender);
        require(productOwnerMarketplace == address(0), "productOwnerMarketplace already setted!");

        productOwnerMarketplace = _productOwnerMarketplace;
    }

    // ------------------------------------------------------------------------------------
    // ----- VIEW  ------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------

    function enforceIsProductOwner(address _account) public view {
        require(_account == productOwner, "only product owner!");
    }

    function enforceIsProductOwnerMarketplace(address _account) public view {
        require(_account == productOwnerMarketplace, "only product owner marketplace!");
    }

    function enforceIsNftTokenContract(address _contract) external view {
        require(nftTokens[_contract], "only nft token!");
    }

    function enforceIsNftTokensFactory(address _account) external view {
        require(nftTokensFactory == _account, "only nft token factory!");
    }

    function enforceIsPayToken(address _token) external view {
        require(payTokens[_token], "only pay token!");
    }
}
