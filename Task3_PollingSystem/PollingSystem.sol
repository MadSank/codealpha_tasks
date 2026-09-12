// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PollingSystem
 * @dev CodeAlpha Blockchain Development Internship - Task 3
 * A decentralized polling and governance system supporting multi-option poll creation,
 * single-vote enforcement per wallet, on-chain deadlines, creator cancellations,
 * status tracking, and deterministic winner computation.
 */
contract PollingSystem {
    // Enum representing the current lifecycle stage of a poll
    enum PollStatus {
        ACTIVE,
        ENDED,
        CANCELLED
    }

    // Structure holding complete poll metadata, options, and vote records
    struct Poll {
        string title;
        string[] options;
        uint256 startTime;
        uint256 endTime;
        address creator;
        bool exists;
        bool cancelled;
        uint256 totalVotes;
        mapping(uint256 => uint256) voteCount;
        mapping(address => bool) hasVoted;
    }

    // Total count of polls created
    uint256 public pollCount;

    // Mapping from unique poll ID to Poll struct (kept private due to nested mappings)
    mapping(uint256 => Poll) private polls;

    // Events
    event PollCreated(
        uint256 indexed pollId,
        string title,
        address indexed creator,
        uint256 startTime,
        uint256 endTime,
        uint256 optionCount
    );

    event VoteCast(
        uint256 indexed pollId,
        address indexed voter,
        uint256 optionIndex
    );

    event PollCancelled(
        uint256 indexed pollId,
        address indexed creator
    );

    /**
     * @notice Creates a new poll.
     * @param title The question or proposal statement (cannot be empty).
     * @param options Array of candidate choices (minimum 2 required).
     * @param duration Active voting window in seconds.
     * @return pollId The newly generated unique poll identifier.
     */
    function createPoll(
        string calldata title,
        string[] calldata options,
        uint256 duration
    ) external returns (uint256 pollId) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(options.length >= 2, "Must have at least 2 options");
        require(duration > 0, "Duration must be greater than zero");

        pollCount += 1;
        pollId = pollCount;

        Poll storage newPoll = polls[pollId];
        newPoll.title = title;
        newPoll.options = options;
        newPoll.startTime = block.timestamp;
        newPoll.endTime = block.timestamp + duration;
        newPoll.creator = msg.sender;
        newPoll.exists = true;
        newPoll.cancelled = false;

        emit PollCreated(
            pollId,
            title,
            msg.sender,
            newPoll.startTime,
            newPoll.endTime,
            options.length
        );
    }

    /**
     * @notice Casts a vote for a designated option in an active poll.
     * @param pollId The unique identifier of the poll.
     * @param optionIndex The zero-based index of the chosen option.
     */
    function vote(uint256 pollId, uint256 optionIndex) external {
        Poll storage poll = polls[pollId];

        require(poll.exists, "Poll does not exist");
        require(!poll.cancelled, "Poll has been cancelled");
        require(block.timestamp < poll.endTime, "Voting has ended");
        require(optionIndex < poll.options.length, "Invalid option index");
        require(!poll.hasVoted[msg.sender], "Address has already voted");

        poll.hasVoted[msg.sender] = true;
        poll.voteCount[optionIndex] += 1;
        poll.totalVotes += 1;

        emit VoteCast(pollId, msg.sender, optionIndex);
    }

    /**
     * @notice Allows the poll creator to cancel an active poll before its deadline.
     * @param pollId The unique identifier of the poll.
     */
    function cancelPoll(uint256 pollId) external {
        Poll storage poll = polls[pollId];

        require(poll.exists, "Poll does not exist");
        require(msg.sender == poll.creator, "Only poll creator can cancel");
        require(!poll.cancelled, "Poll is already cancelled");
        require(block.timestamp < poll.endTime, "Cannot cancel ended poll");

        poll.cancelled = true;

        emit PollCancelled(pollId, msg.sender);
    }

    /**
     * @notice Returns the current lifecycle status of a poll.
     * @param pollId The unique identifier of the poll.
     * @return The status enum (0: ACTIVE, 1: ENDED, 2: CANCELLED).
     */
    function getPollStatus(uint256 pollId) public view returns (PollStatus) {
        Poll storage poll = polls[pollId];
        require(poll.exists, "Poll does not exist");

        if (poll.cancelled) {
            return PollStatus.CANCELLED;
        }
        if (block.timestamp >= poll.endTime) {
            return PollStatus.ENDED;
        }
        return PollStatus.ACTIVE;
    }

    /**
     * @notice Determines the winning option of a concluded poll.
     * Reverts if the poll is still ongoing, was cancelled, or concluded with zero votes.
     * Resolves ties deterministically by selecting the first option with the highest vote count.
     * @param pollId The unique identifier of the poll.
     * @return winningIndex The zero-based index of the winning option.
     * @return winningOption The text label of the winning option.
     * @return votes Total votes accumulated by the winner.
     */
    function getWinningOption(uint256 pollId)
        external
        view
        returns (
            uint256 winningIndex,
            string memory winningOption,
            uint256 votes
        )
    {
        Poll storage poll = polls[pollId];

        require(poll.exists, "Poll does not exist");
        require(!poll.cancelled, "Poll has been cancelled");
        require(block.timestamp >= poll.endTime, "Poll is still ongoing");
        require(poll.totalVotes > 0, "No votes cast");

        uint256 highestVotes = 0;
        uint256 bestIndex = 0;

        for (uint256 i = 0; i < poll.options.length; i++) {
            if (poll.voteCount[i] > highestVotes) {
                highestVotes = poll.voteCount[i];
                bestIndex = i;
            }
        }

        return (bestIndex, poll.options[bestIndex], highestVotes);
    }

    /**
     * @notice Returns the cumulative votes cast across all options for a poll.
     * @param pollId The unique identifier of the poll.
     */
    function getTotalVotes(uint256 pollId) external view returns (uint256) {
        require(polls[pollId].exists, "Poll does not exist");
        return polls[pollId].totalVotes;
    }

    /**
     * @notice Returns the vote tally for an individual option in a poll.
     * @param pollId The unique identifier of the poll.
     * @param optionIndex The zero-based index of the option.
     */
    function getVoteCount(uint256 pollId, uint256 optionIndex)
        external
        view
        returns (uint256)
    {
        Poll storage poll = polls[pollId];
        require(poll.exists, "Poll does not exist");
        require(optionIndex < poll.options.length, "Invalid option index");

        return poll.voteCount[optionIndex];
    }

    /**
     * @notice Checks whether a given address has voted in a poll.
     * @param pollId The unique identifier of the poll.
     * @param voter The address to query.
     */
    function hasUserVoted(uint256 pollId, address voter)
        external
        view
        returns (bool)
    {
        require(polls[pollId].exists, "Poll does not exist");
        return polls[pollId].hasVoted[voter];
    }

    /**
     * @notice Returns top-level metadata and current status for a poll.
     * @param pollId The unique identifier of the poll.
     */
    function getPollDetails(uint256 pollId)
        external
        view
        returns (
            string memory title,
            address creator,
            uint256 startTime,
            uint256 endTime,
            uint256 optionCount,
            PollStatus status,
            uint256 totalVotes
        )
    {
        Poll storage poll = polls[pollId];
        require(poll.exists, "Poll does not exist");

        return (
            poll.title,
            poll.creator,
            poll.startTime,
            poll.endTime,
            poll.options.length,
            getPollStatus(pollId),
            poll.totalVotes
        );
    }

    /**
     * @notice Returns all candidate option labels for a poll.
     * @param pollId The unique identifier of the poll.
     */
    function getPollOptions(uint256 pollId)
        external
        view
        returns (string[] memory)
    {
        require(polls[pollId].exists, "Poll does not exist");
        return polls[pollId].options;
    }
}
