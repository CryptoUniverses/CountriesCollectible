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
        _updateOwner(msg.sender, contractAddress, _tokenId);

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

        (cost,feeCost) =_calculateCost(politicsOnSale[_tokenId].price, true)
        require(msg.value == feeCost + cost, "Incorrect amount");

        ownerAddress.transfer(feeCost);
        politicsOnSale[_tokenId].owner.transfer(cost);

        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        delete politicsOnSale[_tokenId];

        // Update politician Owned
        _updateOwner(contractAddress, msg.sender, _tokenId);
    }

    /**
    * @notice Cancel the sell of politician
    * @param _tokenId of politician for sale
    */
    function cancelSell(uint256 _tokenId) public {
        require(msg.sender == politicsOnSale[_tokenId].owner, "Not your politician");

        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Update politician Owned
        _updateOwner(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        delete politicsOnSale[_tokenId];
    }
}
