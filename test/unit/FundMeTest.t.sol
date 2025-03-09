//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol"; //standard packages and contracts to make test easier in foundry
import {FundMe} from "../../src/FundMe.sol"; //import the contract we want to test
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; //import the script we want to run

//Test.sol is big , we can use console to print something out from our test
contract FundMeTest is Test {
    //we want to test our contract is doing what we want to do
    //so firstly we gonna deploy contract
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether; //0. dont work but it is like 1e7
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        //us calling-> FundmeTest -> FundMe . so FundMeTest becoming owner address
        //instead this to change with deploy we do next line ; fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //deploy the contract . we are saying our FundMe variable of FundMe variable is a new FundMe contract. if we use console.log

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    //setup always run first then testDemo
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18); //assertEq is a function from Test.sol

        //deploy contract
        //call the function
        //check the result
        //assert the result
        //  console.log(number); //it should print out the number
    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.i_owner()); //it should print out the address of the owner
        // console.log(msg.sender);

        //so we use address(this) instead of msg.sender

        assertEq(fundMe.getOwner(), /*address(this))*/ msg.sender); //this is the address of the contract
    }

    function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        //if testing fails use cheatcode from book.getfoundry cheatcode under test section
        //to know more in book reference cheatcode reference /assertion/expectRevert

        vm.expectRevert(); //hey next line ,should revert
        //equivalent to assert(this tx fails/revert)
        //uint256 cat =1;//if this line is code then this will fail if this line doesn't fail
        //to test the line upper try running forge test --mt testFundFailsWithoutEnoughEth .for single test and it will fail bcz upper line din't fail
        fundMe.fund(); //this should pass.0 value so line failing
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //the next tx will be sent by user
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFunderToArrayOfFunders() public funded {
        // vm.prank(USER); //the next tx will be sent by user
        // fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        //  vm.prank(USER); //the next tx will be sent by user

        //added modifier   fundMe.fund{value: SEND_VALUE}();//user funding

        vm.expectRevert();
        vm.prank(USER); //v.expect revert next line but ir will not revert vm.prank instead its next line
        fundMe.withdraw(); //user withdrawing .but it is nor owner
    }

    function testWithdrawWithASingleFunder() public funded {
        //arrange
        //Act
        //assert .. whenever he will think of a test

        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //In Solidity, balance is a property of any address that returns the amount of ETH (in wei) stored in that address.
        uint256 startingfundMeBalance = address(fundMe).balance;
        //act
        // uint256 gasStart = gasleft(); //we send 1000 gas//THIS FUNCTION IS BUILT IN TELLS HOW MUCH GAS LEFT
        vm.txGasPrice(GAS_PRICE); //CHEAT CODE
        vm.prank(fundMe.getOwner()); //the next tx will be sent by owner
        fundMe.withdraw(); //used gas
        //  uint256 gasEnd = gasleft(); //now have gas 800 . we sent more gas than we need so difference is the gas used by the fun.
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingfundMeBalance
        );
    }

    function testWithdrawMultipleFunders() public funded {
        //arrange
        uint160 numberOfFunders = 10; //we have to use 160 in case of address representing number bcz address is 160
        uint160 startingFunderIndex = 1; //0 address sometimes fails so starting from 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm. deal we can use both these but we can do the following also
            //  hoax(<someaddress>,SEND_VALUE) , another cheat code create address with eth
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner()); //there is startprank and stopprank also. in between address is the start address
        fundMe.withdraw();
        //assert
        assert(address(fundMe).balance == 0);
        assert(
            fundMe.getOwner().balance ==
                startingOwnerBalance + startingfundMeBalance
        );
    }

    function testWithdrawMultipleFundersCheaper() public funded {
        //arrange
        uint160 numberOfFunders = 10; //we have to use 160 in case of address representing number bcz address is 160
        uint160 startingFunderIndex = 1; //0 address sometimes fails so starting from 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm. deal we can use both these but we can do the following also
            //  hoax(<someaddress>,SEND_VALUE) , another cheat code create address with eth
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner()); //there is startprank and stopprank also. in between address is the start address
        fundMe.cheaperWithdraw();
        //assert
        assert(address(fundMe).balance == 0);
        assert(
            fundMe.getOwner().balance ==
                startingOwnerBalance + startingfundMeBalance
        );
    }
}
//-vv /-vvvvv specify visibility of logging in this test
