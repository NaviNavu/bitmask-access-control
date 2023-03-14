// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { BitmaskAccessControl } from "../src/BitmaskAccessControl.sol";
import { TestContract } from "./TestContract.sol";

contract BitmaskAccessControlTest is Test {
    address constant DEPLOYER_ADDRESS = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address constant OPERATOR = address(0x1);
    uint256 constant ROLE_ADMIN_DEFAULT = 1 << 0;
    uint256 constant ROLE_MINTER = 1 << 2;
    uint256 constant ROLE_DAO_MANAGER = 1 << 4;
    uint256 constant ROLE_NFT_MANAGER = 1 << 8;

    TestContract public testContract;

    event RoleGranted(uint256 indexed roleFlag, address indexed account, address indexed sender);
    event RoleRevoked(uint256 indexed roleFlag, address indexed account, address indexed sender);

    function setUp() public {
        vm.prank(DEPLOYER_ADDRESS);
        testContract = new TestContract();
    }

    function test_deployerHasDefaultAdminRole() public {
        assertTrue(testContract.hasRole(ROLE_ADMIN_DEFAULT, DEPLOYER_ADDRESS));
    }

    function test_grantRole() public {
        vm.expectEmit(true, true, true, true);
        emit RoleGranted(ROLE_MINTER, OPERATOR, DEPLOYER_ADDRESS);

        vm.prank(DEPLOYER_ADDRESS);
        testContract.grantRole(ROLE_MINTER, OPERATOR);

        assertTrue(testContract.hasRole(ROLE_MINTER, OPERATOR));
    }

    function test_grantRole_canHaveMultipleRoles() public {
        vm.startPrank(DEPLOYER_ADDRESS);
        testContract.grantRole(ROLE_MINTER, OPERATOR);
        testContract.grantRole(ROLE_DAO_MANAGER, OPERATOR);
        testContract.grantRole(ROLE_NFT_MANAGER, OPERATOR);
        vm.stopPrank();

        assertTrue(testContract.hasRole(ROLE_MINTER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_DAO_MANAGER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_NFT_MANAGER, OPERATOR));
    }

    function test_revokeRole() public {
        vm.startPrank(DEPLOYER_ADDRESS);
        testContract.grantRole(ROLE_MINTER, OPERATOR);
        testContract.grantRole(ROLE_DAO_MANAGER, OPERATOR);
        testContract.grantRole(ROLE_NFT_MANAGER, OPERATOR);
        vm.stopPrank();
   
        assertTrue(testContract.hasRole(ROLE_MINTER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_DAO_MANAGER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_NFT_MANAGER, OPERATOR));

        vm.expectEmit(true, true, true, true);
        emit RoleRevoked(ROLE_DAO_MANAGER, OPERATOR, DEPLOYER_ADDRESS);
        
        vm.prank(DEPLOYER_ADDRESS);
        testContract.revokeRole(ROLE_DAO_MANAGER, OPERATOR);

        // Removed ROLE_DAO_MANAGER...
        assertTrue(!testContract.hasRole(ROLE_DAO_MANAGER, OPERATOR));
        // ... but kept other roles.
        assertTrue(testContract.hasRole(ROLE_MINTER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_NFT_MANAGER, OPERATOR));
    }

    function test_renounceRole() public {
        vm.startPrank(DEPLOYER_ADDRESS);
        testContract.grantRole(ROLE_MINTER, OPERATOR);
        testContract.grantRole(ROLE_DAO_MANAGER, OPERATOR);
        testContract.grantRole(ROLE_NFT_MANAGER, OPERATOR);
        vm.stopPrank();
   
        assertTrue(testContract.hasRole(ROLE_MINTER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_DAO_MANAGER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_NFT_MANAGER, OPERATOR));

        vm.expectEmit(true, true, true, true);
        emit RoleRevoked(ROLE_DAO_MANAGER, OPERATOR, OPERATOR);
        
        vm.prank(OPERATOR);
        testContract.renounceRole(ROLE_DAO_MANAGER);

        // Removed ROLE_DAO_MANAGER...
        assertTrue(!testContract.hasRole(ROLE_DAO_MANAGER, OPERATOR));
        // ... but kept other roles.
        assertTrue(testContract.hasRole(ROLE_MINTER, OPERATOR));
        assertTrue(testContract.hasRole(ROLE_NFT_MANAGER, OPERATOR));
    }
}
