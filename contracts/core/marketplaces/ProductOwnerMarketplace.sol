// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { INftToken } from "../../interfaces/INftToken.sol";
import { IAddressBook } from "../../interfaces/IAddressBook.sol";
import { INftTokensFactory } from "../../interfaces/INftTokensFactory.sol";
import { VerifySignedMessage } from "../../utils/VerifySignedMessage.sol";

contract ProductOwnerMarketplace is
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    VerifySignedMessage
{
    using SafeERC20 for IERC20Metadata;

    address public addressBook;
    address public server;

    mapping(address payToken => uint256) public defaultPrice;
    mapping(address payToken => mapping(address nftToken => uint256)) public price;

    event Buy(address buyer, address nftToken, uint256 nftId, address payToken, uint256 price);
    event DiscountedBuy(
        address buyer,
        address nftToken,
        uint256 nftId,
        address payToken,
        uint256 discount,
        uint256 discountedPrice,
        uint256 fullPrice
    );

    function initialize(
        address _addressBook,
        address _server
    ) public initializer {
        addressBook = _addressBook;
        server = _server;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function setPrice(address _payToken, address _nftToken, uint256 _newPrice) external {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
        price[_payToken][_nftToken] = _newPrice;
    }

    function setDefaultPrice(address _payToken, uint256 _newDefaultPrice) external {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
        defaultPrice[_payToken] = _newDefaultPrice;
    }

    function safeGetPrice(address _nftToken, address _payToken) public view returns (uint256) {
        uint256 _price = price[_payToken][_nftToken];
        if (_price == 0) _price = defaultPrice[_payToken];
        require(_price > 0, "price == 0");
        return _price;
    }

    function buy(address _nftToken, address _payToken) external nonReentrant {
        IAddressBook _addressBook = IAddressBook(addressBook);
        _addressBook.enforceIsNftTokenContract(_nftToken);

        uint256 _price = safeGetPrice(_nftToken, _payToken);

        IERC20Metadata(_payToken).safeTransferFrom(msg.sender, _addressBook.treasury(), _price);

        address nftTokensFactory = _addressBook.nftTokensFactory();
        uint256 nftId = INftTokensFactory(nftTokensFactory).regularMint(_nftToken, msg.sender);

        emit Buy(msg.sender, _nftToken, nftId, _payToken, _price);
    }

    function discountedBuy(
        address _nftToken,
        address _payToken,
        uint256 _discount,
        bytes32 _uuidHash,
        uint256 _exireiesTimestamp,
        bytes calldata _signature
    ) external nonReentrant {
        require(block.timestamp < _exireiesTimestamp, "signature expiried!");
        _verifySignedMessage(
            server,
            _signature,
            keccak256(
                abi.encodePacked(
                    this.discountedBuy.selector,
                    msg.sender,
                    _nftToken,
                    _discount,
                    _uuidHash,
                    _exireiesTimestamp
                )
            )
        );

        IAddressBook _addressBook = IAddressBook(addressBook);
        _addressBook.enforceIsNftTokenContract(_nftToken);

        uint256 _price = safeGetPrice(_nftToken, _payToken);
        uint256 discountedPrice = _price - (_price * _discount) / 10000;

        if (discountedPrice > 0) {
            IERC20Metadata(_payToken).safeTransferFrom(
                msg.sender,
                _addressBook.treasury(),
                discountedPrice
            );
        }

        address nftTokensFactory = _addressBook.nftTokensFactory();
        uint256 nftId = INftTokensFactory(nftTokensFactory).discountedMint(_nftToken, msg.sender);

        emit DiscountedBuy(
            msg.sender,
            _nftToken,
            nftId,
            _payToken,
            _discount,
            discountedPrice,
            _price
        );
    }
}
