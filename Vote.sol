pragma solidity ^0.4.18;

import "./Owned.sol";

contract Vote is owned {
    event ProposalAdd(uint vote_id, address generator, string descript);
    event ProposalEnd(uint vote_id, string descript);

    struct Proposal {
        address generator;
        string descript;
        uint256 start_timestamp;
        uint256 end_timestamp;
        bool executed;
        uint256 voting_cut;
        uint256 threshold;

        uint256 voting_count;
        uint256 total_weight;
        mapping (address => uint256) voteWeightOf;
        mapping (address => bool) votedOf;
        address [] voter_address;
    }

    uint private vote_id = 0;
    Proposal [] private Proposals;

    function getProposalLength() public constant returns (uint) {
        return Proposals.length;
    }

    function getProposalIndex(uint _proposal_index) public constant returns (
        address generator,
        string descript,
        uint256 start_timestamp,
        uint256 end_timestamp,
        bool executed,
        uint256 voting_count,
        uint256 total_weight,
        uint256 voting_cut,
        uint256 threshold
    ) {
        generator = Proposals[_proposal_index].generator;
        descript = Proposals[_proposal_index].descript;
        start_timestamp = Proposals[_proposal_index].start_timestamp;
        end_timestamp = Proposals[_proposal_index].end_timestamp;
        executed = Proposals[_proposal_index].executed;
        voting_count = Proposals[_proposal_index].voting_count;
        total_weight = Proposals[_proposal_index].total_weight;
        voting_cut = Proposals[_proposal_index].voting_cut;
        threshold = Proposals[_proposal_index].threshold;
    }

    function getProposalVoterList(uint _proposal_index) public constant returns (address[]) {
        return Proposals[_proposal_index].voter_address;
    }

    function newVote(
        address who,
        string descript,
        uint256 start_timestamp,
        uint256 end_timestamp,
        uint256 voting_cut,
        uint256 threshold
    ) onlyOwner public returns (uint256) {
        if (Proposals.length >= 1) {
            require(Proposals[vote_id].end_timestamp < start_timestamp);
            require(Proposals[vote_id].executed == true);
        }

        vote_id = Proposals.length;
        Proposal storage p = Proposals[Proposals.length++];
        p.generator = who;
        p.descript = descript;
        p.start_timestamp = start_timestamp;
        p.end_timestamp = end_timestamp;
        p.executed = false;
        p.voting_cut = voting_cut;
        p.threshold = threshold;

        p.voting_count = 0;
        delete p.voter_address;
        ProposalAdd(vote_id, who, descript);
        return vote_id;
    }

    function voting(address _voter, uint256 _weight) internal returns(bool) {
        if (Proposals[vote_id].end_timestamp < now) {
            Proposals[vote_id].executed = true;
        }

        require(Proposals[vote_id].executed == false);
        require(Proposals[vote_id].end_timestamp > now);
        require(Proposals[vote_id].start_timestamp <= now);
        require(Proposals[vote_id].votedOf[_voter] == false);
        require(Proposals[vote_id].voting_cut <= _weight);

        Proposals[vote_id].votedOf[_voter] = true;
        Proposals[vote_id].voting_count += 1;
        Proposals[vote_id].voteWeightOf[_voter] = _weight;
        Proposals[vote_id].total_weight += _weight;
        Proposals[vote_id].voter_address[Proposals[vote_id].voter_address.length++] = _voter;

        if (Proposals[vote_id].total_weight >= Proposals[vote_id].threshold) {
            Proposals[vote_id].executed = true;
        }
        return true;
    }

    function voteClose() onlyOwner public {
        if (Proposals.length >= 1) {
            Proposals[vote_id].executed = true;
            ProposalEnd(vote_id, Proposals[vote_id].descript);
        }
    }

    function checkVote() onlyOwner public {
        if ((Proposals.length >= 1) &&
            (Proposals[vote_id].end_timestamp < now)) {
            voteClose();
        }
    }
}
