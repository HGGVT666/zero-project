// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * ZERO Community & Education Treasury
 *
 * PURPOSE
 * - Education
 * - Scam awareness
 * - Community learning
 *
 * RULES
 * - No instant withdrawal
 * - All spending proposals are on-chain
 * - Mandatory delay before execution
 * - Community can observe and challenge
 *
 * NOTE
 * This treasury is designed for responsibility, not profit.
 */

contract CommunityTreasury {
    address public guardian;
    uint256 public constant DELAY = 7 days;

    struct Proposal {
        address to;
        uint256 amount;
        uint256 executeAfter;
        bool executed;
        string purpose;
    }

    Proposal[] public proposals;

    event ProposalCreated(
        uint256 indexed id,
        address indexed to,
        uint256 amount,
        string purpose
    );

    event ProposalExecuted(uint256 indexed id);

    constructor() {
        guardian = msg.sender;
    }

    function propose(
        address to,
        uint256 amount,
        string memory purpose
    ) public {
        require(msg.sender == guardian, "not guardian");

        proposals.push(
            Proposal({
                to: to,
                amount: amount,
                executeAfter: block.timestamp + DELAY,
                executed: false,
                purpose: purpose
            })
        );

        emit ProposalCreated(
            proposals.length - 1,
            to,
            amount,
            purpose
        );
    }

    function execute(uint256 id, address token) public {
        Proposal storage p = proposals[id];
        require(!p.executed, "already executed");
        require(block.timestamp >= p.executeAfter, "delay not passed");

        (bool success, ) = token.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                p.to,
                p.amount
            )
        );

        require(success, "transfer failed");

        p.executed = true;
        emit ProposalExecuted(id);
    }
}
