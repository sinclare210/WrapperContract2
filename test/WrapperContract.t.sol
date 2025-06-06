// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Sinclair} from "../src/Sinclair.sol";
import {WrapperContract} from "../src/WrapperContract.sol";

contract WrapperContractTest is Test {
    Sinclair public sinclair;
    WrapperContract public wrapperContract;

    address sinc = address(0x1);

    uint256 public constant DepositAmount = 1 ether;

    function setUp() external {
        sinclair = new Sinclair(sinc);
        wrapperContract = new WrapperContract(address(sinclair), WrapperContract.AssetType.TOKEN);
    }
}
