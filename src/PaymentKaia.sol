// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/**
 * @title AI-Game Puzzle
 * @dev A contract that allows users to deposit Kaia into a multisig wallet and declare a winner.
 */
contract PayementKaia {
    address public multisigWallet; // Address of the multisig wallet
    address public owner; // Address of the contract owner
    address public winner; // Address of the declared winner

    /// @notice Event emitted when a deposit is made
    /// @param sender The address of the sender
    /// @param amount The amount of Kaia deposited
    event Deposit(address indexed sender, bytes32 hashedPrompt ,uint256 amount);

    /// @notice Event emitted when a winner is declared
    /// @param winner The address of the winner
    event WinnerDeclared(address indexed winner);

    /// @dev Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /**
     * @dev Constructor to initialize the contract with the multisig wallet address.
     * @param _multisigWallet The address of the multisig wallet
     */
    constructor(address _multisigWallet) {
        require(_multisigWallet != address(0), "Invalid multisig wallet address");
        multisigWallet = _multisigWallet;
        owner = msg.sender;
    }

    /**
     * @dev Function to allow users to deposit Kaia into the multisig wallet.
     *      Emits a {Deposit} event.
     */
    function BuyIn(bytes32 hashedPrompt) external payable {
        require(msg.value > 0, "You must send some Kaia");
        (bool success, ) = multisigWallet.call{value: msg.value}("");
        require(success, "Transfer to multisig wallet failed");

        emit Deposit(msg.sender, hashedPrompt , msg.value);
    }
}