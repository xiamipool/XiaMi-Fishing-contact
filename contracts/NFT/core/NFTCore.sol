pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "../library/NFTOwnership.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC721/ERC721Metadata.sol";

contract NFTCore is NFTOwnership{

    uint16 public maxLevel = 31;
    uint256 public levelUpFee = 1 * 1e18;
    uint256 public buyNFTFee = 0.02 ether;
    uint256 public levelUpPower = 500;

    string public constant name = "XiaMiPool NFT";
    string public constant symbol = "XNFT";
    string public baseUri = "";



    function() external payable {
    }



    function checkBalance() external view onlyGovernance returns(uint) {
        return address(this).balance;
    }

    function setBuyNFTFee(uint _fee) external onlyGovernance{
        buyNFTFee = _fee;
    }

    function setUpLevelFee(uint _fee) external onlyGovernance{
        levelUpFee = _fee;
    }

    function setBaseURI(string memory _baseUri) public onlyGovernance{
        baseUri = _baseUri;
    }

    function withdraw() external onlyGovernance {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawXMPT() external onlyGovernance {
        XMPT.transfer(msg.sender,XMPT.balanceOf(address(this)));
    }

    function withdrawXMPT(uint _amount) external onlyGovernance {
        XMPT.transfer(msg.sender,_amount);
    }

    function ethJackpot() public view returns(uint256){
        return address(this).balance;
    }

    function xmptJackpot() public view  returns (uint256){
        return XMPT.balanceOf(address(this));
    }

    function burnNFT(uint _nftId) external {
        _burn(msg.sender,_nftId);
        uint256 burnNFTRewards = NFTs[_nftId].level*levelUpFee.mul(6).div(10);
        XMPT.transfer(msg.sender,burnNFTRewards);
    }

    function getBurnNFTRewards(uint _nftId) public view returns(uint256){
        return  NFTs[_nftId].level*levelUpFee.mul(6).div(10);
    }

    function buyNFT() external payable returns(uint){
        require(msg.value >= buyNFTFee,'No enough money');
        address(uint160(teamWallet)).transfer(buyNFTFee.div(10));
        return _createNFT(msg.sender);
    }

    function getNFTById(uint _nftId) public view returns(uint32,uint32,uint32,uint,uint){
        NFT memory n =  NFTs[_nftId];
        return(n.quality,n.level,n.medal,n.dna,n.power);
    }

    function levelUp (uint _nftId,uint _amount) external onlyOwnerOf(_nftId) returns (uint){
        require(_amount >= levelUpFee,'No enough money');
        require(NFTs[_nftId].level <= maxLevel,'Upgraded to the highest level');
        XMPT.transferFrom(msg.sender,address(this),_amount.mul(9).div(10));
        XMPT.transferFrom(msg.sender,address(uint160(teamWallet)),_amount.div(10));
        NFTs[_nftId].level = uint32(NFTs[_nftId].level.add(1));
        if(NFTs[_nftId].level % 5 == 0){
            NFTs[_nftId].medal = uint32(NFTs[_nftId].medal.add(1));
        }
        uint addPower = _randomByModulus(levelUpPower).add(NFTs[_nftId].quality.mul(levelUpPower));
        NFTs[_nftId].power = uint32(NFTs[_nftId].power.add(addPower));
        return 1;
    }

    function topLevelUpFee(uint _nftId) public view returns(uint) {
        uint upLevel = maxLevel - NFTs[_nftId].level;
        return levelUpFee.mul(upLevel);
    }

    function topLevelUp (uint _nftId,uint _amount) external onlyOwnerOf(_nftId) returns (uint){
        require(NFTs[_nftId].level <= maxLevel,'Upgraded to the highest level');
        uint upLevel = maxLevel - NFTs[_nftId].level;
        require(_amount >= levelUpFee.mul(upLevel),'No enough money');
        XMPT.transferFrom(msg.sender,address(this),_amount.mul(9).div(10));
        XMPT.transferFrom(msg.sender,address(uint160(teamWallet)),_amount.div(10));
        NFTs[_nftId].level = uint32(NFTs[_nftId].level.add(upLevel));
        NFTs[_nftId].medal = uint32(NFTs[_nftId].level.div(5));
        uint addPower = _randomByModulus(levelUpPower).add(NFTs[_nftId].quality.mul(levelUpPower));
        NFTs[_nftId].power = uint32(NFTs[_nftId].power.add(addPower.mul(upLevel)));
        return 1;
    }
}