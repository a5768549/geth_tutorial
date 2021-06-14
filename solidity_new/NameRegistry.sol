// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

contract NameRegistry{

    //登錄合約用的結構(struct)
    struct Contract{
        address owner;
        address addr;
        string description;
    }

    //登錄完成的紀錄數
    uint public numContracts;

    //保存合約的map(對應表)
    mapping(string => Contract) public contracts;

    ///建構子
    constructor() {
        numContracts = 0;
    }

    ///登錄合約
    function register(string memory _name) public returns(bool){
        //名稱尚未被使用就可登錄
        if(contracts[_name].owner == 0x0000000000000000000000000000000000000000){
            Contract storage con = contracts[_name];
            con.owner = msg.sender;
            numContracts++;
            return true;
        }else{
            return false;
        }
    }

    ///刪除合約
    function unregister(string memory _name) public returns(bool){
        if(contracts[_name].owner == msg.sender){
            contracts[_name].owner = 0x0000000000000000000000000000000000000000;
            numContracts--;
            return true;
        }else{
            return false;
        }
    }

    ///變更合約(contract)的擁有者(owner)
    function changeOwner(string memory _name ,address _newOwner) public onlyOwner(_name){
        contracts[_name].owner = _newOwner;
    }

    ///取得合約的擁有者
    function getOwner(string memory _name) external view returns(address){
        return contracts[_name].owner;
    }

    ///設定合約的位址(address)
    function setAddr(string memory _name, address _addr) public onlyOwner(_name){
        contracts[_name].addr = _addr;
    }

    ///取得合約的位址
    function getAddr(string memory _name) external view returns(address){
        return contracts[_name].addr;
    }
    
    ///設定合約的說明
    function setDescription(string memory _name,string memory _description) public onlyOwner(_name){
        contracts[_name].description = _description;
    }

    ///取得合約的說明
    function getDescription(string memory _name) external view returns(string memory){
        return contracts[_name].description;
    }

    ///定義會在函數被呼叫之前進行處裡的modifier
    modifier onlyOwner(string memory _name){
        require(contracts[_name].owner == msg.sender);
        _;
    }
}