// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Test} from "forge-std/test.sol";

import {DropsSplitter} from "../../src/splitter/DropsSplitter.sol";
import {SplitRegistry} from "../../src/splitter/SplitRegistry.sol";
import {IDropsSplitter} from "../../src/splitter/interfaces/IDropsSplitter.sol";
import {SafeSender} from "../../src/utils/SafeSender.sol";

/// @notice Test for drops splitter
contract DropsSplitterTest is Test {
    using SafeSender for address payable;
    SplitRegistry public registry;
    DropsSplitter public splitter;

    function setUp() public {
        registry = new SplitRegistry();
        splitter = new DropsSplitter(registry);
    }

    function test_Init() public {
        IDropsSplitter.Share[] memory userShares = new IDropsSplitter.Share[](
            2
        );
        userShares[0].user = payable(address(0x123));
        userShares[0].numerator = 1;
        userShares[1].user = payable(address(0x124));
        userShares[1].numerator = 1;

        IDropsSplitter.Share[]
            memory platformShares = new IDropsSplitter.Share[](0);

        splitter.setup(userShares, 2, platformShares, 0);
        address payable sender = payable(address(0x03));
        vm.deal(sender, 2 ether);
        vm.prank(sender);
        // only safe in tests
        payable(address(splitter)).safeSendETH(1 ether);

        // test withdraw ETH
        splitter.withdrawETH();
    }

    function test_UpdateUser() public {
        IDropsSplitter.Share[] memory userShares = new IDropsSplitter.Share[](
            2
        );
        userShares[0].user = payable(address(0x123));
        vm.label(userShares[0].user, "user share 0");
        userShares[0].numerator = 1;
        userShares[1].user = payable(address(0x124));
        vm.label(userShares[1].user, "user share 1");
        userShares[1].numerator = 1;

        IDropsSplitter.Share[]
            memory platformShares = new IDropsSplitter.Share[](0);

        splitter.setup(userShares, 2, platformShares, 0);
        address payable sender = payable(address(0x03));
        vm.deal(sender, 2 ether);
        vm.prank(sender);

        // only safe in tests
        payable(address(splitter)).safeSendETH(1 ether);

        // test withdraw ETH
        splitter.withdrawETH();

        userShares[0].numerator = 2;
        splitter.updateUserSplit(userShares, 3);

        vm.prank(sender);

        // only safe in tests
        payable(address(splitter)).transfer(1 ether);

        // test withdraw ETH
        splitter.withdrawETH();
    }

    function test_UpdatePlatform() public {
        IDropsSplitter.Share[] memory userShares = new IDropsSplitter.Share[](
            0
        );

        IDropsSplitter.Share[]
            memory platformShares = new IDropsSplitter.Share[](1);

        platformShares[0].user = payable(address(0x0323));
        vm.label(platformShares[0].user, "platform user");
        platformShares[0].numerator = 1;

        splitter.setup(userShares, 0, platformShares, 1);

        address payable sender = payable(address(0x03));
        vm.deal(sender, 2 ether);
        vm.prank(sender);
        // only safe in tests
        payable(address(splitter)).safeSendETH(1 ether);

        splitter.setPrimaryBalance(1 ether);

        // test withdraw ETH
        splitter.withdrawETH();
    }
}