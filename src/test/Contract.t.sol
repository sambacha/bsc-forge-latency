// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.6;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import "../Safemoon.sol";
// for cheatcodes

contract BTest is DSTestPlus {

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
        router = token.uniswapV2Router();
        uniswapV2Pair = token.uniswapV2Pair();
        token.approve(address(router),type(uint256).max);
        router.addLiquidityETH{value: 1 ether}(address(token), supply/10, 0, 0, address(this), block.timestamp);
        buy_path = new address[](2);
        buy_path[0] = router.WETH();
        buy_path[1] = address(token);
        sell_path = new address[](2);
        sell_path[0] = address(token);
        sell_path[1] = router.WETH();

    }

    function testBuyFees(address buyer,uint96 amount) public {
        //address buyer=address(this); uint256 amount = supply/100;
        vm.assume(buyer!=address(0));
        vm.assume(amount!=0 && amount<supply/1000 && !token.isExcludedFromFee(buyer) );
        uint balanceBefore = token.balanceOf(buyer);
        uint[] memory amounts=router.getAmountsIn(amount, buy_path);
        console.log(amounts[0],amounts[1]);
        router.swapETHForExactTokens{value: amounts[0]}(amount, buy_path, buyer, block.timestamp);
        uint balanceAfter = token.balanceOf(buyer);
        //console.log(balanceAfter-balanceBefore);
        uint256 buyFees=token._liquidityFee();
        assertEq(amount-(balanceAfter-balanceBefore),amount*buyFees/100);
    }

    function testSellFees(address seller,uint96 amount) public {
        vm.assume(seller!=address(0));
        vm.assume(amount> 1 ether && amount<=token.balanceOf(address(this))&& !token.isExcludedFromFee(seller) && amount<=token._maxTxAmount());
        token.transfer(seller,amount);
        vm.startPrank(seller);
        vm.deal(seller, 100 ether);
        uint256 sellFees=token._liquidityFee();
        uint balanceBeforeToken = token.balanceOf(seller);
        assertEq(balanceBeforeToken,amount);
        uint balanceBeforeETH = address(seller).balance;
        uint[] memory amounts=router.getAmountsOut(amount, sell_path);
        uint[] memory amountsTaxed=router.getAmountsOut(amount-amount*sellFees/100, sell_path);
        //console.log(amounts[0],amounts[1]);
        //console.log(amountsTaxed[0],amountsTaxed[1]);
        token.approve(address(router),type(uint256).max);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, sell_path, seller, block.timestamp);
        uint balanceAfterETH = address(seller).balance;
        //console.log(balanceAfter-balanceBefore);
        
        assertEq(balanceAfterETH-balanceBeforeETH,amountsTaxed[1]);
    }

    receive() payable external {}

}