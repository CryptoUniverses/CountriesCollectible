// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Lottery.sol";

/**
* @title ERC721 Lottery utils methods
* @author Youness Chetoui
*/
contract LotteryUtils is Lottery {

    /**
    * @notice Get stats by lottery
    * @param _id of lottery
    * @return uint256 ticket_available, uint256 nb_player
    */
    function getlotteryAvailableStats(uint256 _id) public view onlyOwner returns(uint256 ticket_available, uint256 nb_player) {
        require(lotteryAvailable[_id].created, "Lottery not found");
        return (lotteryAvailable[_id].ticket_available, lotteryAvailable[_id].nb_player);
    }
}
