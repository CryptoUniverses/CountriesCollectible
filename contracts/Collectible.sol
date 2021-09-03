// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title ERC721 collectible base methods
* @author Youness Chetoui
*/
contract Collectible is ERC721URIStorage, ERC721Holder, Ownable {
    struct PoliticsAvailable {
        uint256 id;
        uint256 price;
        bool lottery;
        bool created;
    }

    struct PoliticsOwned {
        uint256 id;
        uint256 id_politic;
        address owner;
    }

    mapping(uint256 => PoliticsAvailable) internal politicsAvailable;
    mapping(address => PoliticsOwned[]) internal userOwnedPolitics;
    mapping(uint256 => uint256) internal politicsAvailableQty;
    mapping(uint256 => address) internal politicToUser;

    address payable public ownerAddress;
    address payable public contractAddress;

    uint256 internal tokenCounter = 1;

    event CreatePolitician(uint256 id);
    event PoliticianBuy(address owner, uint256 id);

    constructor() ERC721("PoliticsNft", "POL") {
        ownerAddress = payable(msg.sender);
        contractAddress = payable(address(this));
    }

    /**
    * @notice Create politician
    * @param _name, _id, _qty, _level, _price and _lottery of politician available
    * @return PoliticsAvailable created
    */
    function create(
        uint256 _id,
        uint256 _price,
        uint256 _qty,
        bool _lottery
    )
        public onlyOwner {
        require(!politicsAvailable[_id].created, "id already in use");

        PoliticsAvailable memory politic =
            PoliticsAvailable({id: _id, price: _price, lottery: _lottery, created: true});
        politicsAvailableQty[_id] = _qty;
        politicsAvailable[_id] = politic;

        emit CreatePolitician(_id);
    }

    /**
    * @notice Buy politician
    * @param _id, _tokenUri of politician available
    */
    function buy(uint256 _id, string memory _tokenUri) external payable {
        require(politicsAvailable[_id].created, "Politic not found");
        require(!politicsAvailable[_id].lottery, "Politic only available with lottery");
        require(politicsAvailableQty[_id] > 0, "There is no more politic available");
        require(msg.value == ((politicsAvailable[_id].price * 10**18) / 1000), "Incorrect amount");
        PoliticsAvailable memory politic;

        politicsAvailableQty[_id]--;

        uint256 id = uint256(keccak256(abi.encodePacked(tokenCounter, msg.sender))) % 10000000000;
        tokenCounter++;

        ownerAddress.transfer(msg.value);
        _safeMint(msg.sender, id);
        _setTokenURI(id, _tokenUri);

        PoliticsOwned memory politicOwned =
            PoliticsOwned({id: id, id_politic: politic.id, owner: msg.sender});

        userOwnedPolitics[msg.sender].push(politicOwned);
        politicToUser[id] = msg.sender;

        emit PoliticianBuy(msg.sender, id);
    }
}
