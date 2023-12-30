// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {TimeLock} from "../src/TimeLock.sol";

contract MyGovernorTest is Test {
    MyGovernor governor;
    Box box;
    GovToken govToken;
    TimeLock timelock;

    address public USER = makeAddr("user");
    uint256 public constant INITIAL_SUPLY = 100 ether;
    uint256 public constant MINT_DELAY = 3600; //After a vote passes
    address[] proposers;
    address[] executers;

    function setUp() public {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timelock = new TimeLock(MINT_DELAY, proposers, executers, msg.sender);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executerRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executerRole, address(governor));
        timelock.revokeRole(adminRole, USER);
        vm.stopPrank();

        box.transferOwnership(address(timelock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }
}
