// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";
import {console} from "forge-std/console.sol";

contract DeployToken is Script {
    function setUp() public {}

    function run() public returns (Token) {
        
        // Các tham số cho Token
        uint256 initialSupply = 1000000 * 10**18; 
        string memory name = "FREYSA";
        string memory symbol = "Freysa";
        
        vm.startBroadcast(); 

        Token token = new Token(
            initialSupply,
            name,
            symbol
        );
        
        vm.stopBroadcast();
        
        console.log("Token deployed to:", address(token));
        console.log("Token name:", name);
        console.log("Token symbol:", symbol);
        console.log("Initial supply:", initialSupply);
        
        return token;
    }
}