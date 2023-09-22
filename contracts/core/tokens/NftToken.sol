// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { INftToken } from "../../interfaces/INftToken.sol";
import { IAddressBook } from "../../interfaces/IAddressBook.sol";
import { INftTokensObserver } from "../../interfaces/INftTokensObserver.sol";

contract NftToken is INftToken, ReentrancyGuardUpgradeable, UUPSUpgradeable, ERC721Upgradeable {
    address public addressBook;
    uint256 public nextTokenId;

    function initialize(
        address _addressBook,
        string calldata _name,
        string calldata _symbol
    ) public initializer {
        __ERC721_init(_name, _symbol);
        addressBook = _addressBook;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function mint(address _recipient) external returns (uint256 tokenId_) {
        IAddressBook(addressBook).enforceIsProductOwnerMarketplace(msg.sender);
        tokenId_ = nextTokenId++;
        _safeMint(_recipient, tokenId_);
    }

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _nftId,
        uint256
    ) internal override {
        address nftTokensObserver = IAddressBook(addressBook).nftTokensObserver();
        INftTokensObserver(nftTokensObserver).notify(_nftId, _from, _to);
    }
}
