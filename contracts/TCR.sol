// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TCR is ERC20, Ownable {
    // Struct to represent a product proposal
    struct ProductProposal {
        address proposer;
        string productName;
        uint256 environmentalRating;
        bool isChallenged;
        uint256 votesFor;
        uint256 votesAgainst;
    }

    // Mapping to store product proposals
    mapping(uint256 => ProductProposal) public productProposals;

    // Event emitted when a new product is proposed
    event ProductProposed(uint256 proposalId, string productName);

    // Event emitted when a product is challenged
    event ProductChallenged(uint256 proposalId);

    // Event emitted when a product's rating is finalized
    event RatingFinalized(uint256 proposalId, uint256 finalRating);

    // Constructor for EnvironmentalImpactTCR
    constructor() ERC20("EnvironmentalToken", "ETK") {}

    // Function to propose a new product
    function proposeProduct(string memory productName, uint256 environmentalRating) external {
        require(environmentalRating >= 0, "Rating must be non-negative");
        uint256 proposalId = totalSupply() + 1;
        _mint(msg.sender, 1); // Mint 1 token for the proposer
        productProposals[proposalId] = ProductProposal(msg.sender, productName, environmentalRating, false, 0, 0);
        emit ProductProposed(proposalId, productName);
    }

    // Function to challenge a product proposal
    function challengeProduct(uint256 proposalId) external {
        require(_exists(proposalId), "Proposal does not exist");
        require(!productProposals[proposalId].isChallenged, "Proposal is already challenged");
        productProposals[proposalId].isChallenged = true;
        emit ProductChallenged(proposalId);
    }

    // Function to vote on a product proposal
    function voteOnProduct(uint256 proposalId, bool support) external {
        require(_exists(proposalId), "Proposal does not exist");
        require(!productProposals[proposalId].isChallenged, "Proposal is challenged");
        require(balanceOf(msg.sender) > 0, "Must have tokens to vote");

        if (support) {
            productProposals[proposalId].votesFor += 1;
        } else {
            productProposals[proposalId].votesAgainst += 1;
        }
    }

    // Function to finalize a product's rating
    function finalizeRating(uint256 proposalId) external onlyOwner {
        require(_exists(proposalId), "Proposal does not exist");
        require(productProposals[proposalId].isChallenged, "Proposal is not challenged");

        // Calculate the final rating based on the votes
        uint256 finalRating = productProposals[proposalId].votesFor > productProposals[proposalId].votesAgainst
            ? productProposals[proposalId].environmentalRating
            : 0;

        emit RatingFinalized(proposalId, finalRating);

        // Mint tokens to the proposer based on the final rating
        _mint(productProposals[proposalId].proposer, finalRating);
    }

    // Internal function to check if a proposal exists
    function _exists(uint256 proposalId) internal view returns (bool) {
        return proposalId <= totalSupply();
    }
}

