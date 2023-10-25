// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract Abcoin is ERC20 {
    address public owner;
    uint256 public votesPerPerson = 100;
    uint256 public lastResetYear; // To keep track of the last year when balances were reset.

    
    struct  Candidate{
        address adr;
        uint256 votes;
    }

    struct Election {
        address organizer;
        string name;
        mapping(address => Candidate) candidates;
        Candidate winner;
    }

    mapping(uint256 => Election) public elections;
    uint256 public currentElectionId = 1;

    struct Voter {
        address adr;
    }

    mapping(address => Voter) public voters;

    constructor() ERC20("Abcoin", "ABC") {
        owner = msg.sender;
        lastResetYear = getCurrentYear();
    }

    // Function to check if the current year has changed
    function isCurrentYear() internal view returns (bool) {
        return getCurrentYear() == lastResetYear;
    }

    // Function to get the current year (for testing purposes)
    function getCurrentYear() internal view returns (uint256) {
        return block.timestamp / 365 days;
    }

    function getElection(uint256 electionId) internal view returns(Election storage){
        Election storage election = elections[electionId];
        require(election.organizer != address(0), "Election not found");
        return election;
    }

    modifier notExpired() {
        require(isCurrentYear(), "This contract has been expired");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to create a new election
    function createElection(string memory name) public notExpired onlyOwner {  
        Election storage election = elections[currentElectionId];

        election.organizer = msg.sender;
        election.name = name;
        election.winner = Candidate({
            adr: address(0),
            votes: 0
        });
    
        currentElectionId++;
    }

    // Function to add a candidate to an election
    function addCandidate(uint256 electionId, address candidate) public notExpired onlyOwner {
        Election storage election = getElection(electionId);
        require(election.candidates[candidate].adr != candidate, "Candidate already added");

        election.candidates[candidate] = Candidate({
            adr: candidate,
            votes: 0
        });
    }

    // Function to add a voter and distribute tokens
    function addVoter(address voterAddress) public notExpired onlyOwner {
        require(voters[voterAddress].adr != voterAddress, "Voter already added");
        
        voters[voterAddress] = Voter({
            adr: voterAddress
        });
        
        _mint(voterAddress, votesPerPerson);
    }

    // Function to allow users to spend their votes on a specific election and candidate
    function spendVotes(uint256 electionId, address candidate, uint256 votes) public notExpired {
        require(balanceOf(msg.sender) >= votes, "Insufficient balance");
        require(electionId > 0 && electionId <= currentElectionId, "Invalid election ID");
        
        Election storage election = getElection(electionId);
        require(election.candidates[candidate].adr != address(0), "Candidate not found");

        election.candidates[candidate].votes += votes;
        if (election.candidates[candidate].votes > election.winner.votes){
            election.winner = election.candidates[candidate];
        }
        _burn(msg.sender, votes);
    }
}