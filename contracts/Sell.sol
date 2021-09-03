// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./CollectibleUtils.sol";

/**
* @title Base function of sell ERC721
* @author Youness Chetoui
*/
contract Sell is CollectibleUtils {
    struct PoliticOnSale {
        uint256 tokenId;
        uint256 price;
        address payable owner;
        bool created;
    }

    mapping(uint256 => PoliticOnSale) internal politicsOnSale;

    uint256[] public arrayPoliticiansOnSale;
    uint256 internal feeSale = 5;

    event CreateSale(uint256 id, address owner);
    event BuyOnSale(uint256 id, address buyer);

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

        _updatePoliticianOnSale(_tokenId, true);

        emit BuyOnSale(_tokenId, msg.sender);
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
        _updatePoliticianOnSale(_tokenId, true);

        emit BuyOnSale(_tokenId, msg.sender);
    }

    /**
    * @notice Cancel the sell of politician
    * @param _tokenId of politician for sale
    */
    function cancelSell(uint256 _tokenId) public payable {
        require(msg.sender == politicsOnSale[_tokenId].owner, "Not your politician");
        uint256 feeCost = ((politicsOnSale[_tokenId].price * 10**18) / 1000) * feeSale /100;
        require(msg.value == feeCost, "Incorrect amount");

        ownerAddress.transfer(feeCost);
        // transfer collectible from contract to buyer
        this.safeTransferFrom(contractAddress, msg.sender, _tokenId);

        // Delete onSale
        _updatePoliticianOnSale(_tokenId, true);
    }

    /**
    * @notice Update on sale politician
    * @param _tokenId of politician, _delete is delete or add on sale
    */
    function _updatePoliticianOnSale(uint256 _tokenId, bool _delete) internal {
        if (_delete) {
            delete politicsOnSale[_tokenId];

            for (uint i = 0; i < arrayPoliticiansOnSale.length; i++) {
                if (arrayPoliticiansOnSale[i] == _tokenId) {
                    delete arrayPoliticiansOnSale[i];
                }
            }
        } else {
            arrayPoliticiansOnSale.push(_tokenId);
        }
    }
}
