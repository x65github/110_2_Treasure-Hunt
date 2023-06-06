/*
說明1：引入SPDX License Identifier
由於開源程式碼常常會面臨到法律的問題，因此自Solidity ^0.6.8 版本需使用註解的方式進行License的宣告。
*/
// SPDX-License-Identifier: MIT 

/*
說明2：Pragmas
宣告前置檢查作業，如：版本限制。
*/
pragma solidity ^0.8.0; //宣告solidity的版本不能低於0.8.0

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TreasureHuntNFT is ERC721Enumerable, Ownable {

    using Strings for uint256;

    bool public _isSaleActive = false; //NFT盲盒是否發行
    bool public _revealed = false; //NFT盲盒是否開箱

    // Constants
    uint256 public constant MAX_SUPPLY = 10; //NFT的鑄造數量上限
    uint256 public mintPrice = 0.01 ether; //鑄造NFT的基本價錢
    uint256 public maxBalance = 1; //使用者可持有的NFT數量
    uint256 public maxMint = 1; //使用者可同時鑄造的NFT數量

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory initBaseURI, string memory initNotRevealedUri)
        ERC721("TreasureHunt", "TH")
    {
        setBaseURI(initBaseURI);
        setNotRevealedURI(initNotRevealedUri);
    }

    //讓使用者搶NFT，使用early-return的流程進行
    function mintNicMeta(uint256 tokenQuantity) public payable {
        
        //NFT的鑄造數量已達上限
        require(
            totalSupply() + tokenQuantity <= MAX_SUPPLY,
            "Sale would exceed max supply"
        );
        
        //NFT的並未開始發行
        require(_isSaleActive, "Sale must be active to mint NicMetas");
        
        //每個帳戶僅可持有一個NFT
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        
        //金額不足以兌換獎勵
        require(
            tokenQuantity * mintPrice <= msg.value,
            "Not enough ether sent"
        );
        
        //一個帳戶一次僅可同時鑄造一個NFT
        require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");

        _mintNicMeta(tokenQuantity);
    }

    function _mintNicMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    //回傳基本URI
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //翻轉NFT盲盒的發行狀態
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    //翻轉NFT盲盒的開箱狀態
    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    //調整鑄造NFT的基本價錢
    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}
