// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract WhenAndGivenTestForConstructor {
    modifier givenAssetTypeIsTOKEN() {
        _;
    }

    function test_Given_tokenAddressIsAddress0() external givenAssetTypeIsTOKEN {
        // it should revert with ZeroAddressNotAllowed
    }

    function test_Given_tokenAddressIsValid() external givenAssetTypeIsTOKEN {
        // it should set token to _tokenAddress
        // it should set assetType to TOKEN
        // it should set name to "WRAPPED SINCLAIR"
        // it should set symbol to "WSIN"
    }

    function test_GivenAssetTypeIsETH() external {
        // it should set assetType to ETH
        // it should not set token address
        // it should set name to "WRAPPED SINCLAIR"
        // it should set symbol to "WSIN"
    }
}
