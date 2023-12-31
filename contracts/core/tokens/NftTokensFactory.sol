// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { INftToken } from "../../interfaces/INftToken.sol";
import { IAddressBook } from "../../interfaces/IAddressBook.sol";
import { INftTokensObserver } from "../../interfaces/INftTokensObserver.sol";

contract NftTokensFactory is ReentrancyGuardUpgradeable, UUPSUpgradeable {
    address public addressBook;
    uint256 public nextTokenId;

    mapping(address account => bool) public minters;
    mapping(address nftToken => mapping(uint256 nftId => bool)) public isDiscountedMint;

    // mapping(address nftToken => mapping(uint256 nftId => bool)) public isCreditMint;

    function initialize(address _addressBook) public initializer {
        addressBook = _addressBook;
    }

    function setMinter(address _minter, bool _value) external {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
        minters[_minter] = _value;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function _enfroceIsMinterRole() internal view {
        require(minters[msg.sender], "only minter role!");
    }

    function regularMint(
        address _nftToken,
        address _recipient
    ) external returns (uint256 tokenId_) {
        _enfroceIsMinterRole();
        tokenId_ = INftToken(_nftToken).mint(_recipient);
    }

    function discountedMint(
        address _nftToken,
        address _recipient
    ) external returns (uint256 tokenId_) {
        _enfroceIsMinterRole();
        tokenId_ = INftToken(_nftToken).mint(_recipient);
        isDiscountedMint[_nftToken][tokenId_] = true;
    }

    // function creditMint(address _nftToken, address _recipient) external returns (uint256 tokenId_) {
    //     _enfroceIsMinterRole();
    //     tokenId_ = INftToken(_nftToken).mint(_recipient);
    //     isCreditMinted[_nftToken][tokenId_] = true;
    // }
}
