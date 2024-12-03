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
    address public owner;

    mapping(address => uint256) public bidders;

    uint256 public highestBid;
    address public highestBidder;

    uint256 startTime = block.timestamp;
    uint256 endTime = startTime + 10;

    constructor (address _nftAddress) {
        nftAddress = _nftAddress;
        owner = msg.sender;
    }

    function addBid() public payable {

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

    function refund(address payable _bidder) public payable {
        if ( bidders[_bidder] > 0) {
            _bidder.transfer(bidders[_bidder]);
        }
    }


}