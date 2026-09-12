// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleStorage
 * @dev CodeAlpha Blockchain Development Internship - Task 1
 * An on-chain value management system supporting basic increments/decrements,
 * parameterized adjustments, owner-controlled updates/resets, and state tracking.
 */
contract SimpleStorage {
    // Current stored integer value
    uint256 public value;

    // Contract owner address
    address public owner;

    // Total count of successful state modifications
    uint256 public updateCount;

    // Events emitted on state transitions
    event ValueChanged(
        address indexed updater,
        uint256 oldValue,
        uint256 newValue,
        uint256 timestamp
    );

    event ValueReset(
        address indexed resetBy,
        uint256 previousValue,
        uint256 timestamp
    );

    // Access control modifier restricting functions to contract deployer
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /**
     * @dev Initializes the contract setting the deployer as the owner.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Increments the stored value by 1.
     */
    function increment() external {
        uint256 oldValue = value;
        value += 1;
        updateCount += 1;

        emit ValueChanged(msg.sender, oldValue, value, block.timestamp);
    }

    /**
     * @notice Increments the stored value by a specified amount.
     * @param amount The value to add to the current stored value.
     */
    function incrementBy(uint256 amount) external {
        require(amount > 0, "Increment amount must be greater than zero");

        uint256 oldValue = value;
        value += amount;
        updateCount += 1;

        emit ValueChanged(msg.sender, oldValue, value, block.timestamp);
    }

    /**
     * @notice Decrements the stored value by 1.
     * Reverts if the value is already 0 to prevent underflow.
     */
    function decrement() external {
        require(value > 0, "Value cannot be negative");

        uint256 oldValue = value;
        value -= 1;
        updateCount += 1;

        emit ValueChanged(msg.sender, oldValue, value, block.timestamp);
    }

    /**
     * @notice Decrements the stored value by a specified amount.
     * @param amount The value to subtract from the current stored value.
     */
    function decrementBy(uint256 amount) external {
        require(amount > 0, "Decrement amount must be greater than zero");
        require(value >= amount, "Cannot decrement below zero");

        uint256 oldValue = value;
        value -= amount;
        updateCount += 1;

        emit ValueChanged(msg.sender, oldValue, value, block.timestamp);
    }

    /**
     * @notice Allows the contract owner to set an arbitrary new value.
     * @param newValue The new value to set.
     */
    function setValue(uint256 newValue) external onlyOwner {
        uint256 oldValue = value;
        value = newValue;
        updateCount += 1;

        emit ValueChanged(msg.sender, oldValue, value, block.timestamp);
    }

    /**
     * @notice Resets the stored value to 0. Restricted to the contract owner.
     */
    function reset() external onlyOwner {
        uint256 oldValue = value;
        value = 0;
        updateCount += 1;

        emit ValueReset(msg.sender, oldValue, block.timestamp);
        emit ValueChanged(msg.sender, oldValue, 0, block.timestamp);
    }
}
