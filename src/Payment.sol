// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Payment {
    address payable feeRecipient; // Địa chỉ nhận phí
    uint256 feePerc; // Tỷ lệ phí (phần trăm)

    address operator; // Địa chỉ điều hành hợp đồng

    event BuyIn(address indexed user, bytes32 hashedPrompt, uint256 amount);

    constructor(address feeRecipientAddress, uint256 feePerc_) {
        feeRecipient = payable(feeRecipientAddress);
        feePerc = feePerc_;
        operator = msg.sender;
    }

    modifier isOperator() {
        require(msg.sender == operator, "Only operator can perform this action");
        _;
    }

    // Cập nhật operator
    function setOperator(address operator_) public isOperator {
        operator = operator_;
    }

    // Cập nhật địa chỉ nhận phí
    function setFeeRecipient(address feeRecipientAddress) public isOperator {
        feeRecipient = payable(feeRecipientAddress);
    }

    // Cập nhật tỷ lệ phí
    function setFee(uint256 feePerc_) public isOperator {
        require(feePerc_ <= 30, "Fee cannot exceed 30%");
        feePerc = feePerc_;
    }

    // 
    function applyFee(uint256 amount) private returns (uint256) {
        uint256 fee = (amount * feePerc) / 100; // Tính phí
        if (fee > 0) {
            (bool success, ) = feeRecipient.call{value: fee}(""); // Chuyển phí
            require(success, "Fee transfer failed");
        }
        return amount - fee; // Trả lại số tiền còn lại
    }

    // Hàm BuyIn chính
    function buyIn(bytes32 hashedPrompt) public payable {
        uint256 amountIn = msg.value; // Số ETH gửi vào
        require(
            amountIn > 0.0001 ether,
            "Amount must be greater than 0.0001 ether"
        );

        uint256 amountAfterFee = applyFee(amountIn); // Trừ phí
        require(amountAfterFee > 0, "Remaining amount must be greater than 0");

        // Lưu lại sự kiện giao dịch
        emit BuyIn(msg.sender, hashedPrompt, amountIn);
    }

    // Fallback để ngăn ETH gửi trực tiếp
    fallback() external payable {
        revert("Fallback function not supported");
    }

    // Hàm nhận ETH (không hỗ trợ trực tiếp)
    receive() external payable {
        revert("Receive function not supported");
    }
}
