// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract WithdrawTest {
    function test_Given_amountIs0() external {
        // it should revert with CantSendZero
    }

    modifier given_amountIsGreaterThan0() {
        _;
    }

    function test_GivenMsgSenderHasInsufficientWSINBalance() external given_amountIsGreaterThan0 {
        // it should revert with "ERC20: burn amount exceeds balance"
    }

    modifier givenMsgSenderHasSufficientWSINBalance() {
        _;
    }

    modifier givenAssetTypeIsETH() {
        _;
    }

    function test_GivenBalanceInEthForUserMsgSenderLessThan_amount()
        external
        given_amountIsGreaterThan0
        givenMsgSenderHasSufficientWSINBalance
        givenAssetTypeIsETH
    {
        // it should revert with InsufficientFunds
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
    }

    modifier givenAssetTypeIsTOKEN() {
        _;
    }

    function test_GivenContractHasInsufficientTokenBalance()
        external
        given_amountIsGreaterThan0
        givenMsgSenderHasSufficientWSINBalance
        givenAssetTypeIsTOKEN
    {
        // it should revert with "SafeERC20: low-level call failed"
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
    }
}
