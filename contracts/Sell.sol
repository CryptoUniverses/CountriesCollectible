// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./LotteryFactory.sol";


contract Sell is LotteryFactory {
    struct PoliticOnSale {
        uint256 tokenId;
        uint256 price;
        address owner
        bool created;
    }

    mapping(uint256 => PoliticOnSale) internal politicsOnSale;

    uint256 internal fee = 5;

    function forSale(uint256 _tokenId, uint256 _price)
        public
    {
        require(politicToUser[_tokenId] == msg.sender, "You are not the owner of the token");

        safeTransferFrom(msg.sender, contractAddress, _tokenId);

        PoliticOnSale memory politicOnSale =
            PoliticOnSale({tokenId: _tokenId, price: _price, owner: msg.sender, created: true});

        politicsOnSale[_tokenId] = politicOnSale;

        PoliticsOwned[] memory politicsFrom = userOwnedPolitics[msg.sender];
        delete userOwnedPolitics[msg.sender];
        for (uint i = 0; i < politicsFrom.length; i++) {
            if (politicsFrom[i].id != _tokenId) {
                userOwnedPolitics[from].push(politicsFrom[i]);

            }
        }

        delete userOwnedPolitics[politicToUser[_tokenId]];
    }

    function buyPoliticsForSale(uint256 _tokenId)
        public
        payable
    {
        require(politicsOnSale[_tokenId].created, "Politic not for sale");
        require(msg.value == politicsOnSale[_tokenId].price / decimal * 10e18, "Incorrect amount");

        // get 5% of fee
        politicsOnSale[_tokenId].owner.transfer(msg.value);
        safeTransferFrom(contractAddress, msg.sender, _tokenId);

        delete politicsOnSale[_tokenId];
    }
}
