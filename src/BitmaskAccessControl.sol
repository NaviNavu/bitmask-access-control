// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/************************************************
* Author: Navinavu (https://github.com/NaviNavu)
*************************************************/

import { IBitmaskAccessControl } from "./IBitmaskAccessControl.sol";

/// @notice A low-level, role-based access control module inspired by OpenZeppelin's AccessControl.
/// @dev Roles can be externally granted and revoked via the `grantRole()` and `revokeRole()` functions 
/// by any address that have been assigned the `ROLE_ADMIN_DEFAULT` role to.
/// Additionnaly, an user can renounce his roles by calling the `renounceRole()` function.
/// A child contract implementing the BitmaskAccessControl have access to its internal functions 
/// `_grantRole()`, `_revokeRoke()`, `_hasRole()` as well as the `hasRole()` function modifier.
///
/// ⚠️ WARNINGS:
/// - Unlike OZ's AccessControl, all roles are governed by the `ROLE_ADMIN_DEFAULT`.
/// - The `ROLE_ADMIN_DEFAULT` is assigned to the child contract deployer's address,
///   you can grant this role to another address and revoke the deployer's default 
///   admin role inside the child contract's constructor if needed.
/// - The `ROLE_ADMIN_DEFAULT` is also its own admin: it has permission to grant, revoke and renounce this role!
abstract contract BitmaskAccessControl is IBitmaskAccessControl {
    /// @dev Default admin role
    uint256 public constant ROLE_ADMIN_DEFAULT = 1 << 0;
    /// @dev Precomputed error selector: Unauthorized()
    bytes4 public constant ERR_NOT_AUTHORIZED = 0x82b42900;
    /// @dev Precomputed error selector: RoleAlreadyAssignedToUser(uint256,address)
    bytes4 public constant ERR_ROLE_ALREADY_ASSIGNED = 0x8b0eb420;
    /// @dev Precomputed error selector: RoleNotAssignedToUser(uint256,address)
    bytes4 public constant ERR_ROLE_NOT_ASSIGNED = 0xbfcea5b7;

    /// @dev userRoles[account] => rolesFlags
    mapping(address => uint256) public userRoles;
 
    constructor() {
        /// @dev automatically grants the default admin role to the child contract deployer.
        _grantRole(ROLE_ADMIN_DEFAULT, msg.sender);
    }
    
    /// @notice see `_grantRole`.
    function grantRole(uint256 _roleFlag, address _account) external virtual override onlyRole(ROLE_ADMIN_DEFAULT) {
        _grantRole(_roleFlag, _account);
        emit RoleGranted(_roleFlag, _account, msg.sender);
    }

    /// @notice see `_revokeRole`.
    function revokeRole(uint256 _roleFlag, address _account) external virtual override onlyRole(ROLE_ADMIN_DEFAULT) {
        _revokeRole(_roleFlag, _account);
        emit RoleRevoked(_roleFlag, _account, msg.sender);
    }

    /// @notice Renounces the caller's role.
    /// @param _roleFlag The role flag.
    function renounceRole(uint256 _roleFlag) external virtual override {
        _revokeRole(_roleFlag, msg.sender);
        emit RoleRevoked(_roleFlag, msg.sender, msg.sender);
    }

    /// @notice see `_hasRole`.
    function hasRole(uint256 _roleFlag, address _account) external view virtual override returns(bool) {
        return _hasRole(_roleFlag, _account);
    }

    /// @notice Verifies if a role is assigned to an account.
    /// @dev Returns TRUE if `_acccount` has `_roleFlag`, false otherwise.
    /// @param _roleFlag The role flag.
    /// @param _account The addresse to check if the role is assigned to.
    function _hasRole(uint256 _roleFlag, address _account) internal view virtual returns(bool accountHasRole) {
        assembly {
            mstore(0x0, shr(0x60, shl(0x60, _account)))
            mstore(0x20, userRoles.slot)
            accountHasRole := and(sload(keccak256(0x0, 0x40)), _roleFlag)
        }
    }

    /// @notice Grants a role to an account.
    /// @dev Reverts with `RoleAlreadyAssignedToUser(uint256,address)` if `_roleFlag`
    /// is already assigned to `_account`.
    /// @param _roleFlag The role flag.
    /// @param _account The addresse to assign the role to.
    function _grantRole(uint256 _roleFlag, address _account) internal virtual {
        assembly {
            mstore(0x0, shr(0x60, shl(0x60, _account)))
            mstore(0x20, userRoles.slot)

            let slotHash := keccak256(0x0, 0x40)
            let slotValue := sload(slotHash)
            let roleFlag := _roleFlag
            
            if gt(and(slotValue, roleFlag), 0) {
                let ptr := mload(0x40)
                mstore(ptr, ERR_ROLE_ALREADY_ASSIGNED)
                mstore(add(ptr, 0x04), roleFlag)
                mstore(add(ptr, 0x24), _account)
                revert(ptr, 0x44)
            }

            sstore(slotHash, or(slotValue, roleFlag))
        }
    }

    /// @notice Revokes an account's role.
    /// @dev Reverts with `RoleNotAssignedToUser(uint256,address)` if `_roleFlag`
    /// is not assigned to `_account`.
    /// @param _roleFlag The role flag.
    /// @param _account The addresse to revoke the role from.
    function _revokeRole(uint256 _roleFlag, address _account) internal virtual {
        assembly {
            mstore(0x0, shr(0x60, shl(0x60, _account)))
            mstore(0x20, userRoles.slot)
            
            let slotHash := keccak256(0x0, 0x40)
            let slotValue := sload(slotHash)
            let roleFlag := _roleFlag

            if iszero(and(slotValue, roleFlag)) {
                let ptr := mload(0x40)
                mstore(ptr, ERR_ROLE_NOT_ASSIGNED)
                mstore(add(ptr, 0x04), roleFlag)
                mstore(add(ptr, 0x24), _account)
                revert(ptr, 0x44)
            }

            sstore(slotHash, and(slotValue, not(roleFlag)))
        }
    }

    /// @notice Modifier to verify if a caller is authorized to access a function.
    /// @dev Reverts with `Unauthorized()` if `_roleFlag` is not assigned to the caller.
    /// @param _roleFlag The role flag.
    modifier onlyRole(uint256 _roleFlag) {
        assembly {
            mstore(0x0, shr(0x60, shl(0x60, caller())))
            mstore(0x20, userRoles.slot)

            if iszero(and(sload(keccak256(0x0, 0x40)), _roleFlag)) {
                let ptr := mload(0x40)
                mstore(ptr, ERR_NOT_AUTHORIZED)
                revert(ptr, 0x04)
            }
        }
        _;
    }
}
