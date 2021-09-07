// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Collectible.sol";

/**
* @title ERC721 collectible utils methods
* @author Youness Chetoui
*/
contract CollectibleUtils is Collectible {

    /**
    * @notice get qty of country available
    * @param _id CountriesAvailable
    * @return uint256
    */
    function getCountryQty(uint256 _id) public view onlyOwner returns (uint256) {
        require(countriesAvailable[_id].created, "Country not found");
        return countriesAvailableQty[_id];
    }

    /**
    * @notice Get countries by user
    * @return array of struct CountriesOwned
    */
    function getMyCountries() public view returns (CountriesOwned[] memory) {
        return userOwnedCountries[msg.sender];
    }

    /**
    * @notice Add quantity for a CountriesAvailable
    * @param _id of CountriesAvailable and _qty wished
    */
    function addQty(uint256 _id, uint256 _qty) public onlyOwner {
        require(countriesAvailable[_id].created, "Country not found");
        countriesAvailable[_id] = _qty;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        CountriesOwned[] memory countriesFrom = userOwnedCountries[from];
        delete userOwnedCountries[from];
        for (uint i = 0; i < countriesFrom.length; i++) {
            if (countriesFrom[i].id != tokenId) {
                userOwnedCountries[from].push(countriesFrom[i]);

            } else {
                countriesFrom[i].owner = to;
                userOwnedCountries[to].push(countriesFrom[i]);
            }
        }

        countryToUser[tokenId] = to;
    }
}
