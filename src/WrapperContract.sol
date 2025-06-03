// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title WrapperContract
 * @author YourName
 * @notice This contract allows users to deposit either ETH or an ERC20 token and receive wrapped tokens in return.
 * @dev Wrapped tokens are minted 1:1 with the deposited asset (ETH or ERC20).
 */

contract WrapperContract is ERC20 {
    using SafeERC20 for IERC20;

    /// @notice Reverts when a zero address is provided
    error ZeroAddressNotAllowed();

    /// @notice Reverts when trying to deposit or withdraw zero amount
    error CantSendZero();

    /// @notice Reverts when trying to withdraw more than available balance
    error InsufficientFunds();

    /// @notice Emitted when a deposit is made
    event Deposited(address indexed user, uint256 amount, AssetType assetType);

    /// @notice Emitted when a withdrawal is made
    event Withdrawn(address indexed user, uint256 amount, AssetType assetType);

    /// @notice Enum representing the asset type (ETH or ERC20)
    enum AssetType { TOKEN, ETH }

    /// @notice The asset type being wrapped
    AssetType public assetType;

    /// @notice The ERC20 token address being wrapped (if applicable)
    IERC20 public token;

    /// @notice Total ETH balance held in the contract
    uint256 public BalanceInEth;

    /// @notice Mapping of user addresses to their ETH balances
    mapping(address => uint256) public BalanceInEthForUser;

    /**
     * @notice Constructor to initialize the wrapper
     * @param _tokenAddress The address of the ERC20 token to wrap (if applicable)
     * @param _asset The asset type (ETH or TOKEN)
     */
    constructor(address _tokenAddress, AssetType _asset) ERC20("WRAPPED SINCLAIR", "WSIN") {
        assetType = _asset;

        if (assetType == AssetType.TOKEN) {
            if (_tokenAddress == address(0)) revert ZeroAddressNotAllowed();
            token = IERC20(_tokenAddress);
        }
    }

    /**
     * @notice Deposit ETH or ERC20 and receive wrapped tokens
     * @param _amount The amount of token to deposit (for ERC20 only)
     * @dev For ETH deposits, `msg.value` must be sent. For ERC20, user must approve before calling.
     */
    function Deposit(uint256 _amount) external payable {
        if (assetType == AssetType.ETH) {
            if (msg.value <= 0) revert CantSendZero();
            BalanceInEth += msg.value;
            BalanceInEthForUser[msg.sender] += msg.value;
            _mint(msg.sender, msg.value);
            emit Deposited(msg.sender, msg.value, AssetType.ETH);
        } else {
            if (_amount <= 0) revert CantSendZero();
            token.safeTransferFrom(msg.sender, address(this), _amount);
            _mint(msg.sender, _amount);
            emit Deposited(msg.sender, _amount, AssetType.TOKEN);
        }
    }

    /**
     * @notice Withdraw deposited ETH or ERC20 by burning wrapped tokens
     * @param _amount The amount of wrapped token to burn and withdraw
     */
    function Withdraw(uint256 _amount) external {
        if (_amount <= 0) revert CantSendZero();

        _burn(msg.sender, _amount);

        if (assetType == AssetType.ETH) {
            if (BalanceInEthForUser[msg.sender] < _amount) revert InsufficientFunds();
            BalanceInEthForUser[msg.sender] -= _amount;
            BalanceInEth -= _amount;

            (bool success, ) = payable(msg.sender).call{value: _amount}("");
            require(success, "ETH transfer failed");
            emit Withdrawn(msg.sender, _amount, AssetType.ETH);
        } else {
            token.safeTransfer(msg.sender, _amount);
            emit Withdrawn(msg.sender, _amount, AssetType.TOKEN);
        }
    }

    /**
     * @notice Receive ETH directly to the contract
     * @dev Required to accept ETH in case someone sends it directly
     */
    receive() external payable {}
}
