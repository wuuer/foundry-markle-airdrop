// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MerkelAirdrop} from "../../src/MerkelAirdrop.sol";
import {BagleToken} from "../../src/BagleToken.sol";
import {Deploy} from "../../script/Deploy.s.sol";

contract MerkleAirdropTest is Test {
    MerkelAirdrop private merkelAirdrop;
    BagleToken private bagleToken;

    bytes32 private constant USERPROOFONE = 0x23929ac3ff4a5d4c54ce9e00713ea4fe5dc4c5f3ad9667160480cbb003b5307d;
    bytes32 private constant USERPROOFTWO = 0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89;

    bytes32 private constant ANOTHERUSERONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant ANOTHERUSERTWO = 0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89;

    bytes32[] private proofs = [USERPROOFONE, USERPROOFTWO];
    bytes32[] private anotherProofs = [ANOTHERUSERONE, ANOTHERUSERTWO];
    uint256 private constant CLAIM_AMOUNT = 25 ether;
    address private user;
    uint256 private userPrivateKey;
    address private anotherUser;
    uint256 private anotherUserPrivateKey;

    function setUp() external {
        Deploy deploy = new Deploy();
        (bagleToken, merkelAirdrop) = deploy.run();
        (user, userPrivateKey) = makeAddrAndKey("user");
        (anotherUser, anotherUserPrivateKey) = makeAddrAndKey("anotherUser");
        //console.log(user);
        //console.log(anotherUser);
    }

    function testUserCanClaim() public {
        uint256 startingBalance = bagleToken.balanceOf(user);
        vm.startPrank(user);

        // self sign
        bytes32 digest = merkelAirdrop.getMessageHash(user, CLAIM_AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        merkelAirdrop.claim(user, CLAIM_AMOUNT, proofs, v, r, s);
        uint256 endingBalance = bagleToken.balanceOf(user);
        assert(endingBalance - startingBalance == CLAIM_AMOUNT);
        vm.stopPrank();
    }

    function testUserCantClaimTwice() public {
        vm.startPrank(user);

        // self sign
        bytes32 digest = merkelAirdrop.getMessageHash(user, CLAIM_AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        merkelAirdrop.claim(user, CLAIM_AMOUNT, proofs, v, r, s);
        vm.expectRevert(MerkelAirdrop.MerkelAirdrop__AlreadyClaimed.selector);
        merkelAirdrop.claim(user, CLAIM_AMOUNT, proofs, v, r, s);
        vm.stopPrank();
    }

    function testUserCantClaim() public {
        (address newUser, uint256 newUserPrivateKey) = makeAddrAndKey("new user");
        vm.startPrank(user);
        // self sign
        bytes32 digest = merkelAirdrop.getMessageHash(newUser, CLAIM_AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(newUserPrivateKey, digest);

        vm.expectRevert(abi.encodeWithSelector(MerkelAirdrop.MerkelAirdrop__NotAClaimer.selector, newUser));
        merkelAirdrop.claim(newUser, CLAIM_AMOUNT, proofs, v, r, s);

        vm.stopPrank();
    }

    function testUserCanClaimForAnotherUser() public {
        uint256 startingBalance = bagleToken.balanceOf(anotherUser);
        vm.startPrank(user);
        // aother user sign
        bytes32 digest = merkelAirdrop.getMessageHash(anotherUser, CLAIM_AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(anotherUserPrivateKey, digest);

        merkelAirdrop.claim(anotherUser, CLAIM_AMOUNT, anotherProofs, v, r, s);
        uint256 endingBalance = bagleToken.balanceOf(anotherUser);
        assert(endingBalance - startingBalance == CLAIM_AMOUNT);
        vm.stopPrank();
    }
}
