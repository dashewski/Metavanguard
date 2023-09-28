// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import { ERC721HolderUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";

import { IAddressBook } from "../../interfaces/IAddressBook.sol";

contract NftReferalStaking is
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable,
    ERC721Upgradeable,
    ERC721HolderUpgradeable
{
    address public addressBook;
    uint256 public nextStakingId;
    uint256 public lockPeriod;

    mapping(address nftToken => mapping(uint256 nftId => bool)) public alreadyStaked;

    mapping(uint256 stakingId => uint256) public initialTimestamp;
    mapping(uint256 stakingId => address) public nftToken;
    mapping(uint256 stakingId => uint256) public nftId;

    event Stake(uint256 stakingId, address owner, address nftToken, uint256 nftId);
    event Unstake(uint256 stakingId, address owner, address nftToken, uint256 nftId);

    function initialize(address _addressBook, uint256 _lockPeriod) public initializer {
        addressBook = _addressBook;
        lockPeriod = _lockPeriod;
    }

    function _authorizeUpgrade(address) internal view override {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
    }

    function setLockPeriod(uint256 _newLockPeriod) external {
        IAddressBook(addressBook).enforceIsProductOwner(msg.sender);
        lockPeriod = _newLockPeriod;
    }

    function stake(address _nftToken, uint256 _nftId) external nonReentrant {
        IAddressBook(addressBook).enforceIsNftTokenContract(_nftToken);
        require(alreadyStaked[_nftToken][_nftId] == false, "already staked!");
        alreadyStaked[_nftToken][_nftId] = true;

        address owner = msg.sender;

        IERC721(_nftToken).safeTransferFrom(owner, address(this), _nftId);

        uint256 stakingId = nextStakingId++;

        _mint(owner, stakingId);

        initialTimestamp[stakingId] = block.timestamp;
        nftToken[stakingId] = _nftToken;
        nftId[stakingId] = _nftId;

        emit Stake(stakingId, owner, _nftToken, _nftId);
    }

    function unstake(uint256 _stakingId) external nonReentrant {
        address owner = ownerOf(_stakingId);
        require(owner == msg.sender, "only staking owner!");

        uint256 _initialTimestamp = initialTimestamp[_stakingId];
        require(block.timestamp > _initialTimestamp + lockPeriod, "not expired!");

        _burn(_stakingId);

        address _nftToken = nftToken[_stakingId];
        uint256 _nftId = nftId[_stakingId];

        IERC721(_nftToken).safeTransferFrom(address(this), owner, _nftId);

        emit Unstake(_stakingId, owner, _nftToken, _nftId);
    }
}
