// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IPancakeRouter02.sol";
import {NDR} from "./NDR.sol";

contract Exchange is Pausable , Ownable {
    address private constant BSC_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address private constant USDT = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;

    using SafeMath for uint256;

    uint256 fee; 
    address wallet;
    //BNB
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0x7F8caD4690A38aC28BDA3D132eF83DB1C17557Df);
    int public fetchedPrice = ((fetchLatestPrice()*10**18/31000000000000000000)*10000000000);
    NDR public token;
    IERC20 public exchangeToken;

    constructor(address _wallet) {
        wallet = _wallet;
        fee = 1000000000000000000;
        token = NDR(0x16ae1a23e9a0FD4dD7513427108b1B300D8C6042);
    }

    event buy (address _buyer, uint256 _amount);
    event sell (address _seller, uint256 _amount);

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint _amountIn,
        uint _amountOutMin,
        address _to
    ) external {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(BSC_ROUTER, _amountIn);

        address[] memory path;
        if (_tokenIn == USDT || _tokenOut == USDT) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }

        IPancakeRouter02(BSC_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint _amountIn
    ) external view returns (uint) {
        address[] memory path;
        if (_tokenIn == USDT || _tokenOut == USDT) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = USDT;
            path[2] = _tokenOut;
        }

        // same length as path
        uint[] memory amountOutMins =
        IPancakeRouter02(BSC_ROUTER).getAmountsOut(_amountIn, path);

        return amountOutMins[path.length - 1];
    }

    function fetchLatestPrice() internal view returns (int) {
        (
            uint80 _roundID, 
            int price,
            uint _startedAt,
            uint _timeStamp,
            uint80 _answeredInRound
        ) = priceFeed.latestRoundData();
        return price ;
    }

    //setups the exchange ---------------------------------------

     function changeWallet(address _wallet) public onlyOwner {
        wallet = _wallet;
    }

    function changeFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function changeTokenAddress(address _token) public onlyOwner {
        token = NDR(_token);
    }
    //----------------------------------------------------------------

    function buyToken(uint _amount, address _exchange)  public  whenNotPaused {
        int goldPrice = ((fetchLatestPrice()*10**18/31000000000000000000)*10000000000); 
        exchangeToken = IERC20(_exchange);
        uint256 feeAmount = _amount.mul(fee).div(100 * 10 ** 18);
        uint256 amount = _amount - feeAmount;
        require(exchangeToken.balanceOf(msg.sender) >= _amount, "No tienes saldo suficiente");
        uint totalToken = (amount*10**18) / uint(goldPrice);

        // token.mint(msg.sender, totalToken);
        // exchangeToken.transferFrom(msg.sender, address(this), _amount);
        // exchangeToken.transfer(wallet, feeAmount);

        emit buy(msg.sender, totalToken);
    }
    
    function sellToken(uint _amount, address _exchange)  public  whenNotPaused  {
        require(token.balanceOf(msg.sender) >= _amount, "No tienes saldo suficiente");
        int goldPrice = ((fetchLatestPrice()*10**18/31000000000000000000)*10000000000);
        exchangeToken = IERC20(_exchange);
        uint totalexchangeToken = _amount * (uint(goldPrice)/10**18);
        require(exchangeToken.balanceOf(address(this)) >= totalexchangeToken, "El contrato no tiene saldo suficiente");
        uint256 feeAmount = totalexchangeToken.mul(fee).div(100 * 10 ** 18); 
        uint256 amount = totalexchangeToken - feeAmount;

        // token.burnFrom(msg.sender, _amount);
        // exchangeToken.transfer(wallet, feeAmount);
        // exchangeToken.transfer(msg.sender, amount);

        emit sell(msg.sender, _amount);
    }

        function tokenBalance(address _token) public view returns (uint256) {
        IERC20 balanceAddress = IERC20(_token);
        return balanceAddress.balanceOf(address(this));
    }


    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner{
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }

    function withdrawBNB() public payable onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
}







