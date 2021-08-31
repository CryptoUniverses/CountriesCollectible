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
    * @notice Up for sale of owned politician
    * @param _tokenId of politician owned and _price wished
    */
    function forSale(uint256 _tokenId, uint256 _price) public {
        require(politicToUser[_tokenId] == msg.sender, "You are not the owner of the token");

        ERC721.safeTransferFrom(msg.sender, contractAddress, _tokenId);

        PoliticOnSale memory politicOnSale =
            PoliticOnSale({tokenId: _tokenId, price: _price, owner: payable(msg.sender), created: true});

        politicsOnSale[_tokenId] = politicOnSale;

        // Update politicsOwned and transfer politician for sale to contract
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
    * @notice Buy politician
    * @param _tokenId of politician for sale
    */
    function buyPoliticsForSale(uint256 _tokenId) public payable {
        require(politicsOnSale[_tokenId].created, "Politician not for sale");
        require(msg.sender != politicsOnSale[_tokenId].owner, "Your politician");
        require(msg.value == (politicsOnSale[_tokenId].price * 10**18) / 1000, "Incorrect amount");

        // get 5% of fee
        uint256 feeCost = msg.value * feeSale / 100;
        uint256 amountOwner = msg.value - feeCost;
        ownerAddress.transfer(feeCost);
        politicsOnSale[_tokenId].owner.transfer(amountOwner);

        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        delete politicsOnSale[_tokenId];

        // Update politician Owned
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

    /**
    * @notice Cancel the sell of politician
    * @param _tokenId of politician for sale
    */
    function cancelSell(uint256 _tokenId) public {
        require(msg.sender == politicsOnSale[_tokenId].owner, "Not your politician");

        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        delete politicsOnSale[_tokenId];

        // Update politician Owned
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
