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
    struct CountriesAvailable {
        uint256 id;
        uint256 price;
        bool lottery;
        string tokenUri;
        bool created;
    }

    struct CountriesOwned {
        uint256 id;
        uint256 id_country;
        address owner;
    }

    mapping(uint256 => CountriesAvailable) internal countriesAvailable;
    mapping(address => CountriesOwned[]) internal userOwnedCountries;
    mapping(uint256 => uint256) internal countriesAvailableQty;
    mapping(uint256 => address) internal countryToUser;

    address payable public ownerAddress;
    address payable public contractAddress;

    uint256 internal tokenCounter = 1;

    event CreateCountry(uint256 id);
    event CountryBuy(address owner, uint256 id);

    constructor() ERC721("CountriesCollectible", "COC") {
        ownerAddress = payable(msg.sender);
        contractAddress = payable(address(this));
    }

    /**
    * @notice Create country
    * @param _id, _qty, _price and _lottery of country available
    */
    function create(
        uint256 _id,
        uint256 _price,
        uint256 _qty,
        bool _lottery,
        string memory _tokenUri
    )
        public onlyOwner {
        require(!countriesAvailable[_id].created, "id already in use");

        CountriesAvailable memory country =
            CountriesAvailable({id: _id, price: _price, lottery: _lottery, tokenUri: _tokenUri, created: true});
        countriesAvailableQty[_id] = _qty;
        countriesAvailable[_id] = country;

        emit CreateCountry(_id);
    }

    /**
    * @notice Buy country
    * @param _id, _tokenUri of country available
    */
    function buy(uint256 _id) external payable {
        require(countriesAvailable[_id].created, "Country not found");
        require(!countriesAvailable[_id].lottery, "Country only available with lottery");
        require(countriesAvailableQty[_id] > 0, "There is no more country available");
        require(msg.value == ((countriesAvailable[_id].price * 10**18) / 1000), "Incorrect amount");

        countriesAvailableQty[_id]--;

        uint256 id = uint256(keccak256(abi.encodePacked(tokenCounter, msg.sender))) % 10000000000;
        tokenCounter++;

        ownerAddress.transfer(msg.value);
        _safeMint(msg.sender, id);
        _setTokenURI(id, countriesAvailable[_id].tokenUri);

        CountriesOwned memory countryOwned =
            CountriesOwned({id: id, id_country: _id, owner: msg.sender});

        userOwnedCountries[msg.sender].push(countryOwned);
        countryToUser[id] = msg.sender;

        emit CountryBuy(msg.sender, id);
    }
}
