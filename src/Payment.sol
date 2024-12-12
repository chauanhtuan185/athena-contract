// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

/**
 * @title Payment
 * @dev A smart contract for handling payments with a fee mechanism.
 *      The contract allows an operator to manage fees, fee recipients, 
 *      and ensure that users can interact securely via `buyIn`.
 */
contract Payment {
    /// @notice The address where fees are sent.
    address payable feeRecipient;

    /// @notice The percentage fee (in basis points, e.g., 1% = 1).
    uint256 feePerc;

    /// @notice The address with operator privileges for managing contract settings.
    address operator;

    /// @notice Emitted when a user interacts with the `buyIn` function.
    /// @param user The address of the user making the payment.
    /// @param hashedPrompt A unique identifier provided by the user.
    /// @param amount The total payment amount sent in ETH.
    event BuyIn(address indexed user, bytes32 hashedPrompt, uint256 amount);

    /**
     * @dev Initializes the contract with a fee recipient, fee percentage, and sets the deployer as the operator.
     * @param feeRecipientAddress The address to receive fees.
     * @param feePerc_ The initial fee percentage (must not exceed 30%).
     */
    constructor(address feeRecipientAddress, uint256 feePerc_) {
        feeRecipient = payable(feeRecipientAddress);
        feePerc = feePerc_;
        operator = msg.sender;
    }

    /// @dev Ensures that only the operator can call certain functions.
    modifier isOperator() {
        require(msg.sender == operator, "Only operator can perform this action");
        _;
    }

    /**
     * @dev Updates the operator of the contract.
     * @param operator_ The new operator address.
     */
    function setOperator(address operator_) public isOperator {
        operator = operator_;
    }

    /**
     * @dev Updates the address that will receive the fees.
     * @param feeRecipientAddress The new fee recipient address.
     */
    function setFeeRecipient(address feeRecipientAddress) public isOperator {
        feeRecipient = payable(feeRecipientAddress);
    }

    /**
     * @dev Updates the fee percentage. The value cannot exceed 30%.
     * @param feePerc_ The new fee percentage.
     */
    function setFee(uint256 feePerc_) public isOperator {
        require(feePerc_ <= 30, "Fee cannot exceed 30%");
        feePerc = feePerc_;
    }

    /**
     * @dev Calculates and transfers the fee to the feeRecipient.
     *      Returns the remaining amount after deducting the fee.
     * @param amount The total amount to calculate the fee from.
     * @return The remaining amount after fee deduction.
     */
    function applyFee(uint256 amount) private returns (uint256) {
        uint256 fee = (amount * feePerc) / 100;
        if (fee > 0) {
            (bool success, ) = feeRecipient.call{value: fee}("");
            require(success, "Fee transfer failed");
        }
        return amount - fee;
    }

    /**
     * @dev Allows a user to interact with the contract by sending ETH.
     *      A minimum of 0.0001 ETH is required, and fees are deducted from the sent amount.
     * @param hashedPrompt A unique identifier or metadata for the interaction.
     */
    function buyIn(bytes32 hashedPrompt) public payable {
        uint256 amountIn = msg.value; // The ETH amount sent by the user.
        require(
            amountIn > 0.0001 ether,
            "Amount must be greater than 0.0001 ether"
        );

        uint256 amountAfterFee = applyFee(amountIn);
        require(amountAfterFee > 0, "Remaining amount must be greater than 0");

        emit BuyIn(msg.sender, hashedPrompt, amountIn);
    }

    /**
     * @dev Fallback function to prevent unintended ETH transfers.
     */
    fallback() external payable {
        revert("Fallback function not supported");
    }

    /**
     * @dev Receive function to prevent unintended ETH transfers.
     */
    receive() external payable {
        revert("Receive function not supported");
    }
}
