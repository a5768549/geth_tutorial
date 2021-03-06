// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.4.11;

contract HelloEthereum {
    //註解範例(範例1)
    string public msg1;

    string private msg2; //註解範例(範例2)

    /* 註解範例(範例3) */
    address public owner;
    uint8 public counter;

    /// Constructor(建構子)
    function HelloEthereum(string _msg1) {
        //將msg1設為_msg1
        msg1 = _msg1;

        //將owner設定成此合約(Contract)所產生的位址(address)
        owner = msg.sender;

        //作為起始值，將counter設為0
        counter = 0;
    }

    ///msg2的setter
    function setMsg2(string _msg2) public {
        //if句的範例
        if (owner != msg.sender) {
            throw;
        } else {
            msg2 = _msg2;
        }
    }

    ///msg2的getter
    function getMsg2() public constant returns (string) {
        return msg2;
    }

    function setCounter() public {
        //for 句的範例
        for (uint8 i = 0; i < 3; i++) {
            counter++;
        }
    }
}
