// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

/**
 * @title Payment
 * @dev A smart contract for handling payments with a fee mechanism.
 *      The contract supports splitting fees between two wallets provided by the user.
 *      The remaining amount (0.0001 ETH) is sent to a router for further execution.
 */
contract Payment {
    // State variables
    address public operator; // Address of the operator who manages the contract

    // Events
    /// @notice Emitted when a user interacts with the `buyIn` function
    /// @param user The address of the user interacting with the contract
    /// @param hashedPrompt A unique identifier provided by the user
    /// @param amount The total payment amount in ETH
    event BuyIn(address indexed user, bytes32 hashedPrompt, uint256 amount);

    /**
     * @dev Initializes the contract and sets the operator as the deployer.
     */
    constructor() {
        operator = msg.sender;
    }

    // Modifiers
    /**
     * @dev Modifier to ensure that only the operator can call certain functions.
     */
    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator can perform this action");
        _;
    }

    /**
     * @dev Allows the operator to update the operator address.
     * @param newOperator The new operator address.
     */
    function setOperator(address newOperator) external onlyOperator {
        operator = newOperator;
    }

    /**
     * @dev Allows the user to interact with the contract by sending ETH.
     *      The contract splits the fees and ensures that 0.0001 ETH is sent to the `routerAddress`.
     * @param hashedPrompt A unique identifier or metadata for the interaction.
     * @param routerAddress The address of the router where the remaining ETH will be sent.
     * @param callData The calldata to be passed to the router.
     * @param feeWallet The address receiving 70% of the fees.
     * @param multisWallet The address receiving 15% of the fees.
     */
    function buyIn(
        bytes32 hashedPrompt,
        address routerAddress,
        bytes memory callData,
        address feeWallet,
        address multisWallet
    ) public payable {
        uint256 amountIn = msg.value; // Total ETH sent by the user
        require(amountIn > 0.0001 ether, "Amount must be greater than 0.0001 ETH");

        // Calculate the fee (remaining amount is 0.0001 ETH)
        uint256 fee = amountIn - 0.0001 ether;
        uint256 feeWalletAmount = (fee * 70) / 85; // 70% of the fee
        uint256 multisWalletAmount = (fee * 15) / 85; // 15% of the fee

        // Transfer fees to the respective wallets
        payable(feeWallet).transfer(feeWalletAmount);
        payable(multisWallet).transfer(multisWalletAmount);

        // Transfer the remaining 0.0001 ETH to the router
        (bool success, ) = routerAddress.call{value: 0.0001 ether}(callData);
        require(success, "Router call failed");

        // Emit the BuyIn event
        emit BuyIn(msg.sender, hashedPrompt, amountIn);
    }

    /**
     * @dev Fallback function to prevent accidental ETH transfers.
     *      Reverts any ETH sent to the contract.
     */
    fallback() external payable {
        revert("Fallback function not supported");
    }

    /**
     * @dev Receive function to prevent accidental ETH transfers.
     *      Reverts any ETH sent to the contract.
     */
    receive() external payable {
        revert("Receive function not supported");
    }
}
