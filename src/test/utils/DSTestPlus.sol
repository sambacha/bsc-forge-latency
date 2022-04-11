// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {XConsole} from "./Console.sol";

import {DSTest} from "@ds/test.sol";

import {stdCheats, stdError} from "@std/stdlib.sol";
import {Vm} from "@std/Vm.sol";

contract DSTestPlus is DSTest, stdCheats {
    XConsole console = new XConsole();

    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(HEVM_ADDRESS);
}