// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
// SushiBar is the coolest bar in town. You come in with some Sushi, and leave with more! The longer you stay, the more Sushi you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.
contract SushiBar is ERC20("SushiBar", "xSUSHI"){
    using SafeMath for uint256;
    uint256 startTime;
    IERC20 public sushi;
    event staked(uint256 amount);
    event unStaked(uint256 amount);

    // Define the Sushi token contract
    //0x6B3595068778DD592e39A122f4f5a5cF09C90fE2
    constructor(IERC20 _sushi) public {
        sushi = _sushi;
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks Sushi and mints xSushi
    function enter(uint256 _amount) public {
        //start time
        startTime =block.timestamp;
        // Gets the amount of Sushi locked in the contract
        uint256 totalSushi = sushi.balanceOf(address(this));
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // If no xSushi exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xSushi the Sushi is worth. The ratio will change overtime, as xSushi is burned/minted and Sushi deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount*totalShares/(totalSushi);
            _mint(msg.sender, what);
        }
        // Lock the Sushi in the contract
        sushi.transferFrom(msg.sender, address(this), _amount);
        emit staked(_amount);
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unlocks the staked + gained Sushi and burns xSushi
    function leave(uint256 _share) public {
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        //Calculates the amount of Sushi the xSushi is worth
        uint256 what = _share.mul(sushi.balanceOf(address(this))).div(totalShares);

        //2 days - 0% can be unstaked
        require(block.timestamp > startTime + 48 hours, "0% unstack if withdraw before 2 days");
        
        //2-4 days - 25% can be unstaked
        if(block.timestamp > startTime +  48 hours || block.timestamp < startTime + 96 hours ){
            uint256 reward = 25 % what;
            uint256 tax = 75 % what;
            _burn(msg.sender, _share);
            //75% Tax will go back to contract
            sushi.transferFrom(msg.sender,address(this),tax);
            //25% only unstaked 
            sushi.transfer(msg.sender, reward);
            emit unStaked(reward);
        }

        //4-6 days - 50% can be unstaked
          if(block.timestamp > startTime +  4 days || block.timestamp < startTime + 6 days ){
            uint256 reward = 50 % what;
            uint256 tax = 50 % what;
            _burn(msg.sender, _share);
            //50% Tax will go back to contract
            sushi.transferFrom(msg.sender,address(this),tax);
            //50% only unstaked 
            sushi.transfer(msg.sender, reward);
            emit unStaked(reward);
        }
        
        //6-8 days - 75% can be unstaked
         if(block.timestamp > startTime +  6 days || block.timestamp < startTime + 8 days ){
            uint256 reward = 75 % what;
            uint256 tax = 25 % what;
            _burn(msg.sender, _share);
            //25% Tax will go back to contract
            sushi.transferFrom(msg.sender,address(this),tax);
            //75% only unstaked 
            sushi.transfer(msg.sender, reward);
            emit unStaked(reward);

        }
        //After 8 days - 100% can be unstaked
        if(block.timestamp > startTime +  8 days){
            _burn(msg.sender, _share);
            //100% unstaked and no tax deduction
            sushi.transfer(msg.sender, what);
            emit unStaked(what);

        }


    }
}