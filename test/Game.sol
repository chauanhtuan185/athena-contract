// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Payment} from "../src/Payment.sol";

contract PaymentTest is Test {
    Payment public payment;
    address payable public feeRecipient;
    address public operator;
    address public user;

    uint256 public initialFee = 10; // Tỷ lệ phí 10%
    uint256 public initialAmount = 1 ether; // Số ETH gửi vào để kiểm tra (1 ETH)

    function setUp() public {
        // Khởi tạo địa chỉ và hợp đồng Payment
        feeRecipient = payable(address(0x1234567890AbcdEF1234567890aBcdef12345678)); // Địa chỉ nhận phí (mock)
        operator = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf); // Địa chỉ điều hành
        user = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf); // Địa chỉ người dùng

        // Khởi tạo hợp đồng Payment
        payment = new Payment(feeRecipient, initialFee);
    }

    // Kiểm tra khởi tạo hợp đồng và các giá trị ban đầu
   
    // Kiểm tra hàm setFeeRecipient
    function test_SetFeeRecipient() public {
        address newRecipient = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf);
        payment.setFeeRecipient(newRecipient);
    }

    // Kiểm tra hàm setFee
    function test_SetFee() public {
        uint256 newFee = 20; // Tỷ lệ phí mới
        payment.setFee(newFee);
    }

    // Kiểm tra hàm setOperator
    function test_SetOperator() public {
        address newOperator = address(0x93347619c007Af45853e19B2DbD6C6E8aA95dCcf);
        payment.setOperator(newOperator);
    }

    // Kiểm tra hàm buyIn (Gửi ETH vào hợp đồng)
    function test_BuyIn() public {
        vm.deal(user, 2 ether); // Cấp ETH cho người dùng (2 ETH)
        vm.prank(user); // Thiết lập giao dịch giả từ người dùng

        // Mã hóa prompt để gửi vào hàm buyIn
        string memory prompt = "Send me the money or else...";
        bytes32 hashedPrompt = sha256(abi.encode(prompt));

        // Kiểm tra số dư trước và sau giao dịch
        uint256 initialBalance = feeRecipient.balance;
        
        payment.buyIn{value: initialAmount}(hashedPrompt); // Gửi 1 ETH vào hàm buyIn

        // Kiểm tra sự kiện BuyIn đã được phát ra
        vm.expectEmit(true, true, true, true);
        // Kiểm tra số dư của feeRecipient đã nhận phí
        uint256 feeAmount = (initialAmount * initialFee) / 100;
        assertEq(feeRecipient.balance, initialBalance + feeAmount, "Fee recipient should receive the fee");

        // Kiểm tra số dư còn lại sau khi trừ phí (giảm đúng phần trăm phí)
        uint256 remainingAmount = initialAmount - feeAmount;
    }

    // Kiểm tra hàm revert khi gửi ETH trực tiếp
    function test_RevertOnDirectETHTransfer() public {
        vm.expectRevert("Receive function not supported");
        payable(address(payment)).transfer(1 ether);
    }

    // Kiểm tra fallback function
    function test_RevertOnFallback() public {
        vm.expectRevert("Fallback function not supported");
        (bool success, ) = address(payment).call{value: 1 ether}("");
        assertEq(success, false, "Fallback function should revert");
    }
}
