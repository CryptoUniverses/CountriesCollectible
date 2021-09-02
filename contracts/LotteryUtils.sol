// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Lottery.sol";

/**
* @title ERC721 Lottery utils methods
* @author Youness Chetoui
*/
contract LotteryUtils is Lottery {

    /**
    * @notice Get all lottery available
    * @return LotteryAvailable[] lottery
    */
    function getlotteryAvailable() public view onlyOwner returns(LotteryAvailable[] memory) {
        LotteryAvailable[] memory lotterys;
        for(uint256 i; i < arrayLotteryAvailable.length; i++) {
            lotterys[i] = lotteryAvailable[arrayLotteryAvailable[i]];
        }

        return lotterys;
    }
}
