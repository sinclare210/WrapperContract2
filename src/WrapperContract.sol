// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";



contract WrapperContract is ERC20 {

    error ZeroAddressNotAllowed();

    error CantSendZero();

    error InsufficientFunds();

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
    mapping (address => uint256) BalanceInEthForUser;
    
    function Deposit (uint256 _amount) public payable{
        if(assetType == AssetType.ETH){

            if(msg.value <= 0) revert CantSendZero();
            BalanceInEth += _amount;
            BalanceInEthForUser[msg.sender] += _amount;
            _mint(msg.sender,msg.value);
        }else {
            if(_amount <= 0) revert CantSendZero();
            token.safeTransferFrom(msg.sender, address(this), _amount);
            _mint(msg.sender,_amount);
        }
    }

    function Withdraw (uint256 _amount) public {
          if(assetType == AssetType.ETH){
            if(_amount <= 0) revert CantSendZero();
            if (BalanceInEthForUser[msg.sender] <= _amount) revert InsufficientFunds();
            _burn(msg.sender,_amount);
            (bool success,) =payable(msg.sender).call{value: _amount}("");
            require(success);
        }else {
            if(_amount <= 0) revert CantSendZero();
            
            _burn(msg.sender,_amount);
            token.safeTransfer(msg.sender, _amount);
        }
    }


}