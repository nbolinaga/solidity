// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;

contract CryptoKids {
    // owner DAD
    address owner;

    event LogKidFundingReceived(
        address addr,
        uint amount,
        uint contractBalance
    );

    constructor() {
        owner = msg.sender;
    }

    // define kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    Kid[] public kids;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }

    // add kid to contract
    function addKid(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        uint releaseTime,
        uint amount
    ) public onlyOwner {
        kids.push(
            Kid(walletAddress, firstName, lastName, releaseTime, amount, false)
        );
    }

    //get balance
    function balanceOf() public view returns (uint) {
        return address(this).balance;
    }

    // deposit funds to contract, specifically to kids account
    function deposit(address walletAddress) public payable onlyOwner {
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private {
        uint i = getIndex(walletAddress);
        kids[i].amount += msg.value;
        emit LogKidFundingReceived(walletAddress, msg.value, balanceOf());
    }

    //kid check if can withdraw
    function availableToWithdraw(address walletAddress) public returns (bool) {
        uint i = getIndex(walletAddress);
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
            return true;
        }
        return false;
    }

    // withdraw money
    function withdraw(address payable walletAddress) public payable {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "You are not the owner");
        require(
            kids[i].canWithdraw == true,
            "You are not the age to withdraw yet"
        );
        kids[i].walletAddress.transfer(kids[i].amount);
    }

    // get the index of the kid in the array (CAREFUL WITH FORLOOPS)
    function getIndex(address walletAddress) private view returns (uint) {
        for (uint i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 999;
    }
}
