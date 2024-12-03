const { expect } = require('chai');
const { ethers, network } = require('hardhat');

const tokens = (n) => {
    return ethers.parseUnits(n.toString(), 'ether')
}

describe("Auction", () => {
    let auction, bidder1, bidder2;
    
    beforeEach ( async () => {

        const Auction = await ethers.getContractFactory("auction");
        [bidder1, bidder2] = await ethers.getSigners()
    
        auction = await Auction.deploy();
    
        // await auction.deployed();

        transaction = await auction.connect(bidder2).addBid({ value: tokens(1)})
        await transaction.wait()
    
        transaction = await auction.connect(bidder1).addBid({ value : tokens(2) })
        await transaction.wait()

        // transaction = await auction.connect(bidder1).addBid({ value: tokens(3)})
        // await transaction.wait()

    })

    it("adding bidds", async() => {
        const result = await auction.bidders(bidder1)
        expect(result).to.be.equal(tokens(2))

    })

    it("increasing the bid", async() => {

        transaction = await auction.connect(bidder1).addBid({ value: tokens(3)})
        await transaction.wait()

        const result = await auction.bidders(bidder1)
        expect(result).to.be.equal(tokens(5))
    })

    it("bid must be up to zero", async() => {
        await expect(auction.addBid({ value: tokens(0)})).to.be.revertedWith("bid must be up zero")
    })

    it("bid must be higher than other bids", async() => {
        await expect(auction.connect(bidder2).addBid({ value: tokens(1)})).to.be.revertedWith("there is a higer bid")
    })

    it("saving highest bid and highest bidder", async() => {
        const result = await auction.bidders(bidder1)

        expect(result).to.be.equal(await auction.highestBid())
        expect(bidder1).to.be.equal(await auction.highestBidder())
    })
    
    it("adding bids in timeline", async() => {
        await network.provider.send("evm_increaseTime", [11]);
        await network.provider.send("evm_mine");

        await expect(auction.addBid()).to.be.revertedWith("The auction has ended")
    } )

    it("refunding addresses didn't win", async() => {
        const txAmount = await auction.bidders(bidder2.address);
        await expect(auction.refund(bidder2)).to.changeEtherBalances([auction, bidder2], [-txAmount, txAmount])
    })
})

