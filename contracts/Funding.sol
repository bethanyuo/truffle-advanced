pragma solidity ^0.5.0;

contract Funding {
    address payable public owner;
    uint public finishesAt;
    uint public goal;
    uint public raised;
    mapping (address => uint) public balances;
    //event withdrawEvent(address _who, uint _amount);
    //event donateEvent(address _who, uint _amount);

    constructor(uint _duration, uint _goal) public {
      owner = msg.sender;
      finishesAt = now + _duration;
      goal = _goal;
    }

    modifier onlyOwner() {
          require(owner == msg.sender, "You must be the owner");
          _;
      }

    modifier onlyFunded() {
        require(isFunded(), "Not funded");
        _;
    }

    modifier onlyNotFunded() {
        require(!isFunded(), "Is funded");
        _;
    }

    modifier onlyNotFinished() {
        require(!isFinished(), "Donation window already finished.");
        _;
    }

    modifier onlyFinished() {
        require(isFinished(), "Donation window is not finished/timed out");
        _;
    }

    function refund() public onlyFinished onlyNotFunded {
        uint amount = balances[msg.sender];
        require(amount > 0, "Not enough balance to transfer");

        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function isFinished() public view returns(bool) {
        return finishesAt <= now;
    }

    function donate() public onlyNotFinished payable {
        //emit donateEvent(msg.sender,msg.value);
        balances[msg.sender] += msg.value;
        raised += msg.value;
    }

    function isFunded() view public returns (bool) {
        return raised >= goal;
    }

    function withdraw() public onlyOwner onlyFunded {
        //emit withdrawEvent(msg.sender,address(this).balance);
        owner.transfer(address(this).balance);
         //msg.sender.transfer(msg.sender.balance);
    }

}
