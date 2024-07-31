// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkelAirdrop} from "../src/MerkelAirdrop.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Deploy} from "../../script/Deploy.s.sol";

contract ClaimAirdrop is Script {
    address CLAIMING_ANVIL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address CLAIMING_AMOUNT = 25 ether;
    bytes32 private constant USERPROOFONE = 0x0c7ef881bb675a5858617babe0eb12b538067e289d35d5b044ee76b79d335191;
    bytes32 private constant USERPROOFTWO = 0x12706eda1eca62ab0041262b3cba9287ef9a4ecb3dc0d527afcb9384e9ce1273;
    // use command to generate SIGNATURE
    bytes private constant SIGNATURE = hex"fd27";

    bytes32[] private proofs = [USERPROOFONE, USERPROOFTWO];

    function run() external {
        Deploy deploy = new Deploy();
        (, MerkelAirdrop merkelAirdrop) = deploy.run();
        claimAirdrop(merkelAirdrop);
    }

    function splitSignature(bytes memory sig) private returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65,"invalid signature length");
        assembly {
            r := mload(add(sig,32))
            s := mload(add(sig,64))
            v := byte(0,mload(add(sig,96)))
        }
    }

    function claimAirdrop(MerkelAirdrop merkelAirdrop) public {
        bytes32 digest = merkelAirdrop.getMessageHash(CLAIMING_ADDRESS, 25e18);
        (uint8 v, bytes32 r, bytes32 s) = ;
        merkelAirdrop.claim(CLAIMING_ANVIL_ADDRESS, CLAIMING_AMOUNT, proofs, v, r, s);
    }
}
