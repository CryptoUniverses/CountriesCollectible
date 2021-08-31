// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Sell.sol";

/**
* @title Base methode of lottery
* @author Youness Chetoui
*/
contract Lottery is Sell {
    struct LotteryAvailable {
        uint256 id;
        uint256 id_politics;
        uint256 end_time;
        uint256 price;
        uint256 nbPlayer;
        uint256 ticket_available;
        bool created;
    }

    mapping(uint256 => address[]) public userPlayedLottery;
    mapping(uint256 => LotteryAvailable) internal lotteryAvailable;

    uint256[] public arrayLotteryAvailable;

    function createLottery(
        uint256 _id,
        uint256 _id_politics,
        uint256 _end_time,
        uint256 _price,
        uint256 _ticket_available
    ) public onlyOwner {
        require(politicsAvailable[_id_politics].lottery, "Politic not available in lottery");
        require(!lotteryAvailable[_id].created, "Lottery already exist");
        require(block.timestamp > _end_time, "End time is in past");
        require(_price > 0, "Price is 0");
        require(_ticket_available >= 50, "Ticket availible under 50");

        LotteryAvailable memory lottery =
            LotteryAvailable({id: _id, id_politics: _id_politics, end_time: _end_time, price: _price, ticket_available: _ticket_available, nbPlayer: 0, created: true});

        arrayLotteryAvailable.push(lottery.id);
        lotteryAvailable[_id] = lottery;
    }

    function playLottery(uint256 _id) public payable {
        require(msg.value == (lotteryAvailable[_id].price * 10**18) / 1000, "Incorrect amount");
        require(lotteryAvailable[_id].created, "Lottery not available");
        require(lotteryAvailable[_id].end_time > block.timestamp, "Lottery not available");
        require(lotteryAvailable[_id].ticket_available > 0, "Lottery not available");

        address[] memory users = userPlayedLottery[_id];
        for (uint i = 0; i < users.length; i++) {
            require(users[i] != msg.sender, "Only one ticket by address");
        }

        ownerAddress.transfer(msg.value);
        userPlayedLottery[_id].push(msg.sender);
        lotteryAvailable[_id].nbPlayer++;
        lotteryAvailable[_id].ticket_available--;
    }

    function onEndLottery(uint256 _id) public onlyOwner {
        // prendre une address au hasard parmit les joueur
        require(lotteryAvailable[_id].created, "Lottery not available");
        require(block.timestamp >= lotteryAvailable[_id].end_time, "Lottery not finished");

        uint256 id_politics = lotteryAvailable[_id].id_politics;
        address memory winner;
        PoliticsAvailable memory politic;

        for (uint i = 0; i < politics.length; i++) {
            if (politics[i].id == id_politics) {
                politic = politics[i];
                politics[i].qty--;
                politicsAvailable[id_politics] = politics[i];
            }
        }

        uint256 id = uint256(keccak256(abi.encodePacked(tokenCounter, winner))) % 10000000000;
        tokenCounter++;

        _safeMint(winner, id);

        PoliticsOwned memory politicOwned =
            PoliticsOwned({id: id, id_politic: id_politics, owner: winner});


        userOwnedPolitics[winner].push(politicOwned);
        politicToUser[id] = winner;

        delete lotteryAvailable[_id];
        delete userPlayedLottery[_id];
    }

}
