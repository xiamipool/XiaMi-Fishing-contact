pragma solidity ^0.5.0;
import "../library/NFTOwnership.sol";


contract NFTGame is NFTOwnership {

    uint8 num = 5;
    uint8 public count = 0;
    uint16 public maxLevel = 31;
    uint256 public winnerXMPTRewards = 2 * 1e18;
    //uint256 public burnNFTRewards = 2 * 1e18;
    uint256 public levelUpFee = 1 * 1e18;
    uint256 public buyNFTFee = 0.02 ether;
    uint256 public levelUpPower = 500;

    address[5] plays;
    mapping(uint => address) public nonceToWinner;
    mapping(address => uint) public winnerToCounter;
    mapping(address => uint) public HTRewards;
    mapping(address => uint) public XMPTRewards;



    using SafeMath for uint;

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

    function topLevelUp (uint _nftId,uint _amount) external onlyOwnerOf(_nftId) returns (uint){
        require(NFTs[_nftId].level <= maxLevel,'Upgraded to the highest level');
        uint upLevel = maxLevel - NFTs[_nftId].level;
        require(_amount >= levelUpFee*upLevel,'No enough money');
        //XMPT.transferFrom(msg.sender,address(this),_amount*9/10);
        //XMPT.transferFrom(msg.sender,address(uint160(teamWallet)),_amount/10);
        NFTs[_nftId].level = uint32(NFTs[_nftId].level.add(upLevel));
        NFTs[_nftId].medal = uint32(NFTs[_nftId].level.div(5));
        uint addPower = _randomByModulus(levelUpPower).add(NFTs[_nftId].quality.mul(levelUpPower));
        NFTs[_nftId].power = uint32(NFTs[_nftId].power.add(addPower.mul(upLevel)));
        return 1;
    }
}