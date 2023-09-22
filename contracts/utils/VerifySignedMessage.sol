// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


abstract contract VerifySignedMessage {
    mapping(bytes32 => bool) private _alreadyVerified;

    function _verifySignedMessage(address _server, bytes calldata _signature, bytes32 _messageHash) internal {
        require(_alreadyVerified[_messageHash] == false, "already verified!");
        require(
            SignatureChecker.isValidSignatureNow(
                _server,
                ECDSA.toEthSignedMessageHash(_messageHash),
                _signature
            ),
            "signature!"
        );
        _alreadyVerified[_messageHash] = true;
    }

    uint256[50] private __gap;
}
