// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MultiSend
 * @dev CodeAlpha Blockchain Development Internship - Task 2
 * A multi-send payment manager supporting equal and percentage-based Ether distribution,
 * recipient validation, duplicate detection, payment accounting, and emergency withdrawal.
 */
contract MultiSend {
    // Contract deployer with administrative control
    address public owner;

    // Cumulative Ether received per recipient address (in wei)
    mapping(address => uint256) public totalReceived;

    // Total cumulative Ether successfully distributed across all batches (in wei)
    uint256 public totalDistributed;

    // Total count of completed batch distribution transactions
    uint256 public paymentCount;

    // Lightweight reentrancy protection status
    uint256 private _status;

    // Events
    event EtherSent(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    event MultiSendCompleted(
        address indexed sender,
        uint256 totalAmount,
        uint256 recipientCount
    );

    event PercentageSendCompleted(
        address indexed sender,
        uint256 totalAmount,
        uint256 recipientCount
    );

    event EtherReceived(address indexed sender, uint256 amount);

    event EmergencyWithdrawal(address indexed owner, uint256 amount);

    // Modifier restricting access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Lightweight reentrancy guard without external dependencies
    modifier nonReentrant() {
        require(_status != 2, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    /**
     * @dev Initializes contract setting the deployer as owner and initializing reentrancy guard.
     */
    constructor() {
        owner = msg.sender;
        _status = 1;
    }

    /**
     * @dev Internal recipient validator: enforces non-empty list, zero-address rejection,
     * and duplicate detection via O(N^2) calldata comparison for small batches.
     */
    function _validateRecipients(address[] calldata recipients) private pure {
        uint256 len = recipients.length;
        require(len > 0, "No recipients specified");
        require(len <= 50, "Too many recipients");

        for (uint256 i = 0; i < len; i++) {
            require(recipients[i] != address(0), "Cannot send to zero address");
            for (uint256 j = i + 1; j < len; j++) {
                require(recipients[i] != recipients[j], "Duplicate recipient detected");
            }
        }
    }

    /**
     * @notice Distributes sent Ether equally among all provided recipients.
     * @param recipients Array of unique recipient addresses.
     */
    function multiSend(address[] calldata recipients)
        external
        payable
        nonReentrant
    {
        require(msg.value > 0, "Ether sent must be greater than zero");
        _validateRecipients(recipients);

        uint256 recipientCount = recipients.length;
        require(
            msg.value % recipientCount == 0,
            "Amount not evenly divisible among recipients"
        );

        uint256 amountPerRecipient = msg.value / recipientCount;

        for (uint256 i = 0; i < recipientCount; i++) {
            address recipient = recipients[i];
            totalReceived[recipient] += amountPerRecipient;

            (bool success, ) = payable(recipient).call{value: amountPerRecipient}("");
            require(success, "Transfer failed");

            emit EtherSent(msg.sender, recipient, amountPerRecipient);
        }

        totalDistributed += msg.value;
        paymentCount += 1;

        emit MultiSendCompleted(msg.sender, msg.value, recipientCount);
    }

    /**
     * @notice Distributes sent Ether according to exact specified percentage allocations.
     * @param recipients Array of unique recipient addresses.
     * @param percentages Array of integer percentage allocations (must sum to exactly 100).
     */
    function multiSendByPercentage(
        address[] calldata recipients,
        uint256[] calldata percentages
    ) external payable nonReentrant {
        require(msg.value > 0, "Ether sent must be greater than zero");
        require(recipients.length == percentages.length, "Array lengths must match");
        _validateRecipients(recipients);

        require(
            msg.value % 100 == 0,
            "Value must be multiple of 100 wei for exact distribution"
        );

        uint256 totalPercentage = 0;
        uint256 recipientCount = recipients.length;

        for (uint256 i = 0; i < recipientCount; i++) {
            require(percentages[i] > 0, "Percentage must be greater than zero");
            totalPercentage += percentages[i];
        }
        require(totalPercentage == 100, "Percentages must sum to exactly 100");

        for (uint256 i = 0; i < recipientCount; i++) {
            address recipient = recipients[i];
            uint256 amount = (msg.value * percentages[i]) / 100;

            totalReceived[recipient] += amount;

            (bool success, ) = payable(recipient).call{value: amount}("");
            require(success, "Transfer failed");

            emit EtherSent(msg.sender, recipient, amount);
        }

        totalDistributed += msg.value;
        paymentCount += 1;

        emit PercentageSendCompleted(msg.sender, msg.value, recipientCount);
    }

    /**
     * @notice Returns the contract's current Ether balance in wei.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Allows the contract owner to withdraw any remaining or stuck Ether.
     */
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No Ether to withdraw");

        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");

        emit EmergencyWithdrawal(owner, balance);
    }

    /**
     * @notice Accepts direct plain Ether transfers.
     */
    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }
}
