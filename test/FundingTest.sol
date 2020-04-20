pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/Funding.sol";
import "truffle/DeployedAddresses.sol";

contract FundingTest {
  uint public initialBalance = 10 ether;
  Funding funding;

  function() external payable {}

  function beforeEach() public {
      funding = new Funding(1 days, 100 finney);
  }

  function testWithdrawalByOwner() public {
        uint initBalance = address(this).balance;
        funding.donate.value(50 finney)();

        bytes memory bs = abi.encodePacked(keccak256("withdraw()"));
        (bool result,) = address(funding).call(bs);
        Assert.equal(result, false, "Allows for withdrawal before reaching the goal");

        funding.donate.value(50 finney)();
        Assert.equal(address(this).balance, initBalance - 100 finney, "Balance before withdrawal doesn't correspond to sum of donations");

        bs = abi.encodePacked(keccak256("withdraw()"));
        (result,) = address(funding).call(bs);
        Assert.equal(result, true, "Doesn't allow for withdrawal after reaching the goal");
        Assert.equal(address(this).balance, initBalance,"Balance after withdrawal doesn't correspond to sum of donations");
    }

    function testWithdrawalByNotOwner() public {
          // Make sure to check what goal is set in migration (DEFAULT: 100 finney)
          funding = Funding(DeployedAddresses.Funding());
          funding.donate.value(100 finney);

          bytes memory bs = abi.encodePacked(keccak256("withdraw()"));
          (bool result,) = address(funding).call(bs);
          Assert.equal(result, false, "Allows for withdrawal by not an owner");
    }

    function testDonatingAfterTimeIsUp() public {
          Funding newFund = new Funding(0, 100 finney);
          bytes memory bs = abi.encodePacked(keccak256("donate"));

          (bool result,) = address(newFund).call.value(10 finney)(bs);
          Assert.equal(result, false, "Allows for donations when time is up");
    }

    function testTrackingDonatorsBalance() public {
          // Funding funding = new Funding();
          funding.donate.value(5 finney)();
          funding.donate.value(15 finney)();
          Assert.equal(funding.balances(address(this)), 20 finney, "Donator balance is different from sum of donations");
    }

    function testAcceptingDonations() public {
          //Funding funding = new Funding();
          Assert.equal(funding.raised(),0, "Initial raised amount is different from 0");

          funding.donate.value(10 finney)();
          funding.donate.value(20 finney)();
          Assert.equal(funding.raised(),30 finney,"Raised amount is different from sum of donations");
    }

    function testSettingAnOwnerOfDeployedContract() public {
            Funding newFund = Funding(DeployedAddresses.Funding());
            Assert.equal(newFund.owner(), msg.sender,"The owner is different from the deployed");
    }

    function testSettingAnOwnerDuringCreation() public {
            //Funding funding = new Funding();
            Assert.equal(funding.owner(), address(this), "The owner is different from the deployer");
    }
}
