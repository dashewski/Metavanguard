// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { ITreasury } from "../interfaces/ITreasury.sol";
import { IAddressBook } from "../interfaces/IAddressBook.sol";

contract Treasury is ITreasury, UUPSUpgradeable {
    address public addressBook;

    function initialize(address _addressBook) public initializer {
        addressBook = _addressBook;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function withdraw(address _token, uint256 _amount, address _recipient) external {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);

        require(_amount > 0, "Treasury: withdrawn amount is zero!");
        bool success = IERC20Metadata(_token).transfer(_recipient, _amount);
        require(success, "ERC20 transfer failed!");
    }
}
