// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { BitmaskAccessControl } from "../src/BitmaskAccessControl.sol";

contract Example is BitmaskAccessControl {
    // You can add up to 255 Roles if using 1 bit shifts
    uint256 public constant ROLE_MINTER = 1 << 2;
    uint256 public constant ROLE_DAO_MANAGER = 1 << 4;
    uint256 public constant ROLE_NFT_MANAGER = 1 << 8;

    address minter;
    address daoManager;
    address nftManager;

    constructor(address _minter, address _daoManager, address _nftManager) {
        minter = _minter;
        daoManager = _daoManager;
        nftManager = _nftManager;

        _grantRole(ROLE_MINTER, _minter);
        _grantRole(ROLE_DAO_MANAGER, _daoManager);
        _grantRole(ROLE_NFT_MANAGER, _nftManager);

        // The `ROLE_ADMIN_DEFAULT` role is granted to this contract deployer's address.
        // Here you can grant the default admin role to another address then revoke the
        // the deployer`s admin role if needed:
        //
        // _grantRole(ROLE_ADMIN_DEFAULT, address(0x...));
        // _revokeRole(ROLE_ADMIN_DEFAULT, msg.sender);
    }

    function onlyAdminFunction() external onlyRole(ROLE_ADMIN_DEFAULT) {
        // ...
    }

    function onlyMinterFunction() external onlyRole(ROLE_MINTER) {
        // ...
    }

    function onlyDaoManagerFunction() external onlyRole(ROLE_DAO_MANAGER) {
        // ...
    }

    function onlyNftManagerFunction() external onlyRole(ROLE_NFT_MANAGER) {
        // ...
    }
}