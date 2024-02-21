// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;



import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.3/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IUniswapV2Factory.sol";

import "./IUniswapV2Pair.sol";

import "./IUniswapV2Router01.sol";

import "./IUniswapV2router02.sol";





// flash swap contract

contract flashSwap is Ownable{

    using SafeERC20 for IERC20;



    address private UniswapV2Factory;

    address private UniswapV2Router;

    address private SwapV2Router;



    address private Owner;

    uint256 public Balance;

    uint min_Amount;

    constructor(address _swapBorrow, address _swapBorrowFactory, address _swapTrade) {

        UniswapV2Router=_swapBorrow; // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

        UniswapV2Factory = _swapBorrowFactory; // 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f

        SwapV2Router = _swapTrade; // 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506

        Owner= msg.sender;

    }



    receive() external payable {}

     /*

     fallback(bytes calldata _input) external returns (bytes memory) {

        (address sender, uint256 amount0, uint256 amount1, bytes memory data) = abi.decode(_input[4:], (address, uint256, uint256, bytes));

        this.uniswapV2Call(sender, amount0, amount1, data);

    }*/

    // we'll call this function to call to call FLASHLOAN on uniswap

    function testFlashSwap(address _tokenBorrow,address _tokenReceived,uint256 _amount, uint256 _minAmountRequired)public onlyOwner{

        // check the pair contract for token borrow and weth exists

        //require(msg.sender == Owner,"Caller is not contract owner");

        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(_tokenBorrow,_tokenReceived);

        require(pair != address(0), "Pair doesn't exist");



        // right now we dont know tokenborrow belongs to which token

        address token0 = IUniswapV2Pair(pair).token0();

        address token1 = IUniswapV2Pair(pair).token1();

 

        // as a result, either amount0out will be equal to 0 or amount1out will be

        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;

        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;





        // need to pass some data to trigger uniswapv2call

        bytes memory data = abi.encode(_tokenBorrow, _minAmountRequired);



        // last parameter tells whether its a normal swap or a flash swap

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);



    }


    function gettingAmountIn(address token0, address token1, uint56 _amount0, uint56 _amount1) public view returns (uint256){
        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(token0, token1);
        require(pair != address(0), "Pair doesn't exist");
        // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
        address[] memory path = new address[](2);
        uint amountToken = _amount0 == 0 ? _amount1 : _amount0;
        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;
        (uint reserve0, uint reserve1,)=IUniswapV2Pair(pair).getReserves();
        //uint256 amountIn = IUniswapV2Router02(UniswapV2Router).getAmountIn(amountToken,reserve1,reserve0);
        uint256 amountIn;
        if (path[0] == token0 ){
            amountIn=IUniswapV2Router02(UniswapV2Router).getAmountIn(amountToken,reserve1,reserve0);
        }
        else{
            amountIn=IUniswapV2Router02(UniswapV2Router).getAmountIn(amountToken,reserve0,reserve1);
        }
        return amountIn * (10 ** 18);
    }

    function gettingAmountOut(address token0, address token1, uint56 _amount0, uint56 _amount1) public view returns (uint256){
        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(token0, token1);
        require(pair != address(0), "Pair doesn't exist");
        address[] memory path = new address[](2);
        uint amountToken = _amount0 == 0 ? _amount1 : _amount0; // 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844
        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;
        (uint reserve0, uint reserve1,)=IUniswapV2Pair(pair).getReserves();
        uint256 amountOut;
        if (path[0] == token0 ){
            amountOut=IUniswapV2Router02(UniswapV2Router).getAmountOut(amountToken,reserve1,reserve0);
        }
        else{
            amountOut=IUniswapV2Router02(UniswapV2Router).getAmountOut(amountToken,reserve0,reserve1);
        }
        return amountOut;
    }

    
    





    function changeSwap(address _swapBorrow, address _swapBorrowFactory, address _swapTrade)  public onlyOwner{

        UniswapV2Router=_swapBorrow;

        UniswapV2Factory = _swapBorrowFactory;

        SwapV2Router = _swapTrade;

    }

   



    function uniswapV2Call(address _sender,uint256 _amount0,uint256 _amount1) public  {

        // ,bytes calldata _data

        // check msg.sender is the pair contract



        // take address of token0 n token1



        address[] memory path = new address[](2);



        uint256 amountToken = _amount0 == 0 ? _amount1 : _amount0;



        uint256 deadline=block.timestamp+30;



        address token0 = IUniswapV2Pair(msg.sender).token0();



        address token1 = IUniswapV2Pair(msg.sender).token1();



        // call uniswapv2factory to getpair 



        address pair = IUniswapV2Factory(UniswapV2Factory).getPair(token0, token1);



        require(msg.sender == pair, "Sender is not a pair contract");



        require(_sender == address(this), "!sender");



        path[0] = _amount0 == 0 ? token1 : token0;



        path[1] = _amount0 == 0 ? token0 : token1;



        IERC20 token = IERC20(path[0]);

        token.approve(address(SwapV2Router), amountToken);

       

        uint amountReceived = IUniswapV2Router02(SwapV2Router).swapExactTokensForTokens(amountToken, 0, path, address(this), deadline)[1];



        (uint reserve0, uint reserve1,)=IUniswapV2Pair(msg.sender).getReserves();



        if (path[0] == token0 ){

            min_Amount=IUniswapV2Router02(UniswapV2Router).getAmountIn(amountToken,reserve1,reserve0);



        }

        else{

            min_Amount=IUniswapV2Router02(UniswapV2Router).getAmountIn(amountToken,reserve0,reserve1);

        }

 





        require(min_Amount>0, "min_amount minor");

        require(amountReceived > min_Amount, "Received tokens are not sufficient to profitable");



        Balance=IERC20(path[1]).balanceOf(address(this));

        IERC20(path[1]).safeTransfer(pair, min_Amount);



    }



    function withdraw (address _assetAddress) public onlyOwner{
        // , uint256 _quantity
        uint256 assetBalance=IERC20(_assetAddress).balanceOf(address(this));

        require(assetBalance >0,"Unsuficient balance");

        IERC20(_assetAddress).safeTransfer(msg.sender,assetBalance);



    }


    



    

}
