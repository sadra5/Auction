// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.2;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract auction {

    address public nftAddress;
    address payable public owner;
    uint256 public highestBid;
    address public highestBidder;
    uint256 startTime;
    uint256 endTime = 10;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this method");
        _;
    }

    mapping(address => uint256) public bidders;

    constructor (address _nftAddress) {
        nftAddress = _nftAddress;
        owner = payable(msg.sender);
    }

    function addBid() public payable {

        require(startTime > 0, "The auction has not started yet");
        require(block.timestamp < endTime, "The auction has ended");
        require(msg.value > 0, "bid must be up zero");
        require((bidders[msg.sender] + msg.value) > highestBid, "there is a higer bid");

        bidders[msg.sender] += msg.value;
        highestBid = bidders[msg.sender];
        highestBidder =  msg.sender;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function refund(address payable _bidder) public payable onlyOwner{
        if ( bidders[_bidder] > 0) {
            _bidder.transfer(bidders[_bidder]);
        }
    }

    function list(uint256 _nftID) public onlyOwner {
        
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);

        startTime = block.timestamp;
        endTime += startTime;
    }

    function finalaizeAuction(uint256 _nftID) public onlyOwner {
        
        require(block.timestamp >= endTime, "The auction has not ended yet");

        owner.transfer(highestBid);

        IERC721(nftAddress).transferFrom(address(this), highestBidder, _nftID);
    }
}