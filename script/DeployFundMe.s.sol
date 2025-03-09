//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol"; //S should be upper hand
import {FundMe} from "../src/FundMe.sol"; //import the contract we want to test
import {HelperConfig} from "./HelperConfig.s.sol"; //import the contract we want to test

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig(); //before broadcast bcz we dont wanna use gas deploying this
        //before vm.start not real tx. it gonna simulate in simalate environment
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // FundMe fundMe = new FundMe(); we dont need this line as we are not going to use the contract
        // FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //this will deploy the contract
        //we have wthUsdPriceFeed from helper config so upper line not needed

        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        //when i do vm. it makes funder masg.sender again . so we need to change the test to msg.sender instead of address(this)
        vm.stopBroadcast();
        return fundMe;
    }
}
