// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

contract Store {
    //顧客資料
    struct Customer {
        address addr; //顧客的位址
        uint256 value; //消費金額
        string description; //消費描述
    }

    address public owner;        //合約擁有者(店主)
    uint256 public numCustomers; //顧客數目
    uint256 public totalAmount;  //總營收
    mapping(uint256 => Customer) private customers; //管理顧客的對應表(map)

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    ///建構子
    constructor() {
        owner = msg.sender;
        
        numCustomers = 0;
        totalAmount = 0;
    }

    ///付款
    function pay(string memory _description) public payable{
        Customer storage inv = customers[numCustomers++];

        inv.addr = msg.sender;
        inv.value = msg.value;
        inv.description = _description;
        totalAmount += msg.value;
    }
    
    ///查看帳單
    function info(uint256 _index) public view returns(address _customer,uint256 _value,string memory _description){
        return(customers[_index].addr,customers[_index].value,customers[_index].description);
    }

    ///取錢
    function withdraw() public payable onlyOwner {
        payable(owner).transfer(address(this).balance);

        if (address(this).balance != 0) {
            revert();
        }
    }
    
    ///退款(需要付款時登記的索引值)
    function refund(uint256 _index) public payable onlyOwner {
        uint256 before_amount = address(this).balance;
        payable(customers[_index].addr).transfer(customers[_index].value);
        
        if (before_amount - customers[_index].value > address(this).balance) {
            revert("Fail");
        }
        
        Customer storage inv = customers[_index];

        inv.addr = 0x0000000000000000000000000000000000000000;
        inv.value = 0;
        inv.description = "";
    }

    function close() public onlyOwner {
        selfdestruct(payable(owner));
    }
}