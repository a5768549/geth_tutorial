// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.4.11;

contract CrowdFunding{
    //投資者
    struct Investor{
        address addr; //投資者的位址
        uint amount;  //投資額
    }

    address public owner; //合約擁有者
    uint public numInvestors; //投資者數目
    uint public deadline; //截止時間(UnixTime)
    string public status; //募資活動的狀態
    bool public ended; //募資活動是否已經結束
    uint public goalAmount; //目標額
    uint public totalAmount; //投資總額
    mapping(uint => Investor) public investors; //管理投資者的對應表(map)

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    ///建構子
    function CrowdFunding(uint _duration, uint _goalAmount){
        owner = msg.sender;

        //用Unixtime設定截止時間
        deadline = now + _duration;

        goalAmount = _goalAmount;
        status = "Funding";
        ended = false;
        numInvestors = 0;
        totalAmount = 0;
    }

    ///投資時會被呼叫的函數
    function fund() payable{
        //若是活動已結束的話就中斷處理
        require(!ended);

        Investor inv = investors[numInvestors++];
        inv.addr = msg.sender;
        inv.amount = msg.value;
        totalAmount += inv.amount;
    }

    ///確認是否已達成目標金額
    ///此外，根據活動的成功於否進行ether的匯款
    function checkGoalReached() public onlyOwner{
        //若是活動已結束的話就中斷處理
        require(!ended);
        //截止時間還沒到就中斷處理
        require(now >= deadline);

        if(totalAmount >= goalAmount){ //活動成功的時候
            status = "Campaign Succeeded";
            ended = true;
            //將合約內所有以太幣(ether)傳送給擁有者
            if(!owner.send(this.balance)){
                throw;
            }
        }else{ //活動失敗的時候
            uint i = 0;
            status = "Campaiga Failed";
            ended = true;

            //將ether退款給每位投資者
            while(i <= numInvestors){
                if(!investors[i].addr.send(investors[i].amount)){
                    throw;
                }
                i++;
            }
        }
    }

    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}