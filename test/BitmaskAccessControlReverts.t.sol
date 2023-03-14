pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { BitmaskAccessControl } from "../src/BitmaskAccessControl.sol";
import { TestContract } from "./TestContract.sol";

contract BitmaskAccessControlTestReverts is Test {
    address constant DEPLOYER_ADDRESS = address(0x2);
    address constant OPERATOR = address(0x1);
    uint256 constant ROLE_ADMIN_DEFAULT = 1 << 0;
    uint256 constant ROLE_MINTER = 1 << 2;
    bytes4 public constant ERR_NOT_AUTHORIZED = 0x82b42900;
    bytes4 public constant ERR_ROLE_ALREADY_ASSIGNED = 0x8b0eb420;
    bytes4 public constant ERR_ROLE_NOT_ASSIGNED = 0xbfcea5b7;


    TestContract public testContract;

    function setUp() public {
        vm.prank(DEPLOYER_ADDRESS);
        testContract = new TestContract();
    }

    function test_grantRole_Unauthorized() public {
        vm.expectRevert(ERR_NOT_AUTHORIZED);

        vm.prank(OPERATOR);
        testContract.grantRole(ROLE_ADMIN_DEFAULT, OPERATOR);
    }

    function test_grantRole_RoleAlreadyAssignedToUser() public {
        vm.expectRevert(
            abi.encodeWithSelector(ERR_ROLE_ALREADY_ASSIGNED, ROLE_ADMIN_DEFAULT, DEPLOYER_ADDRESS)
        );

        vm.prank(DEPLOYER_ADDRESS);
        testContract.grantRole(ROLE_ADMIN_DEFAULT, DEPLOYER_ADDRESS);
    }

     function test_revokeRole_Unauthorized() public {
        vm.expectRevert(ERR_NOT_AUTHORIZED);
        
        vm.prank(OPERATOR);
        testContract.revokeRole(ROLE_ADMIN_DEFAULT, DEPLOYER_ADDRESS);
    }

    function test_revokeRole_RoleNotAssignedToUser() public {
        assertTrue(!testContract.hasRole(ROLE_MINTER, OPERATOR));

        vm.expectRevert(
            abi.encodeWithSelector(ERR_ROLE_NOT_ASSIGNED, ROLE_MINTER, OPERATOR)
        );
        
        vm.prank(DEPLOYER_ADDRESS);
        testContract.revokeRole(ROLE_MINTER, OPERATOR);
    }

    function test_renounceRole_RoleNotAssignedToUser() public {
        assertTrue(!testContract.hasRole(ROLE_MINTER, OPERATOR));

        vm.expectRevert(
            abi.encodeWithSelector(ERR_ROLE_NOT_ASSIGNED, ROLE_MINTER, OPERATOR)
        );
        
        vm.prank(OPERATOR);
        testContract.renounceRole(ROLE_MINTER);
    }
}