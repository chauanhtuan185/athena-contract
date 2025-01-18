// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {PayementKaia} from "../src/PaymentKaia.sol";
import {console} from "forge-std/console.sol";

contract DeployPayment is Script {
    function run() public returns (PayementKaia) {
        uint256 _deployKey = vm.envUint("PRIVATE_KEY");
        // start broacast transaction
        vm.startBroadcast(_deployKey);

        // Deploy Payment contract
        PayementKaia payment = new PayementKaia(
            vm.envAddress("MULTISIG_WALLET")
        );

        console.log("Contract address : ", address(payment));

        vm.stopBroadcast();
        return payment;
    }
} 