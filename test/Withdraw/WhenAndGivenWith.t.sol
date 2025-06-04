// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {WrapperContract} from "./../../src/WrapperContract.sol";
import {WrapperContractTest} from "../WrapperContract.t.sol";

contract WithdrawTest is WrapperContractTest{
    

    function test_Given_amountIs0() external {
        // it should revert with CantSendZero
        vm.startPrank(sinc);
        vm.expectRevert(WrapperContract.CantSendZero.selector);
        wrapperContract.Withdraw(0);
        vm.stopPrank();
    }

    modifier given_amountIsGreaterThan0() {
        _;
    }

    function test_GivenMsgSenderHasInsufficientWSINBalance() external given_amountIsGreaterThan0 {
        // it should revert with "ERC20: burn amount exceeds balance"
        vm.startPrank(sinc);
        vm.expectRevert();
        wrapperContract.Withdraw(1000000000);
        vm.stopPrank();
    }

    modifier givenMsgSenderHasSufficientWSINBalance() {
        _;
    }

    modifier givenAssetTypeIsETH() {
        wrapperContract = new WrapperContract(address(0), WrapperContract.AssetType.ETH);
        _;
    }

    function test_GivenBalanceInEthForUserMsgSenderLessThan_amount()
        external
        given_amountIsGreaterThan0
        givenMsgSenderHasSufficientWSINBalance
        givenAssetTypeIsETH
    {
        // it should revert with InsufficientFunds
        vm.deal(sinc, 2 ether);
        vm.startPrank(sinc);

        wrapperContract.Deposit{value: DepositAmount}(0);
        vm.expectRevert();
        wrapperContract.Withdraw(2 ether);
        vm.stopPrank();
    }

    function test_GivenBalanceInEthForUserMsgSenderGreaterThanOrEqualTo_amount()
        external
        given_amountIsGreaterThan0
        givenMsgSenderHasSufficientWSINBalance
        givenAssetTypeIsETH
    {
        // it should burn _amount WSIN tokens from msg sender
        // it should decrease BalanceInEthForUser msg sender by _amount
        // it should decrease BalanceInEth by _amount
        // it should transfer _amount ETH to msg sender
        // it should emit Withdrawn(msg sender, _amount, AssetType ETH)
        
        uint256 withdrawAmount = 0.5 ether;
        vm.deal(sinc, 2 ether);
        vm.startPrank(sinc);

        // Get initial balances BEFORE deposit
        uint256 initialWSINBalance = wrapperContract.balanceOf(sinc);
        uint256 initialBalanceInEth = wrapperContract.BalanceInEth();
        uint256 initialUserEthInContract = wrapperContract.BalanceInEthForUser(sinc);
        uint256 initialSincEthBalance = sinc.balance;

        // Make deposit
        wrapperContract.Deposit{value: DepositAmount}(0);

        // Get balances after deposit, before withdrawal
        uint256 balanceAfterDeposit = wrapperContract.balanceOf(sinc);
        uint256 ethBalanceAfterDeposit = wrapperContract.BalanceInEth();
        uint256 userEthAfterDeposit = wrapperContract.BalanceInEthForUser(sinc);

        // Expect withdrawal event
        vm.expectEmit(true, false, false, true);
        emit Withdrawn(sinc, withdrawAmount, WrapperContract.AssetType.ETH);

        // Make withdrawal
        wrapperContract.Withdraw(withdrawAmount);

        // Verify WSIN tokens were burned
        assertEq(
            wrapperContract.balanceOf(sinc),
            balanceAfterDeposit - withdrawAmount
        );

        // Verify BalanceInEthForUser decreased
        assertEq(
            wrapperContract.BalanceInEthForUser(sinc),
            userEthAfterDeposit - withdrawAmount
        );

        // Verify BalanceInEth decreased
        assertEq(
            wrapperContract.BalanceInEth(),
            ethBalanceAfterDeposit - withdrawAmount
        );

        // Verify ETH was transferred to user
        assertEq(
            sinc.balance,
            initialSincEthBalance - DepositAmount + withdrawAmount
        );

        vm.stopPrank();
    }

    modifier givenAssetTypeIsTOKEN() {
        wrapperContract = new WrapperContract(address(sinclair), WrapperContract.AssetType.TOKEN);
        _;
    }

    function test_GivenContractHasInsufficientTokenBalance()
        external
        given_amountIsGreaterThan0
        givenMsgSenderHasSufficientWSINBalance
        givenAssetTypeIsTOKEN
    {
        // it should revert with "SafeERC20: low-level call failed"
        vm.startPrank(sinc);
        sinclair.mint(sinc, 100000);
        sinclair.approve(address(wrapperContract), type(uint256).max);
        wrapperContract.Deposit(50000);
        vm.stopPrank();

        // Transfer tokens out of contract to make it insufficient
        vm.startPrank(address(wrapperContract));
        sinclair.transfer(address(0x123), sinclair.balanceOf(address(wrapperContract)));
        vm.stopPrank();

        vm.startPrank(sinc);
        vm.expectRevert();
        wrapperContract.Withdraw(10000);
        vm.stopPrank();
    }

    function test_GivenContractHasSufficientTokenBalance()
        external
        given_amountIsGreaterThan0
        givenMsgSenderHasSufficientWSINBalance
        givenAssetTypeIsTOKEN
    {
        // it should burn _amount WSIN tokens from msg sender
        // it should transfer _amount tokens to msg sender
        // it should decrease contract's token balance by _amount
        // it should emit Withdrawn(msg sender, _amount, AssetType TOKEN)
        
        uint256 depositAmount = 50000;
        uint256 withdrawAmount = 10000;
        
        vm.startPrank(sinc);
        sinclair.mint(sinc, 100000);
        sinclair.approve(address(wrapperContract), type(uint256).max);
        
        // Get initial balances
        uint256 initialUserTokenBalance = sinclair.balanceOf(sinc);
        uint256 initialContractTokenBalance = sinclair.balanceOf(address(wrapperContract));
        
        // Make deposit
        wrapperContract.Deposit(depositAmount);
        
        // Get balances after deposit
        uint256 userWSINBalance = wrapperContract.balanceOf(sinc);
        uint256 userTokenAfterDeposit = sinclair.balanceOf(sinc);
        uint256 contractTokenAfterDeposit = sinclair.balanceOf(address(wrapperContract));
        
        // Expect withdrawal event
        vm.expectEmit(true, false, false, true);
        emit Withdrawn(sinc, withdrawAmount, WrapperContract.AssetType.TOKEN);
        
        
        wrapperContract.Withdraw(withdrawAmount);
        
        
        assertEq(
            wrapperContract.balanceOf(sinc),
            userWSINBalance - withdrawAmount
        );
        
        assertEq(
            sinclair.balanceOf(sinc),
            userTokenAfterDeposit + withdrawAmount
            
        );
        
        assertEq(
            sinclair.balanceOf(address(wrapperContract)),
            contractTokenAfterDeposit - withdrawAmount
        );
        
        vm.stopPrank();
    }

    event Withdrawn(address indexed user, uint256 amount, WrapperContract.AssetType assetType);
}