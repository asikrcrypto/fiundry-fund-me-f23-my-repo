//SPDX-License-Identifier: MIT

//1. Deploy mocks when we are in local anvil chain
//2. keep track of different address across different chain
// like, sepolia eth/usd , mainnet eth/usd addresses

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //if we are on local anvil , we deploy mock
    //otherwise grab the existing address from the live network

    //if we need  price feed address , vrf address , gas price
    //so it is good idea to turn this config into its own type

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig; //to send the addresses, gas price to the deploy secction . to set the addresses here we will use constructor

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
        //now we just need address only one
    }

    constructor() {
        if (block.chainid == 11155111) {
            //chain id of sepolia is updated not according to the video
            //solidity has lot of global variable on of this block.chain id . chain.id refers chains current id
            //ex, eth mainnent has chain id 1, sepolia has 1115511,BSC 56 go to chainlist.com to get the chain id
            activeNetworkConfig = getSepoliaEthConfig(); //so its says if we are on sepolia use this sepolia config
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetConfig();
        } else activeNetworkConfig = getOrCreateAnvilEthConfig();
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        //it wil return configuration for everything we need in mainnet
        //in mainnet we need pricefeed address
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        //since struct we {} can say type and object . we could also not use it

        return mainnetConfig;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //it wil return configuration for everything we need sepolia, or in any chain
        //in sepolia we need pricefeed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        //since struct we {} can say type and object . we could also not use it

        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig()
        public
        returns (
            //changing name to getOrCreateAnvilEthConfig bcz it also creating
            NetworkConfig memory
        )
    {
        //also need pricefeed address

        // 1. deploy the mocks
        //2.return the mock addresses
        //mock is like real contract but it actually we own , we can control it

        if (activeNetworkConfig.priceFeed != address(0)) {
            //now we can deploy with forge test bcz we have our own priceFeed . so teting version can be done

            //activeNetworkConfig.priceFeed means activeNetworkConfig struct's priceFeed value
            return activeNetworkConfig;
        } //if we deployed and have pricefeed then dont need to deploy again

        vm.startBroadcast(); //to access in vm. it cannot be pure function and have to do contract HelperConfig is Script
        //let deploy our own price feed

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); //8 decimals and 2000 usd
        //In our mock contract there is a constructor which takes 2 arguments , 8 and 2000e8

        vm.stopBroadcast();
        // we need our own pricefeed for anvil . so we need contract
        //so creating test/mocks folder and here will create all testing contracts to differentiate from our main contracts
        //now create mocks/MockV3Aggregator.sol and copy code from f-23 test repo . it has all codebase for price feed
        //here is a mock price feed contract in lib/chainlink-brownie../contract but it is for older version solidity .

        //we can also use updateAnswer function to update the price feed
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
