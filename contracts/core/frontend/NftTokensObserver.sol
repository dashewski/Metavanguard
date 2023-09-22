// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { INftTokensObserver } from "../../interfaces/INftTokensObserver.sol";
import { IAddressBook } from "../../interfaces/IAddressBook.sol";

contract NftTokensObserver is INftTokensObserver, UUPSUpgradeable {
    address public addressBook;

    event ChangeOwner(address nftToken, uint256 nftId, address from, address to);

    function initialize(address _addressBook) public initializer {
        addressBook = _addressBook;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function notify(uint256 _nftId, address _from, address _to) external {
        IAddressBook(addressBook).enforceIsNftTokenContract(msg.sender);
        emit ChangeOwner(msg.sender, _nftId, _from, _to);
    }
}
