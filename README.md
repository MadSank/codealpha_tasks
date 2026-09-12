# CodeAlpha Blockchain Development Internship

This repository contains three progressively enhanced smart contract projects developed for the **CodeAlpha Blockchain Development Internship**. The tasks demonstrate key EVM concepts ranging from state variables, events, and access control to low-level Ether transfers, reentrancy guards, and decentralized governance mechanisms.

All contracts are written in **Solidity `^0.8.20`**, completely self-contained with no external dependencies, and optimized for compilation, deployment, and testing directly within **Remix IDE**.

---

## 📋 Task Overview

| Task | Project Name | Primary Concepts Demonstrated |
| :--- | :--- | :--- |
| **Task 1** | **Enhanced Simple Storage** | State variables, modifiers, events, access control, parameterized state mutation |
| **Task 2** | **Multi-Send Payment Manager** | Low-level `.call`, equal & percentage batch payments, duplicate detection, accounting, reentrancy protection |
| **Task 3** | **Decentralized Polling & Governance** | Structs, mappings, status enums, deadline enforcement, single-vote tracking, deterministic winner resolution |

---

## 📁 Repository Structure

```text
CodeAlpha_Blockchain/
│
├── Task1_SimpleStorage/
│   └── SimpleStorage.sol        # On-chain value management system
│
├── Task2_MultiSend/
│   └── MultiSend.sol            # Batch Ether distribution & payment manager
│
├── Task3_PollingSystem/
│   └── PollingSystem.sol        # Decentralized multi-poll governance system
│
├── README.md                    # Project documentation, guides & test flows
├── .gitignore                   # Clean ignore rules for OS, IDE & secrets
└── LICENSE                      # MIT Open-Source License
```

---

## 🛠️ Technology Stack

