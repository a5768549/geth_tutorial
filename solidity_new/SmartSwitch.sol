// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
/*
    預想IOT設備
    使用者付款給合約後，可以使用該IOT設備300秒
    IOT設備可以確認時間是否到達
    合約方可以收款
*/

contract SmartSwitch{
    //用於紀錄開關訊息的結構(struct)
    struct Switch{
        address addr; //使用者的位址
        uint endTime; //使用結束時間(UnixTime)
        bool status;  //當值為true時，可以使用服務
    }

    address public owner; //服務擁有者(owner)的位址
    address public iot; //IoT的位址

    mapping(uint => Switch) public switches; //儲存Switch的map(對應表)

    uint public numPaid; //付款次數

    ///服務擁有者的權限檢查
    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can call this function");
        _;
    }

    //IoT的權限檢查
    modifier onlyIoT(){
        require(msg.sender == iot,"Only iot can call this function");
        _;
    }

    ///建構子
    ///將IoT的位址設為引數
    constructor(address _iot){
        owner = msg.sender;
        iot = _iot;
        numPaid = 0;
    }

    ///付費時會被呼叫的函數
    function payToSwitch() public payable{
        //連1ether都沒有的話，就會停止處理
        require(msg.value == 1000000000000000000,"Please pay 1 ether");
        //設定Switch
        Switch storage s = switches[numPaid++];
        s.addr = msg.sender;
        s.endTime = block.timestamp + 300;
        s.status = true;
    }

    ///變更status的函數
    ///到達使用結束時間就會被呼叫出來
    ///引數是switches的key值
    function updateStatus(uint _index) public onlyIoT{
        //如果對應於目標index的Switch尚未設定的話，就停止處理
        require(switches[_index].addr != 0x0000000000000000000000000000000000000000,"This address has not been set");
        //若尚未到達使用結束時間的話，就停止處理
        require(block.timestamp > switches[_index].endTime,"time is not up yet");

        //更新status
        switches[_index].status = false;
    }

    ///用於提取使用者所支付之以太幣(ether)的函數
    function withdrawFunds() public onlyOwner{
        payable(owner).transfer(address(this).balance);

        if (address(this).balance != 0) {
            revert();
        }
    }

    ///用於銷毀合約的函數
    function kill() public onlyOwner{
        selfdestruct(payable(owner));
    }

}