/*
說明1：引入SPDX License Identifier
由於開源程式碼常常會面臨到法律的問題，因此自Solidity ^0.6.8 版本需使用註解的方式進行License的宣告。
*/
// SPDX-License-Identifier: MIT 

/*
說明2：Pragmas
宣告前置檢查作業，如：版本限制。
*/
pragma solidity ^0.8.18; //宣告solidity的版本不能低於0.8.18

/*
說明3：合約內容
合約名稱：TreasureHunt
合約功能：
1.treasureHunt()：owner(關主)建立stage(遊戲關卡)
2.play()：player(玩家)發送交易(賭注)給stage(遊戲關卡)
3.getlevel()：目前關卡的累計金額
3.fund()：交易成功：owner(關主)向player(玩家)發送獎金(賭注*1.5)
*/

contract TreasureHunt {
    address public owner; //關主
    address public stage; //關卡
    bool public rewarded; //通關狀態(是/否)
    bool public complete; //遊戲狀態(已結束/進行中)
    uint public numPlay; //合約成功執行次數

    //關卡結構
    struct Stage {
        uint amount; //整數
        address play_address; //玩家的錢包地址
        address playstage; //關卡的錢包地址
        bytes32 message; //byte32
    }
    mapping(uint => Stage) public playtime; 
    
    //功能：建立關卡
    function treasureHunt(address _stage) public {
        owner = msg.sender; //關主(即建立關卡者)
        numPlay = 0; //闖關次數
        rewarded = false; //通關狀態：否
        complete = false; //遊戲狀態：進行中
        stage = _stage; //關卡
    }

    //功能：接收以太幣
    function play(address playstage, bytes32 ans) public payable {
        if (msg.value == 0 || complete || rewarded) revert(); //不符合條件而終止執行，消耗所有 gas
        playtime[numPlay] = Stage(msg.value, msg.sender,playstage, ans); 
        numPlay+=1;
    }

    //功能：查看合約上所有關卡之總額
    function getlevel() public view returns (uint) {
        return address(this).balance;
    }

    //功能：發送以太幣
    function fund(uint winner) public payable{
        address payable eth_address; //重新定義一個新的地址，因為僅payable型態可以發送ETH
        if (msg.sender != owner || complete || rewarded) revert(); //不符合條件而終止執行，消耗所有 gas
        eth_address=payable(playtime[winner].play_address); //將地址轉成payable(可發送地址)
        eth_address.transfer(playtime[winner].amount*150/100); //solidity不支援小數點，所以要先*150再/100
        rewarded = true; //通關狀態：是
        complete = true; //遊戲狀態：已結束
    }
}