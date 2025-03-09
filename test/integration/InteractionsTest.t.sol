//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "../../lib/forge-std/src/Test.sol"; //standard packages and contracts to make test easier in foundry
import {FundMe} from "../../src/FundMe.sol"; //import the contract we want to test
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; //import the script we want to run
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol"; //import the script we want to run

//Test.sol is big , we can use console to print something out from our test
contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether; //0. dont work but it is like 1e7
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        //  address funder = fundMe.getFunder(0);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}
