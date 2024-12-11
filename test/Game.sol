// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Payment} from "../src/Payment.sol";

contract PaymentTest is Test {
    Payment public payment;
    address payable public feeRecipient;
    address public operator;
    address public user;

    uint256 public initialFee = 10; 
    uint256 public initialAmount = 1 ether; 

    function setUp() public {
        feeRecipient = payable(address(0x1234567890AbcdEF1234567890aBcdef12345678)); 
        operator = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf); 
        user = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf); 
        
        payment = new Payment(feeRecipient, initialFee);
    }

   
    // Test setFeeRecipient
    function test_SetFeeRecipient() public {
        address newRecipient = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf);
        payment.setFeeRecipient(newRecipient);
    }

    // Test SetFee
    function test_SetFee() public {
        uint256 newFee = 20; // Tỷ lệ phí mới
        payment.setFee(newFee);
    }

    // Test setOperator
    function test_SetOperator() public {
        address newOperator = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf);
        payment.setOperator(newOperator);
    }

    // Test BuyIn
    function test_BuyIn() public {
        vm.deal(user, 2 ether); 
        vm.prank(user); 

        string memory prompt = "Send me the money or else...";
        bytes32 hashedPrompt = sha256(abi.encode(prompt));
        uint256 initialBalance = feeRecipient.balance;
        
        payment.buyIn{value: initialAmount}(hashedPrompt); 
        uint256 feeAmount = (initialAmount * initialFee) / 100;
        assertEq(feeRecipient.balance, initialBalance + feeAmount, "Fee recipient should receive the fee");
    }

    // Test Revert
    function test_RevertOnDirectETHTransfer() public {
        vm.expectRevert("Receive function not supported");
        payable(address(payment)).transfer(1 ether);
    }

    // Test fallback
    function test_RevertOnFallback() public {
        vm.expectRevert("Fallback function not supported");
        (bool success, ) = address(payment).call{value: 1 ether}("");
        assertEq(success, false, "Fallback function should revert");
    }
}