// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Payment} from "../src/Payment.sol";
import {Token} from "../src/Token.sol";
import {console} from "forge-std/console.sol";

contract DeployPayment is Script {
    function run() public returns (Payment) {
        // Bắt đầu broadcast transaction
        vm.startBroadcast();

        Token token = new Token(1000000 * 10**18, "FREYSA", "Freysa");

        address prizePoolAddress = address(0x7B10052d7cdfD8C57a4b335037b4B88B1f7A1570); 
        uint256 poolFeePerc = 5; 
        address teamAddress = address(0xf24FF3a9CF04c71Dbc94D0b566f7A27B94566cac); 
        uint256 teamFeePerc = 3; 

        // Deploy Payment contract
        Payment payment = new Payment(
            address(token),
            prizePoolAddress,
            poolFeePerc,
            teamAddress,
            teamFeePerc
        );

        console.log("Token deployed to:", address(payment));

        vm.stopBroadcast();
        return payment;
    }
} 