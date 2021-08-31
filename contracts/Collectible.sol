// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title ERC721 collectible base methods
* @author Youness Chetoui
*/
contract Collectible is ERC721, Ownable {
    struct PoliticsAvailable {
        uint256 id;
        uint256 qty;
        uint256 level;
        uint256 price;
        string name;
        bool lottery;
        bool created;
    }

    struct PoliticsOwned {
        uint256 id;
        uint256 id_politic;
        address owner;
    }

    PoliticsAvailable[] internal politics;

    mapping(uint256 => PoliticsAvailable) internal politicsAvailable;
    mapping(address => PoliticsOwned[]) internal userOwnedPolitics;
    mapping(uint256 => address) internal politicToUser;

    address payable public ownerAddress;
    address payable public contractAddress;

    uint256 internal tokenCounter = 1;

    constructor() ERC721("PoliticsNft", "POL") {
        ownerAddress = payable(msg.sender);
        contractAddress = payable(address(this));
    }

    /**
    * @notice get politic available by id
    * @param id of politic
    * @return struct PoliticsAvailable
    */
    function getPolitic(uint256 _id) public view onlyOwner returns(PoliticsAvailable memory) {
        require(politicsAvailable[_id].created, "Politic not found");
        return politicsAvailable[_id];
    }

    /**
    * @notice get list of all politics available
    * @return Array of struct PoliticsAvailable
    */
    function getPolitics() public view onlyOwner returns (PoliticsAvailable[] memory) {
        return politics;
    }

    /**
    * @notice Get politics by user
    * @return array of struct PoliticsOwned
    */
    function getMyPolitics() public view returns (PoliticsOwned[] memory) {
        return userOwnedPolitics[msg.sender];
    }

    /**
    * @notice Create politic
    * @param name, id, qty, level, price and lottery of politic available
    * @return PoliticsAvailable created
    */
    function createType(
        string memory _name,
        uint256 _id, uint256 _qty,
        uint256 _level,
        uint256 _price,
        bool _lottery
    )
        public onlyOwner returns (PoliticsAvailable memory) {
        require(!politicsAvailable[_id].created, "id already in use");

        PoliticsAvailable memory politic =
            PoliticsAvailable({name: _name, id: _id, qty: _qty, level: _level, price: _price, lottery: _lottery, created: true});
        politics.push(politic);
        politicsAvailable[_id] = politic;

        return politic;
    }

    /**
    * @notice Add quantity for a PoliticsAvailable
    * @param id of PoliticsAvailable and qty wished
    */
    function addQty(uint256 _id, uint256 _qty) public onlyOwner {
        for (uint i = 0; i < politics.length; i++) {
            if (politics[i].id == _id && politics[i].qty < _qty) {
                politics[i].qty = _qty;
                politicsAvailable[_id] = politics[i];
            }
        }
    }

    /**
    * @notice Create politic
    * @param name, id, qty, level, price and lottery of politic available
    * @return PoliticsAvailable created
    */
    function buy(uint256 _id) external payable {
        require(politicsAvailable[_id].created, "Politic not found");
        require(!politicsAvailable[_id].lottery, "Politic only available with lottery");
        require(politicsAvailable[_id].qty > 0, "There is no more politic available");
        require(msg.value == (politicsAvailable[_id].price * 10e18) / 1000, "Incorrect amount");
        PoliticsAvailable memory politic;

        for (uint i = 0; i < politics.length; i++) {
            if (politics[i].id == _id) {
                politic = politics[i];
                politics[i].qty--;
                politicsAvailable[_id] = politics[i];
            }
        }

        uint256 id = uint256(keccak256(abi.encodePacked(tokenCounter, msg.sender))) % 10000000000;
        tokenCounter++;

        _safeMint(msg.sender, id);
        ownerAddress.transfer(msg.value);

        PoliticsOwned memory politicOwned =
            PoliticsOwned({id: id, id_politic: politic.id, owner: msg.sender});


        userOwnedPolitics[msg.sender].push(politicOwned);
        politicToUser[id] = msg.sender;
    }


    /**
    * @notice Disabled not safe transform
    */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override onlyOwner {
        //do nothing
    }

    /**
    * @notice Transfer Politic
    * @param address of nft to trasnfer, address of receveir and tokenId of PoliticsOwned
    */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override  {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);

        //Update owner of politics
        PoliticsOwned[] memory politicsFrom = userOwnedPolitics[from];
        delete userOwnedPolitics[from];
        for (uint i = 0; i < politicsFrom.length; i++) {
            if (politicsFrom[i].id != tokenId) {
                userOwnedPolitics[from].push(politicsFrom[i]);

            } else {
                politicsFrom[i].owner = to;
                userOwnedPolitics[to].push(politicsFrom[i]);
            }
        }

        politicToUser[tokenId] = msg.sender;
    }
}
