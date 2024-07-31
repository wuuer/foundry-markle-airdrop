// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkelAirdrop} from "../src/MerkelAirdrop.sol";
import {BagleToken} from "../src/BagleToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract Deploy is Script {
    function run() external returns (BagleToken bagleToken, MerkelAirdrop merkelAirdrop) {
        HelperConfig config = new HelperConfig();
        (uint256 BAGLE_INITIAL_SUPPLY, bytes32 merkleRoot, uint256 deployerKey) = config.activeNetworkConfig();

        vm.startBroadcast(deployerKey);

        bagleToken = new BagleToken();
        merkelAirdrop = new MerkelAirdrop(merkleRoot, bagleToken);

        bagleToken.mint(bagleToken.owner(), BAGLE_INITIAL_SUPPLY);
        bagleToken.transfer(address(merkelAirdrop), BAGLE_INITIAL_SUPPLY);

        vm.stopBroadcast();
    }
}
