// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Payment} from "../src/Payment.sol";
import {console} from "forge-std/console.sol";

contract DeployPayment is Script {
    function run() public returns (Payment) {
        // start broacast transaction
        vm.startBroadcast();

        address prizePoolAddress = address(0x707F22a820844E04Ab6aCC73e7DD026DcD7859c1); 
        uint256 poolFeePerc = 5; 

        // Deploy Payment contract
        Payment payment = new Payment(
            prizePoolAddress,
            poolFeePerc
        );

        console.log("Smart Contract address : ", address(payment));

        vm.stopBroadcast();
        return payment;
    }
} 