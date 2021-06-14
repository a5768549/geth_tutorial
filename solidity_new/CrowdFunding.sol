// SPDX-License-Identifier: MIT
/*
    本程式碼將教材中的合約全面升級至0.8.5版，且修復相關BUG
    利用ether募集資金
    投資者可以針對合約進行投資
    開始設定的時間到達後，若達成目標則把錢轉給owner，若沒達成則退回錢
*/
pragma solidity 0.8.5;

contract CrowdFunding {
    //投資者
    struct Investor {
        address addr; //投資者的位址
        uint256 amount; //投資額
    }

    address public owner; //合約擁有者
    uint256 public numInvestors; //投資者數目
    uint256 public deadline; //截止時間(UnixTime)
    string public status; //募資活動的狀態
    bool public ended; //募資活動是否已經結束
    uint256 public goalAmount; //目標額
    uint256 public totalAmount; //投資總額
    mapping(uint256 => Investor) private investors; //管理投資者的對應表(map)

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    ///建構子
    constructor(uint256 _duration, uint256 _goalAmount) {
        owner = msg.sender;

        //用Unixtime設定截止時間
        deadline = block.timestamp + _duration;

        goalAmount = _goalAmount;
        status = "Funding";
        ended = false;
        numInvestors = 0;
        totalAmount = 0;
    }

    ///投資時會被呼叫的函數
    function fund() public payable {
        //若是活動已結束的話就中斷處理
        require(!ended);

        Investor storage inv = investors[numInvestors++];

        inv.addr = msg.sender;
        inv.amount = msg.value;
        totalAmount += msg.value;
    }

    ///確認是否已達成目標金額
    ///此外，根據活動的成功於否進行ether的匯款
    function checkGoalReached() public payable onlyOwner {
        //若是活動已結束的話就中斷處理
        require(!ended, "The Fund is ended");
        //截止時間還沒到就中斷處理
        require(block.timestamp >= deadline, "Time is not end");

        if (totalAmount >= goalAmount) {
            //活動成功的時候
            status = "Campaign Succeeded";
            ended = true;
            //將合約內所有以太幣(ether)傳送給擁有者
            payable(owner).transfer(address(this).balance);

            if (address(this).balance != 0) {
                revert();
            }
        } else {
            //活動失敗的時候
            uint256 i = 0;
            status = "Campaiga Failed";
            ended = true;

            //將ether退款給每位投資者
            while (i <= numInvestors) {
                uint256 before_amount = address(this).balance;
                payable(investors[i].addr).transfer(investors[i].amount);

                if (before_amount - investors[i].amount > address(this).balance) {
                    revert("Fail");
                }
                i++;
            }
        }
    }

    function kill() public onlyOwner {
        selfdestruct(payable(owner));
    }
}
