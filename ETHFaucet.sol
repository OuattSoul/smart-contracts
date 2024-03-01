// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.0;

contract ETHFaucet {

    address public owner ;
    uint256 public amountAllowed = 1 * 10 ** 18;

    mapping(address => uint) public lockTime;
    mapping(address => uint) public donators;

    event FundSent(address indexed _receiver, string indexed _message);
    event HasDonated(address indexed _sender, string indexed _message);

    constructor() payable  {
        owner = msg.sender;
    }


    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }


    //receive() external payable {}

    //fallback() external payable {}

    function faucetBalance() external view returns (uint256){
        return address(this).balance;
    }

    function setNewOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setNewAmountAllowed(uint256 _newAmountAllowed) public onlyOwner {
        amountAllowed = _newAmountAllowed;
    }

    function donateToFaucet() public payable {

        donators[msg.sender] = msg.value;
        emit HasDonated(msg.sender, "Donation happened");
    }


    function requestFaucet(address payable _receiver) public {
        
        require(block.timestamp > lockTime[msg.sender], "You already received funds. Come back tomorrow");

        (bool sucess, ) = _receiver.call{value: amountAllowed}("");
        require(sucess, "Request failed to sent funds");
        

        lockTime[msg.sender] = block.timestamp + 1 days;
        emit FundSent(_receiver, "Funds sent");
    }


    


}