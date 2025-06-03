// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract WrapperContract is ERC20 {

    error ZeroAddressNotAllowed();

    error CantSendZero();

    using SafeERC20 for IERC20;

    IERC20 token;

    enum AssetType {TOKEN, ETH}

    AssetType public assetType;


    constructor (address _tokenAddress, AssetType _asset)  ERC20("WRAPPED SINCLAIR", "WSIN"){
        

        assetType = _asset;

        if(assetType == AssetType.TOKEN) {
            if(_tokenAddress == address(0)) revert ZeroAddressNotAllowed();
            token = IERC20(_tokenAddress);
        }
    }

    uint256 BalanceInEth;
    
    function Deposit (uint256 _amount) public payable{
        if(assetType == AssetType.ETH){
            if(msg.value <= 0) revert CantSendZero();
            _mint(msg.sender,msg.value);
        }else {
            if(_amount <= 0) revert CantSendZero();
            token.safeTransferFrom(msg.sender, address(this), _amount);
            _mint(msg.sender,_amount);
        }
    }


}