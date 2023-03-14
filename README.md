# Bitmask Access Control
A low-level, role-based access control module using Yul and Bitmasks. Inspired by OpenZeppelin's AccessControl.

Roles can be externally granted and revoked via the `grantRole` and `revokeRole` functions by any address that have been assigned the `ROLE_ADMIN_DEFAULT` role to. Additionnaly, an user can renounce his roles by calling the `renounceRole()` function.

A child contract implementing the BitmaskAccessControl have access to its internal functions `_grantRole()`, `_revokeRoke()`, `_hasRole()` as well as the `hasRole()` function modifier.

### Example

An example implementation can be found here: [Example.sol](https://github.com/NaviNavu/bitmask-access-control/blob/main/Example.sol)

### Warnings
- Unlike OZ's AccessControl, **all roles** are governed by the `ROLE_ADMIN_DEFAULT` role.
- The `ROLE_ADMIN_DEFAULT` role is assigned to the child contract deployer's address, you can grant this role to another address and revoke the deployer's default admin role inside the child contract's constructor if needed (see: Example contract above).
- The `ROLE_ADMIN_DEFAULT` is also its own admin: **it has permission to grant, revoke and renounce this role!**

---

### Setting up the project locally

This project is using Foundry. To set it up, you must first [install Foundry](https://book.getfoundry.sh/getting-started/installation) on your machine.


Then you can clone this repository:
```
git clone https://github.com/NaviNavu/bitmask-access-control.git
cd bitmask-access-control
```

Then install the project dependencies and build the project:
```
forge install
forge build
```

To run all the tests with gas report and coverage:
```
forge test --gas-report && forge coverage
```

---

### ⛔️ Disclaimer
This is an educational project not meant to be used in production. Use it at your own risks.
