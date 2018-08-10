pragma solidity ^0.4.18;

import "./Owned.sol";

contract FreezeToken is owned {
    mapping (address => uint256) public freezeDateOf;

    event Freeze(address indexed _who, uint256 _date);
    event Melt(address indexed _who);

    function checkFreeze(address _sender) public constant returns (bool) {
        if (now >= freezeDateOf[_sender]) {
            return false;
        } else {
            return true;
        }
    }

    function freezeTo(address _who, uint256 _date) internal {
        freezeDateOf[_who] = _date;
        Freeze(_who, _date);
    }

    function meltNow(address _who) internal onlyOwner {
        freezeDateOf[_who] = now;
        Melt(_who);
    }
}
