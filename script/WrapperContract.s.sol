// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {WrapperContract} from "../src/WrapperContract.sol";

// sinclair-0x866a9dd11387267a30f89d053b46c47e01f170bb
//0x4f378eb1dc3673fd78d795e39cc42745efc9018f
//https://sepolia.etherscan.io/address/0x4f378eb1dc3673fd78d795e39cc42745efc9018f

contract WrapperContractScript is Script {
    WrapperContract public wrapperContract;
    function run() external {
        vm.startBroadcast();
        wrapperContract = new  WrapperContract(0x866a9Dd11387267A30F89D053B46c47e01f170bB, WrapperContract.AssetType.TOKEN);
        vm.stopBroadcast();
    }
}