- **Smart Contract Language:** Solidity `^0.8.20`
- **Target Environment:** Ethereum-compatible EVM
- **Development & Testing Suite:** [Remix Ethereum IDE](https://remix.ethereum.org/)
- **Test Accounts:** Remix VM virtual accounts (100 ETH each)
- **License:** MIT License

---

## 🔍 Contract Features

### Task 1 — Enhanced Simple Storage (`SimpleStorage.sol`)
An on-chain integer value management system that expands standard storage into an audited, permissioned state machine:
- **State Tracking:** Tracks current integer `value`, contract deployer `owner`, and cumulative `updateCount`.
- **Flexible Modification:** Supports single-step `increment()`/`decrement()` as well as parameterized `incrementBy(uint256 amount)` and `decrementBy(uint256 amount)`.
- **Underflow Protection:** Explicit validation preventing stored values from dropping below zero.
- **Access Control:** Deployer-only administrative functions `setValue(uint256 newValue)` and `reset()` enforced via an `onlyOwner` modifier.
- **Audit Logging:** Emits structured `ValueChanged` and `ValueReset` events capturing updater address, previous value, new value, and block timestamp.

### Task 2 — Multi-Send Payment Manager (`MultiSend.sol`)
A payment distribution manager supporting two payment models, comprehensive recipient validation, and accounting metrics:
- **Equal Ether Distribution (`multiSend`):** Distributes incoming `msg.value` equally across an array of recipients using secure low-level `.call{value: amount}("")`.
- **Percentage-Based Distribution (`multiSendByPercentage`):** Distributes Ether according to exact integer percentage weights summing to 100%.
- **Validation & Duplicate Protection:** Rejects the zero address (`address(0)`) and detects duplicate recipient addresses using an in-calldata comparison suitable for small batches.
- **Payment Metrics:** Tracks cumulative Ether received per address (`totalReceived`), total distributed Ether across all batches (`totalDistributed`), and completed batch count (`paymentCount`).
- **Safety Mechanisms:** Built-in lightweight reentrancy guard (`nonReentrant`), direct Ether reception via `receive()`, and owner-controlled emergency `withdraw()`.

### Task 3 — Decentralized Polling & Governance (`PollingSystem.sol`)
A multi-poll on-chain voting system that manages the full proposal lifecycle:
- **Poll Lifecycle & States:** Tracks poll states (`ACTIVE`, `ENDED`, `CANCELLED`) using a structured enum and block timestamps.
- **Configurable Proposals:** Creates polls with custom titles, multiple options (minimum 2), and customizable voting durations.
- **Single Vote Per Wallet:** Enforces strict 1-vote-per-address limits using nested mappings.
- **Creator Cancellation:** Allows poll creators to cancel proposals before their voting deadline.
- **Deterministic Winner Resolution:** Concludes polls post-deadline, handles zero-vote scenarios safely by reverting, and resolves ties deterministically (first option with highest vote count).
- **Inspection Getters:** Read-only methods for total votes, option tallies, voter participation status, and complete poll details.

---

## 🚀 Remix IDE Setup & Quick Start

1. Open your browser and navigate to **[Remix IDE](https://remix.ethereum.org/)**.
2. In the **File Explorer** tab (left sidebar):
   - Create a workspace or folder named `CodeAlpha_Blockchain`.
   - Recreate the three task folders and add `SimpleStorage.sol`, `MultiSend.sol`, and `PollingSystem.sol`.
3. In the **Solidity Compiler** tab:
   - Select compiler version **`0.8.20`** (or any compatible `0.8.x` compiler).
   - Keep language as **Solidity** and EVM version as **default**.
4. In the **Deploy & Run Transactions** tab:
   - Set **Environment** to **Remix VM** (e.g., Remix VM Cancun, Shanghai, or London).
   - Each VM session provides 10 pre-funded test accounts with 100 ETH each.

---

## 🧪 Exact Step-by-Step Testing Sequences

### Task 1: Enhanced Simple Storage Demo Flow

```text
Deploy (Account 1)
   ↓
Read value (Initial: 0)
   ↓
increment() → value: 1
   ↓
incrementBy(5) → value: 6
   ↓
decrement() → value: 5
   ↓
decrementBy(3) → value: 2
   ↓
setValue(42) → value: 42
   ↓
Check updateCount (6 modifications recorded)
   ↓
Switch to Account 2 → Attempt setValue(100) [Fails: "Caller is not the owner"]
   ↓
Switch back to Account 1 → reset() → value: 0
   ↓
Attempt decrement() at zero [Fails: "Value cannot be negative"]
```

#### Detailed Execution Steps:
1. **Deploy:** Select `SimpleStorage.sol` and click **Deploy** using Account 1 (`0x5B38...`).
2. **Initial State:** Click `value` $\rightarrow$ returns `0`. Click `updateCount` $\rightarrow$ returns `0`.
3. **Increment Operations:**
   - Click `increment` $\rightarrow$ transaction succeeds; `value` is now `1`.
   - Enter `5` into `incrementBy` and click the button $\rightarrow$ `value` is now `6`.
4. **Decrement Operations:**
   - Click `decrement` $\rightarrow$ `value` is now `5`.
   - Enter `3` into `decrementBy` and click the button $\rightarrow$ `value` is now `2`.
5. **Direct Set:** Enter `42` into `setValue` and click the button $\rightarrow$ `value` is now `42`.
6. **Verify Audit Counter:** Click `updateCount` $\rightarrow$ returns `5`.
7. **Access Control Test:**
   - Change the active Remix account to Account 2 (`0xAb84...`).
   - Try calling `setValue` with `100` $\rightarrow$ transaction reverts with `"Caller is not the owner"`.
8. **Reset State:**
   - Switch back to Account 1.
   - Click `reset` $\rightarrow$ `value` is reset to `0`; check logs for `ValueReset` and `ValueChanged` events.
9. **Underflow Prevention:**
   - Click `decrement` while `value` is `0` $\rightarrow$ transaction reverts with `"Value cannot be negative"`.

---

### Task 2: Multi-Send Payment Manager Demo Flow

```text
Deploy (Account 1)
   ↓
Check getBalance() (Initial: 0 ETH)
   ↓
multiSend() with 0.3 ETH split among 3 addresses (0.1 ETH each)
   ↓
Verify totalReceived, totalDistributed & paymentCount
   ↓
multiSendByPercentage() with 1 ETH split 50% / 30% / 20%
   ↓
Direct Ether transfer to contract (Triggers receive())
   ↓
Emergency withdraw() as owner
```

#### Detailed Execution Steps:
1. **Deploy:** Select `MultiSend.sol` and click **Deploy** using Account 1 (`0x5B38...`).
2. **Equal Multi-Send:**
   - In the **Value** field at the top of Remix, enter `0.3` and select `Ether`.
   - In the `multiSend` input, enter an array of three recipient addresses:
     ```json
     ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
     ```
   - Click `multiSend`.
   - Check balances of the three recipient accounts in the Remix dropdown $\rightarrow$ each increased by `0.1 ETH`.
   - Query `totalReceived` for `0xAb84...` $\rightarrow$ returns `100000000000000000` (0.1 ETH in wei).
   - Query `totalDistributed` $\rightarrow$ returns `300000000000000000` (0.3 ETH in wei).
   - Query `paymentCount` $\rightarrow$ returns `1`.
3. **Percentage-Based Multi-Send:**
   - In the **Value** field, enter `1` and select `Ether`.
   - In `recipients`, paste:
     ```json
     ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
     ```
   - In `percentages`, paste:
     ```json
     [50, 30, 20]
     ```
   - Click `multiSendByPercentage`.
   - Account 1 received `0.5 ETH`, Account 2 received `0.3 ETH`, Account 3 received `0.2 ETH`.
   - Query `paymentCount` $\rightarrow$ returns `2`.
4. **Direct Transfer & Fallback:**
   - In the **Value** field, enter `0.5` and select `Ether`.
   - Scroll down to **Low level interactions**, leave data blank, and click **Transact**.
   - Inspect the terminal logs $\rightarrow$ `EtherReceived` event emitted with value `500000000000000000`.
   - Click `getBalance` $\rightarrow$ returns `500000000000000000` (0.5 ETH held in contract).
5. **Owner Withdrawal:**
   - Click `withdraw` as Account 1 $\rightarrow$ contract balance returns to `0`, funds returned to owner, and `EmergencyWithdrawal` event emitted.

---

### Task 3: Decentralized Polling & Governance Demo Flow

```text
Deploy (Account 1)
   ↓
createPoll("Adopt EIP-4844?", ["Yes", "No", "Abstain"], 180 seconds)
   ↓
Inspect getPollDetails(1) & getPollOptions(1)
   ↓
Account 1 votes for Option 0 ("Yes")
   ↓
Account 2 votes for Option 1 ("No")
   ↓
Account 3 votes for Option 0 ("Yes")
   ↓
Account 1 attempts second vote [Fails: "Address has already voted"]
   ↓
Check vote counts & totalVotes
   ↓
Wait 180s for deadline expiration
   ↓
getWinningOption(1) → Winner: "Yes" with 2 votes
```

#### Detailed Execution Steps:
1. **Deploy:** Select `PollingSystem.sol` and click **Deploy** using Account 1 (`0x5B38...`).
2. **Create Poll:**
   - Enter title: `"Adopt EIP-4844?"`
   - Enter options: `["Yes", "No", "Abstain"]`
   - Enter duration: `180` (seconds)
   - Click `createPoll` $\rightarrow$ poll ID `1` created; `PollCreated` event emitted.
3. **Inspect Initial State:**
   - Call `getPollDetails(1)` $\rightarrow$ shows title, creator address, timestamps, 3 options, status `0` (ACTIVE), and 0 total votes.
   - Call `getPollOptions(1)` $\rightarrow$ returns `["Yes", "No", "Abstain"]`.
4. **Cast Votes:**
   - As Account 1: call `vote(1, 0)` $\rightarrow$ votes for `"Yes"`.
   - Switch to Account 2: call `vote(1, 1)` $\rightarrow$ votes for `"No"`.
   - Switch to Account 3: call `vote(1, 0)` $\rightarrow$ votes for `"Yes"`.
5. **Prevent Duplicate Voting:**
   - As Account 1: attempt calling `vote(1, 2)` $\rightarrow$ transaction reverts with `"Address has already voted"`.
6. **Verify Tallies:**
   - Call `getVoteCount(1, 0)` $\rightarrow$ returns `2`.
   - Call `getVoteCount(1, 1)` $\rightarrow$ returns `1`.
   - Call `getTotalVotes(1)` $\rightarrow$ returns `3`.
7. **Attempt Early Winner Query:**
   - Call `getWinningOption(1)` before 180s elapses $\rightarrow$ reverts with `"Poll is still ongoing"`.
8. **Conclude & Determine Winner:**
   - Wait until the 180s duration expires (or forward block time in Remix).
   - Call `getPollStatus(1)` $\rightarrow$ status changes from `0` (ACTIVE) to `1` (ENDED).
   - Call `getWinningOption(1)` $\rightarrow$ returns `winningIndex: 0`, `winningOption: "Yes"`, `votes: 2`.
9. **Demonstrate Creator Cancellation:**
   - Create Poll 2 with duration `600`.
   - As creator, call `cancelPoll(2)` $\rightarrow$ `PollCancelled` emitted; status becomes `2` (CANCELLED).
   - Attempting to vote on Poll 2 reverts with `"Poll has been cancelled"`.

---

## ⚠️ Important Failure Cases Tested

| Task | Condition / Action | Expected Error Message |
| :--- | :--- | :--- |
| **Task 1** | Decrement when `value == 0` | `"Value cannot be negative"` |
| **Task 1** | Non-owner calls `setValue` or `reset` | `"Caller is not the owner"` |
| **Task 2** | `multiSend` with empty recipient list | `"No recipients specified"` |
| **Task 2** | `multiSend` with `msg.value == 0` | `"Ether sent must be greater than zero"` |
| **Task 2** | Recipient list containing `address(0)` | `"Cannot send to zero address"` |
| **Task 2** | Recipient list containing duplicate addresses | `"Duplicate recipient detected"` |
| **Task 2** | Percentage array not summing to 100 | `"Percentages must sum to exactly 100"` |
| **Task 2** | Non-owner calls `withdraw` | `"Only owner can call this function"` |
| **Task 3** | Poll creation with empty title | `"Title cannot be empty"` |
| **Task 3** | Poll creation with fewer than 2 options | `"Must have at least 2 options"` |
| **Task 3** | Address votes more than once | `"Address has already voted"` |
| **Task 3** | Voting after deadline | `"Voting has ended"` |
| **Task 3** | Non-creator attempts to cancel poll | `"Only poll creator can cancel"` |
| **Task 3** | Determining winner on zero-vote poll | `"No votes cast"` |

---

## 🔒 Security Considerations & Limitations

- **Access Control:** Owner-restricted administrative functions use a simple, robust `onlyOwner` modifier.
- **Reentrancy Safety:** State modifications are applied prior to external low-level `.call` invocations (Checks-Effects-Interactions pattern), reinforced with a reentrancy lock.
- **Safe Value Routing:** Low-level `.call{value: amount}("")` is used with explicit boolean success checks instead of deprecated `transfer()` or `send()`.
- **Duplicate Protection:** Recipient arrays are validated in calldata prior to processing to prevent unintended double payments.
- **Time Dependency:** Deadlines rely on `block.timestamp`. While miners can slightly manipulate block timestamps within seconds, it is fully adequate for voting windows and standard dApps.
- **Educational Scope Notice:**
  > *These contracts are educational projects designed to demonstrate Solidity and blockchain development principles for the CodeAlpha internship. They have not undergone a commercial third-party security audit and are intended for testing and demonstration on testnets or virtual EVMs.*

---

## ✅ Verification & Testing Checklist

- [x] **Task 1:** `increment()` and `incrementBy()` add values accurately.
- [x] **Task 1:** `decrement()` and `decrementBy()` subtract values and revert on underflow.
- [x] **Task 1:** `setValue()` and `reset()` restrict access to contract owner.
- [x] **Task 1:** `updateCount` accurately tracks all successful state transitions.
- [x] **Task 2:** `multiSend()` splits Ether equally using low-level call pattern.
- [x] **Task 2:** `multiSendByPercentage()` distributes Ether according to percentage allocations.
- [x] **Task 2:** Zero addresses and duplicate recipients are rejected.
- [x] **Task 2:** Accounting variables (`totalReceived`, `totalDistributed`, `paymentCount`) update accurately.
- [x] **Task 2:** Direct transfers trigger `receive()`; emergency `withdraw()` empties contract to owner.
- [x] **Task 3:** Poll creation validates title, option count, and duration.
- [x] **Task 3:** Address voting restricted to exactly one vote per poll.
- [x] **Task 3:** Voting past deadline is rejected.
- [x] **Task 3:** Creator can cancel active polls; cancelled polls reject votes.
- [x] **Task 3:** `getWinningOption()` computes winner deterministically and reverts on zero votes.

---

## 📌 CodeAlpha Submission & LinkedIn Checklist

When submitting the internship project and sharing on LinkedIn:
- [x] **GitHub Repository:** Push clean repository containing Tasks 1, 2, and 3 with full documentation.
- [x] **Video Demonstration:** Record a short walkthrough demonstrating deployment and execution of each task in Remix IDE.
- [x] **LinkedIn Post:**
  - Tag **CodeAlpha** in your post.
  - Include relevant hashtags: `#CodeAlpha #BlockchainDevelopment #Solidity #SmartContracts #Web3 #Ethereum`.
  - Share key learnings from implementing access control, payment routing, and on-chain voting.

---

## 📄 License

This project is open-source and licensed under the [MIT License](LICENSE).
