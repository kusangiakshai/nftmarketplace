//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    unit256 listingPrice=0.001 ether;

    constructor(){
        owner = payable(msg.sender);

    }
    struct Msrketitem{
        unit itemId;
        address nftContract;
        unit256 tokenId;
        address payable seller;
        address payable owner;
        unit256 price;
        bool sold;
    }

    mapping(unit256 => Marketitem) private idToMarketItem;

    event MarketItemCreated(
        unit indexed itemId,
        address indexed nftContract,
        unit256 indexed tokenId,
         address seller,
        address owner,
        unit256 price,
        bool sold

    );

    function getlistingPrice() public view returns(unit256){
        return listingPrice;
    }

    function createMarketItem(
        address nftContract,
        unit tokenId,
        unit256 price
    ) public payable nonReentrant{
        require(price>0,"Price should be greater than 1 wei");
        require(msg.value==listingPrice,"service charge should be equal to the listingPrice");

        _itemIds.increment();
        uint256 itemId=_itemIds.current();

        idToMarketItem[itemId]=Marketitem(
            _itemsId,
            nftContract,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);

    }

    function createMarketSale(
        address nftContract,
        unit256 itemId
    )public payable nonReentrant{
        unit price= idToMarketItem[itemId].price;
        unit tokenId= idToMarketItem[itemId].tokenId;

        require(msg.value==price,"please submit the asking price to purchase");
        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        idToMarketItem[itemId].owner=payable(msg.sender);
        idToMarketItem[itemId].sold=true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice)


    }
        
    

}