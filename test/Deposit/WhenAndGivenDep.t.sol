// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Test, console} from "forge-std/Test.sol";

import {WrapperContract} from "./../../src/WrapperContract.sol";
import {WrapperContractTest} from "../WrapperContract.t.sol";

contract DepositTest is WrapperContractTest {
    modifier givenAssetTypeIsETH() {
        wrapperContract = new WrapperContract(address(sinclair), WrapperContract.AssetType.ETH);
        _;
    }

    function test_GivenMsgValueIs0() external givenAssetTypeIsETH {
        // it should revert with CantSendZero
        vm.startPrank(sinc);
        vm.expectRevert(WrapperContract.CantSendZero.selector);
        wrapperContract.Deposit{value: 0 ether}(0);
        vm.stopPrank();
    }

    function test_GivenMsgValueIsGreaterThan0() external givenAssetTypeIsETH {
        // it should mint msg value amount of WSIN tokens to msg sender
        // it should increase BalanceInEth by msg value
        // it should increase BalanceInEthForUser [msg sender] by msg value
        // it should increase contract's ETH balance by msg value
        // it should emit Deposited(msg sender, msg value, AssetType ETH)
        uint256 initialContractBalance = wrapperContract.balanceOf(address(this));
        uint256 balanceOfUser = wrapperContract.balanceOf(sinc);
        vm.deal(sinc, 2 ether);
        vm.startPrank(sinc);

        wrapperContract.Deposit{value: DepositAmount}(0);
        assertEq(wrapperContract.BalanceInEth(), initialContractBalance + DepositAmount);
        assertEq(wrapperContract.BalanceInEthForUser(sinc), DepositAmount);
        assertEq(wrapperContract.balanceOf(sinc), balanceOfUser + DepositAmount);
        vm.stopPrank();
    }

    modifier givenAssetTypeIsTOKEN() {
        wrapperContract = new WrapperContract(address(sinclair), WrapperContract.AssetType.TOKEN);
        vm.startPrank(sinc);
        sinclair.approve(address(wrapperContract), type(uint256).max);
        vm.stopPrank();
        _;
    }

    function test_Given_amountIs0() external givenAssetTypeIsTOKEN {
        // it should revert with CantSendZero
        vm.startPrank(sinc);
        vm.expectRevert(WrapperContract.CantSendZero.selector);
        wrapperContract.Deposit(0);
        vm.stopPrank();
    }

    modifier given_amountIsGreaterThan0() {
        uint256 amount = 1e18;
        
        vm.startPrank(sinc);
        sinclair.mint(sinc, amount);
        sinclair.approve(address(wrapperContract), amount);
        vm.stopPrank();
        _;
    }

   

    function test_GivenTransferFromSucceeds() external givenAssetTypeIsTOKEN given_amountIsGreaterThan0 {
        // it should mint _amount of WSIN tokens to msg sender
        // it should transfer _amount tokens from msg sender to contract
        // it should increase contract's token balance by _amount
        // it should emit Deposited(msg sender, _amount, AssetType TOKEN)
        uint256 initialContractBalance = wrapperContract.balanceOf(address(this));
        uint256 balanceOfUser = sinclair.balanceOf(sinc);
        uint256 depositAmount = 1000000;
        vm.startPrank(sinc);
        console.log(initialContractBalance);
        wrapperContract.Deposit(depositAmount);

        assertEq(
            wrapperContract.balanceOf(sinc),
            initialContractBalance + depositAmount,
            "Should mint correct amount of WSIN tokens"
        );
        
        // Verify tokens transferred from user
        assertEq(
            sinclair.balanceOf(sinc),
            balanceOfUser - depositAmount,
            "Should transfer tokens from user"
        );
        
        // Verify contract's token balance increased
        assertEq(
            sinclair.balanceOf(address(wrapperContract)),
            initialContractBalance + depositAmount,
            "Should increase contract's token balance"
        );
        vm.stopPrank();
    }
}
