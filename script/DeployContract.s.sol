// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Payment} from "../src/Payment.sol";
import {console} from "forge-std/console.sol";

contract DeployPayment is Script {
    function run() public returns (Payment) {
        uint256 _deployKey = vm.envUint("PRIVATE_KEY");
        // start broacast transaction
        vm.startBroadcast(_deployKey);

        // Deploy Payment contract
        Payment payment = new Payment();

        console.log("Contract address : ", address(payment));

        vm.stopBroadcast();
        return payment;
    }
} 