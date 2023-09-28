// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

import { INftToken } from "../../interfaces/INftToken.sol";
import { IAddressBook } from "../../interfaces/IAddressBook.sol";
import { INftTokensObserver } from "../../interfaces/INftTokensObserver.sol";

contract NftToken is
    INftToken,
    IERC2981,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    ERC721Upgradeable
{
    address public addressBook;
    uint256 public royaltyFees;
    uint256 public nextTokenId;
    mapping(uint256 nftId => bool) public isOpened;

    function initialize(
        address _addressBook,
        string calldata _name,
        string calldata _symbol,
        uint256 _royaltyFees
    ) public initializer {
        __ERC721_init(_name, _symbol);
        addressBook = _addressBook;
        royaltyFees = _royaltyFees;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function mint(address _recipient) external returns (uint256 tokenId_) {
        IAddressBook(addressBook).enforceIsNftTokensFactory(msg.sender);
        tokenId_ = nextTokenId++;
        _safeMint(_recipient, tokenId_);
    }

    function open(uint256 _nftId) external {
        require(msg.sender == ownerOf(_nftId), "only token owner!");
        require(isOpened[_nftId] == false, "already opened");
        isOpened[_nftId] = true;

        address nftTokensObserver = IAddressBook(addressBook).nftTokensObserver();
        INftTokensObserver(nftTokensObserver).notifyOpen(_nftId);
    }

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _nftId,
        uint256
    ) internal override {
        address nftTokensObserver = IAddressBook(addressBook).nftTokensObserver();
        INftTokensObserver(nftTokensObserver).notifyChangeOwner(_nftId, _from, _to);
    }

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = IAddressBook(addressBook).treasury();
        royaltyAmount = (salePrice * royaltyFees) / 10000;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Upgradeable, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
