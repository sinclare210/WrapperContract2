// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Sinclair} from "../src/Sinclair.sol";

contract SinclairScript is Script {
    Sinclair public sinclair;

    function run() external{
        vm.startBroadcast();
        sinclair = new Sinclair(0x0400a49dE8E485f037f8244EA92c8d11C025C1c5);
        vm.stopBroadcast();
    }
    
    
}