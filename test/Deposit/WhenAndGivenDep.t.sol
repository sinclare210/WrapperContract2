// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DepositTest {
    modifier givenAssetTypeIsETH() {
        _;
    }

    function test_GivenMsgValueIs0() external givenAssetTypeIsETH {
        // it should revert with CantSendZero
    }

    function test_GivenMsgValueIsGreaterThan0() external givenAssetTypeIsETH {
        // it should mint msg value amount of WSIN tokens to msg sender
        // it should increase BalanceInEth by msg value
        // it should increase BalanceInEthForUser [msg sender] by msg value
        // it should increase contract's ETH balance by msg value
        // it should emit Deposited(msg sender, msg value, AssetType ETH)
    }

    modifier givenAssetTypeIsTOKEN() {
        _;
    }

    function test_Given_amountIs0() external givenAssetTypeIsTOKEN {
        // it should revert with CantSendZero
    }

    modifier given_amountIsGreaterThan0() {
        _;
    }

    function test_GivenTransferFromFails() external givenAssetTypeIsTOKEN given_amountIsGreaterThan0 {
        // it should revert with "SafeERC20: low-level call failed"
    }

    function test_GivenTransferFromSucceeds() external givenAssetTypeIsTOKEN given_amountIsGreaterThan0 {
        // it should mint _amount of WSIN tokens to msg sender
        // it should transfer _amount tokens from msg sender to contract
        // it should increase contract's token balance by _amount
        // it should emit Deposited(msg sender, _amount, AssetType TOKEN)
    }
}
