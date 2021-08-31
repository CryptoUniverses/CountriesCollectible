// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./LotteryFactory.sol";

/**
* @title Base function of sell ERC721
* @author Youness Chetoui
*/
contract Sell is LotteryFactory {
    struct PoliticOnSale {
        uint256 tokenId;
        uint256 price;
        address payable owner;
        bool created;
    }

    mapping(uint256 => PoliticOnSale) internal politicsOnSale;

    uint256 internal feeSale = 5;

    /**
    * @notice Up for sale of owned politic
    * @param tokenId of politic owned and price wished
    */
    function forSale(uint256 _tokenId, uint256 _price) public {
        require(politicToUser[_tokenId] == msg.sender, "You are not the owner of the token");

        safeTransferFrom(msg.sender, contractAddress, _tokenId);

        PoliticOnSale memory politicOnSale =
            PoliticOnSale({tokenId: _tokenId, price: _price, owner: payable(msg.sender), created: true});

        politicsOnSale[_tokenId] = politicOnSale;

        // Update politicsOwned and transfer politic for sale to contract
        PoliticsOwned[] memory politicsFrom = userOwnedPolitics[msg.sender];
        delete userOwnedPolitics[msg.sender];
        for (uint i = 0; i < politicsFrom.length; i++) {
            if (politicsFrom[i].id != _tokenId) {
                userOwnedPolitics[msg.sender].push(politicsFrom[i]);

            } else {
                politicsFrom[i].owner = contractAddress;
                userOwnedPolitics[contractAddress].push(politicsFrom[i]);
            }
        }

        delete userOwnedPolitics[politicToUser[_tokenId]];
        delete politicToUser[_tokenId];
    }

    /**
    * @notice Buy politics
    * @param tokenId of politic for sale
    */
    function buyPoliticsForSale(uint256 _tokenId) public payable {
        require(politicsOnSale[_tokenId].created, "Politic not for sale");
        require(msg.value == (politicsOnSale[_tokenId].price * 10e18) / 10000, "Incorrect amount");

        // get 5% of fee
        uint256 feeCost = msg.value * feeSale / 100;
        uint256 amountOwner = msg.value - feeCost;
        ownerAddress.transfer(feeCost);
        politicsOnSale[_tokenId].owner.transfer(amountOwner);

        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Update politic owned
        delete politicsOnSale[_tokenId];

        PoliticsOwned[] memory politicsFrom = userOwnedPolitics[contractAddress];
        delete userOwnedPolitics[contractAddress];
        for (uint i = 0; i < politicsFrom.length; i++) {
            if (politicsFrom[i].id != _tokenId) {
                userOwnedPolitics[msg.sender].push(politicsFrom[i]);

            } else {
                politicsFrom[i].owner = msg.sender;
                userOwnedPolitics[msg.sender].push(politicsFrom[i]);
            }
        }

        politicToUser[_tokenId] = msg.sender;
    }
}
