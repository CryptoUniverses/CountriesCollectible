// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Sell.sol";
import "./RandomNumberConsumer.sol";

/**
* @title Base methode of lottery
* @author Youness Chetoui
*/
contract Lottery is Sell, RandomNumberConsumer {
    struct LotteryAvailable {
        uint256 id;
        uint256 id_country;
        uint256 end_time;
        uint256 price;
        uint256 nb_player;
        uint256 ticket_available;
        bool created;
    }

    mapping(uint256 => address[]) internal userPlayedLottery;
    mapping(uint256 => LotteryAvailable) internal lotteryAvailable;

    event CreateLottery(uint256 id);
    event UserPlayedLottery(uint256 id, address player);
    event EndLottery(uint256 id, address winner);

    /**
    * @notice Create lottery
    * @param _id, _id_country, _end_time, _price, _ticket_available
    */
    function createLottery(
        uint256 _id,
        uint256 _id_country,
        uint256 _end_time,
        uint256 _price,
        uint256 _ticket_available
    ) public onlyOwner {
        require(countriesAvailable[_id_country].lottery, "Country not available in lottery");
        require(!lotteryAvailable[_id].created, "Lottery already exist");
        require(block.timestamp < _end_time, "End time is in past");
        require(_price > 0, "Price is 0");
        require(_ticket_available >= 50, "Ticket availible under 50");

        LotteryAvailable memory lottery =
            LotteryAvailable({id: _id, id_country: _id_country, end_time: _end_time, price: _price, ticket_available: _ticket_available, nb_player: 0, created: true});

        lotteryAvailable[_id] = lottery;

        emit CreateLottery(_id);
    }

    /**
    * @notice Play lottery
    * @param _id of lottery
    */
    function playLottery(uint256 _id) public payable {
        require(msg.value == (lotteryAvailable[_id].price * 10**18) / 1000, "Incorrect amount");
        require(lotteryAvailable[_id].created, "Lottery not found");
        require(lotteryAvailable[_id].end_time > block.timestamp, "Lottery not available");
        require(lotteryAvailable[_id].ticket_available > 0, "No more ticket available");

        address[] memory users = userPlayedLottery[_id];
        for (uint i = 0; i < users.length; i++) {
            require(users[i] != msg.sender, "Only one ticket by address");
        }

        ownerAddress.transfer(msg.value);
        userPlayedLottery[_id].push(msg.sender);
        lotteryAvailable[_id].nb_player++;
        lotteryAvailable[_id].ticket_available--;

        emit UserPlayedLottery(_id, msg.sender);
    }

    /**
    * @notice End lottery
    * @param _id of lottery
    */
    function onEndLottery(uint256 _id) public onlyOwner {
        require(lotteryAvailable[_id].created, "Lottery not available");
        require(block.timestamp > lotteryAvailable[_id].end_time, "Lottery not finished");

        uint256 id_country = lotteryAvailable[_id].id_country;
        uint256 randomIndex =  (randomResult % userPlayedLottery[_id].length) + 1;
        address winner = userPlayedLottery[_id][randomIndex];

        uint256 id = uint256(keccak256(abi.encodePacked(tokenCounter, winner))) % 10000000000;
        tokenCounter++;

        _safeMint(winner, id);

        CountriesOwned memory countryOwned =
            CountriesOwned({id: id, id_country: id_country, owner: winner});

        userOwnedCountries[winner].push(countryOwned);
        countryToUser[id] = winner;

        delete lotteryAvailable[_id];
        delete userPlayedLottery[_id];

        emit EndLottery(_id, winner);
    }

}
