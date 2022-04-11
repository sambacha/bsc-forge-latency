// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import "../Safemoon.sol";
// for cheatcodes

contract ATest is DSTestPlus {

SafeMoon token;
IUniswapV2Router02 router;
address public uniswapV2Pair;

string name ="SafeMoon";
string ticker = "SAFEMOON";
uint decimals = 9;
uint256 supply = 10**15* 10**decimals;
address[] sell_path;
address[] buy_path;
    
    function setUp() public {
        token = new SafeMoon();
    }

    function testOwnerisDeployer(address deployer) public {
        vm.assume(deployer!=address(0));
        vm.startPrank(deployer);
        vm.deal(deployer, 1 ether);
        SafeMoon _token = new SafeMoon();
        assertEq(_token.owner(),deployer);
    }

    function testSupply() public {

        assertEq(token.totalSupply(),supply);
        
    }
    function testName() public {
        assertEq(token.name(),name);
    }
    function testTicker() public {
        assertEq(token.symbol(),ticker); 
    }
    function testDecimals() public {
        assertEq(token.decimals(),decimals); 
    }


}
