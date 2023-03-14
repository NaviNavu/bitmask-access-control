
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBitmaskAccessControl {
    event RoleGranted(uint256 indexed roleFlag, address indexed account, address indexed sender);
    event RoleRevoked(uint256 indexed roleFlag, address indexed account, address indexed sender);

    function hasRole(uint256 roleFlag, address account) external view returns (bool);
    function grantRole(uint256 roleFlag, address account) external;
    function revokeRole(uint256 roleFlag, address account) external;
    function renounceRole(uint256 roleFlag) external;
}