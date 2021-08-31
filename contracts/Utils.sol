// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Sell.sol";

/**
* @title Utils method
* @author Youness Chetoui
*/
contract Utils is Sell {
    /**
    * @notice update owner in mapping
    * @param _from, _to, _qty, _tokenId
    */
    function _updateOwner(address _from,address _to,uint256 _tokenId) internal {
        PoliticsOwned[] memory politicsFrom = userOwnedPolitics[_from];
        delete userOwnedPolitics[_from];
        for (uint i = 0; i < politicsFrom.length; i++) {
            if (politicsFrom[i].id != _tokenId) {
                userOwnedPolitics[_from].push(politicsFrom[i]);

            } else {
                politicsFrom[i].owner = _to;
                userOwnedPolitics[_to].push(politicsFrom[i]);
            }
        }

        politicToUser[_tokenId] = _to;
    }

    /**
    * @notice calculate cost
    * @param _price, _feeSale
    */
    function _calculateCost(uint256 _price, bool feeSale) internal returns (uint256, uint256) {
        uint256 feeCost = 0;

        if (feeSale) {
            // get 5% of fee
            uint256 feeCost = _price * 5 / 100;
            uint256 cost = _price - feeCost;
        } else {
            uint256 cost = (_price * 10**18) / 1000;
        }

        return (cost, feeCost);
    }
}
