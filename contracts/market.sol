// SPDX-License-Identifier: MIT

pragma solidity >0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract marketPlace is ReentrancyGuard{

    struct listing{
        uint256 _price;
        address seller;
    }

    mapping(address=>mapping(uint256=>listing)) private listedMapp;//nftAddress--->tokenId=>struct
    mapping(address=>uint256) private profits;//seller-->amount earned by seliing

    event itemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemBought(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event itemCancelled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);

    modifier alreadyListed(address _nftAddress, uint256 _tokenId){
        listing memory check= listedMapp[_nftAddress][_tokenId];
        require(check._price==0, "NFT Already Listed");
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender){
        IERC721 id= IERC721(nftAddress);
        address owner= id.ownerOf(tokenId);
        require(owner==spender, "You are not the Owner of the NFT");
        _;
    }

    modifier isListed(address _nftAddress, uint256 _id){
        listing memory checks=listedMapp[_nftAddress][_id];
        require(checks._price>0,"Item not Listed");
        _;
    }

    function listNft(address nft, uint256 tokenId, uint256 price)public 
    alreadyListed(nft, tokenId)
    isOwner(nft, tokenId, msg.sender){
        require(price>0, "very Low value!!!");

        IERC721 nftApproved= IERC721(nft);

        require(nftApproved.getApproved(tokenId)==nft, "This token is not approved for Listing");

        listedMapp[nft][tokenId]=listing(price, msg.sender);

        emit itemListed(msg.sender, nft, tokenId, price);
    }

    function buyNft(address _nft, uint256 tokenId)public payable isListed(_nft, tokenId) nonReentrant{
        listing memory items=listedMapp[_nft][tokenId];

        require(items._price==msg.value, "Please pay the exact price");
        profits[items.seller]+=msg.value;
        delete(listedMapp[_nft][tokenId]);//deleting the struct for the current seller

       IERC721(_nft).safeTransferFrom(items.seller, msg.sender, tokenId);
       emit ItemBought(msg.sender, _nft, tokenId, items._price);
    }

    function cancelListing(address nftAddress, uint256 tokenId)external 
    isListed(nftAddress, tokenId)
    isOwner(nftAddress, tokenId, msg.sender){
        delete(listedMapp[nftAddress][tokenId]);
        emit itemCancelled(msg.sender, nftAddress, tokenId);
    }

    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice)external
    isListed(nftAddress, tokenId)
    isOwner(nftAddress, tokenId, msg.sender){
        listedMapp[nftAddress][tokenId]._price=newPrice;
        emit itemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    function withdraw()external nonReentrant{
        uint256 amount=profits[msg.sender];
        require(amount>0,"Not enough funds to withdraw");
        profits[msg.sender]=0;
        (bool success, )=payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed!");
    }

     function getListing(address nftAddress, uint256 tokenId)external view returns (listing memory){
        return listedMapp[nftAddress][tokenId];
    }

    function getAmount(address seller) external view returns (uint256) {
        return profits[seller];
    }
}