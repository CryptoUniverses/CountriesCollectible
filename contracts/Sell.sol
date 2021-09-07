// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./CollectibleUtils.sol";

/**
* @title Base function of sell ERC721
* @author Youness Chetoui
*/
contract Sell is CollectibleUtils {
    struct CountryOnSale {
        uint256 tokenId;
        uint256 price;
        address payable owner;
        bool created;
    }

    mapping(uint256 => CountryOnSale) internal countriesOnSale;

    uint256[] public arrayCountriesOnSale;
    uint256 internal feeSale = 5;

    event CreateSale(uint256 id, address owner);
    event BuyOnSale(uint256 id, address buyer);

    /**
    * @notice Up for sale of owned country
    * @param _tokenId of country owned and _price wished
    */
    function forSale(uint256 _tokenId, uint256 _price) public {
        require(countryToUser[_tokenId] == msg.sender, "You are not the owner of the token");

        ERC721.safeTransferFrom(msg.sender, contractAddress, _tokenId);

        CountryOnSale memory countryOnSale =
            CountryOnSale({tokenId: _tokenId, price: _price, owner: payable(msg.sender), created: true});

        countriesOnSale[_tokenId] = countryOnSale;

        arrayCountriesOnSale.push(_tokenId);

        emit CreateSale(_tokenId, msg.sender);
    }

    /**
    * @notice Buy country
    * @param _tokenId of country for sale
    */
    function buyCountryForSale(uint256 _tokenId) public payable {
        require(countriesOnSale[_tokenId].created, "Country not for sale");
        require(msg.sender != countriesOnSale[_tokenId].owner, "Your country");
        require(msg.value == (countriesOnSale[_tokenId].price * 10**18) / 1000, "Incorrect amount");

        // get 5% of fee
        uint256 feeCost = msg.value * feeSale / 100;
        uint256 amountOwner = msg.value - feeCost;
        ownerAddress.transfer(feeCost);
        countriesOnSale[_tokenId].owner.transfer(amountOwner);

        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        _updateCountryOnSale(_tokenId);

        emit BuyOnSale(_tokenId, msg.sender);
    }

    /**
    * @notice Cancel the sell of country
    * @param _tokenId of country for sale
    */
    function cancelSell(uint256 _tokenId) public payable {
        require(msg.sender == countriesOnSale[_tokenId].owner, "Not your country");
        uint256 feeCost = ((countriesOnSale[_tokenId].price * 10**18) / 1000) * feeSale /100;
        require(msg.value == feeCost, "Incorrect amount");

        ownerAddress.transfer(feeCost);
        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        _updateCountryOnSale(_tokenId);
    }

    /**
    * @notice Update on sale country
    * @param _tokenId of country
    */
    function _updateCountryOnSale(uint256 _tokenId) internal {
        delete countriesOnSale[_tokenId];

        for (uint i = 0; i < arrayCountriesOnSale.length; i++) {
            if (arrayCountriesOnSale[i] == _tokenId) {
                delete arrayCountriesOnSale[i];
            }
        }
    }
}
