// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract SimpleAuction {
	// Parameters of the auction.
	address payable public beneficiary;
	// TODO add auction parameters here
	uint public biddingEnd;
	bool ended;
	mapping(address => uint) public pendingReturns;

	// Current state of the auction.
	address public highestBidder;
	uint public highestBid;
	// TODO add state variables here

	// Events that will be emitted on changes.
	// TODO add events here
	event HighestBidIncreased(address bidder, uint amount);
	event AuctionEnded(address winner, uint amount);

	// Errors that describe failures.
	// TODO add errors here
	error BidNotHighEnough(uint highestBid);
	error AuctionEndAlreadyCalled();
	error TooLate(uint time);
	error TooEarly(uint time);

	// Modifiers
	// TODO add modifiers here
	modifier onlyBefore(uint time) {
		if (block.timestamp >= time) revert TooLate(time);
		_;
	}
	modifier onlyAfter(uint time) {
		if (block.timestamp <= time) revert TooEarly(time);
		_;
	}

	/// Create a simple auction that ends at `_biddingEnd`
	/// on behalf of the beneficiary address `_beneficiary`.
	constructor(uint _biddingEnd, address payable _beneficiary) {
		// TODO store the beneficiary address
		beneficiary = _beneficiary;
		// TODO store when the bidding ends
		biddingEnd = _biddingEnd;
	}

	/// Bid on the auction with the value sent
	/// together with this transaction.
	/// The value will only be refunded if the
	/// auction is not won.
	function bid() external payable onlyBefore(biddingEnd) {
		// TODO
		// if (block.timestamp > biddingEnd) {
		// 	revert TooLate(biddingEnd);
		// }
		if (msg.value <= highestBid) {
			revert BidNotHighEnough(highestBid);
		}

		pendingReturns[highestBidder] += highestBid;

		highestBidder = msg.sender;
		highestBid = msg.value;

		emit HighestBidIncreased(msg.sender, msg.value);
	}

	/// Withdraw a bid that was overbid.
	function withdraw() external {
		// TODO
		uint amount = pendingReturns[msg.sender];
		if (amount > 0) {
			pendingReturns[msg.sender] = 0;
			payable(msg.sender).transfer(amount);
		}
	}

	/// End the auction and send the highest bid
	/// to the beneficiary.
	function auctionEnd() external onlyAfter(biddingEnd) {
		// TODO
		//if (block.timestamp < biddingEnd) revert TooEarly(biddingEnd);
		if (ended) revert AuctionEndAlreadyCalled();

		ended = true;
		beneficiary.transfer(highestBid);

		emit AuctionEnded(highestBidder, highestBid);
	}
}
