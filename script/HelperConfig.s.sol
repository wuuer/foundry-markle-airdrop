// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 BAGLE_INITIAL_SUPPLY;
        bytes32 merkleRoot;
        uint256 deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        // sepolia online testnet
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        // anvil local testnet
        else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() private view returns (NetworkConfig memory) {
        return NetworkConfig({BAGLE_INITIAL_SUPPLY: 100 ether, merkleRoot: 0x0, deployerKey: vm.envUint("PRIVATE_KEY")});
    }

    function getAnvilEthConfig() private view returns (NetworkConfig memory) {
        if (activeNetworkConfig.BAGLE_INITIAL_SUPPLY != 0) {
            return activeNetworkConfig;
        }

        return NetworkConfig({
            BAGLE_INITIAL_SUPPLY: 100 ether,
            merkleRoot: 0x3034b884866cb63ea52192a6c925a7cada6a380b8d0922b6029897bffbd0ea16,
            deployerKey: DEFAULT_ANVIL_KEY
        });
    }
}
