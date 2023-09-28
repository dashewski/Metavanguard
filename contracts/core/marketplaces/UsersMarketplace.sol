// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC2981 } from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import { ERC721HolderUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";

import { IAddressBook } from "../../interfaces/IAddressBook.sol";

contract UsersMarketplace is ReentrancyGuardUpgradeable, UUPSUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20 for IERC20Metadata;

    address public addressBook;
    
    uint256 public nextSellId;

    mapping(uint256 sellId => address) public seller;
    mapping(uint256 sellId => address) public itemAddress;
    mapping(uint256 sellId => uint256) public itemId;
    mapping(uint256 sellId => uint256) public price;
    mapping(uint256 sellId => address) public payToken;
    mapping(uint256 sellId => address) public buyer;

    event PutSale(
        uint256 sellId,
        address seller,
        address itemAddress,
        uint256 itemId,
        address payToken,
        uint256 price
    );
    event UpdateSale(
        uint256 sellId,
        address oldPayToken,
        uint256 oldPrice,
        address newPayToken,
        uint256 newPrice
    );
    event CloseSell(uint256 sellId);
    event Buy(uint256 sellId, address buyer);

    function initialize(address _addressBook) public initializer {
        addressBook = _addressBook;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function sellInfo(
        uint256 _sellId
    )
        external
        view
        returns (
            address seller_,
            address itemAddress_,
            uint256 itemId_,
            uint256 price_,
            address payToken_,
            address buyer_
        )
    {
        seller_ = seller[_sellId];
        itemAddress_ = itemAddress[_sellId];
        itemId_ = itemId[_sellId];
        price_ = price[_sellId];
        payToken_ = payToken[_sellId];
        buyer_ = buyer[_sellId];
    }

    function putSale(
        address _itemAddress,
        uint256 _itemId,
        address _payToken,
        uint256 _price
    ) external nonReentrant {
        IAddressBook _addressBook = IAddressBook(addressBook);
        _addressBook.enforceIsNftTokenContract(_itemAddress);
        _addressBook.enforceIsPayToken(_payToken);
        require(_price > 0, "price!");

        uint256 sellId = nextSellId++;
        address _seller = msg.sender;

        seller[sellId] = _seller;
        itemAddress[sellId] = _itemAddress;
        itemId[sellId] = _itemId;
        price[sellId] = _price;
        payToken[sellId] = _payToken;

        emit PutSale(sellId, _seller, _itemAddress, _itemId, _payToken, _price);
    }

    function updateSell(
        uint256 _sellId,
        address _newPayToken,
        uint256 _newPrice
    ) external nonReentrant {
        address _seller = seller[_sellId];
        require(msg.sender == _seller, "only seller!");

        IAddressBook(addressBook).enforceIsPayToken(_newPayToken);
        require(_newPrice > 0, "new price!");

        address oldPayToken = payToken[_sellId];
        uint256 oldPrice = price[_sellId];

        payToken[_sellId] = _newPayToken;
        price[_sellId] = _newPrice;

        emit UpdateSale(_sellId, oldPayToken, oldPrice, _newPayToken, _newPrice);
    }

    function buy(uint256 _sellId) external nonReentrant {
        address _seller = seller[_sellId];
        require(_seller != address(0), "sell not exists!");
        require(buyer[_sellId] == address(0), "already bought!");

        IERC20Metadata _payToken = IERC20Metadata(payToken[_sellId]);
        uint256 _price = price[_sellId];

        _payToken.safeTransferFrom(msg.sender, address(this), _price);

        address _itemAddress = itemAddress[_sellId];
        uint256 _itemId = itemId[_sellId];

        (address receiver, uint256 royaltyAmount) = IERC2981(_itemAddress).royaltyInfo(
            _itemId,
            _price
        );

        if (royaltyAmount > 0) _payToken.safeTransfer(receiver, royaltyAmount);
        _payToken.safeTransfer(_seller, _price - royaltyAmount);

        address _buyer = msg.sender;
        buyer[_sellId] = _buyer;

        IERC721(_itemAddress).safeTransferFrom(address(this), _buyer, _itemId);

        emit Buy(_sellId, _buyer);
        emit CloseSell(_sellId);
    }

    function withdrawSale(uint256 _sellId) external nonReentrant {
        address _seller = seller[_sellId];
        require(msg.sender == _seller, "only seller!");
        require(buyer[_sellId] == address(0), "already bought!");

        IERC721(itemAddress[_sellId]).safeTransferFrom(address(this), _seller, itemId[_sellId]);

        buyer[_sellId] = _seller;

        emit CloseSell(_sellId);
    }
}
