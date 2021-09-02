// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Collectible.sol";

/**
* @title ERC721 collectible utils methods
* @author Youness Chetoui
*/
contract CollectibleUtils is Collectible {

    /**
    * @notice get list of all politician available
    * @return Array of struct PoliticsAvailable
    */
    function getPolitics() public view onlyOwner returns (PoliticsAvailable[] memory) {
        return politics;
    }

    /**
    * @notice Get politician by user
    * @return array of struct PoliticsOwned
    */
    function getMyPolitics() public view returns (PoliticsOwned[] memory) {
        return userOwnedPolitics[msg.sender];
    }

    /**
    * @notice Add quantity for a PoliticsAvailable
    * @param _id of PoliticsAvailable and _qty wished
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

        politicToUser[tokenId] = to;
    }
}
