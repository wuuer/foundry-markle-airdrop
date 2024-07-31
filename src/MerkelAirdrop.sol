// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MerkelAirdrop is EIP712, ReentrancyGuard {
    using SafeERC20 for IERC20;

    error MerkelAirdrop__NotAClaimer(address account);
    error MerkelAirdrop__AlreadyClaimed();
    error MerkelAirdrop__InvalidSignature();

    event claimSuccess(address indexed account);

    address[] private s_claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_UsersClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkelAirdrop", "v1.0") {
        i_airdropToken = airdropToken;
        i_merkleRoot = merkleRoot;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
        nonReentrant
    {
        if (s_UsersClaimed[account]) {
            revert MerkelAirdrop__AlreadyClaimed();
        }

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkelAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__NotAClaimer(account);
        }

        emit claimSuccess(account);

        // fail if the user rejects it
        i_airdropToken.safeTransfer(account, amount);

        s_UsersClaimed[account] = true;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdeopToken() external view returns (address) {
        return address(i_airdropToken);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
        // EIP-712 encode
        _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        private
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);

        return actualSigner == account;
    }
}
