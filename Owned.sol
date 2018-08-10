pragma solidity ^0.4.18;

contract owned {
    address public owner;
    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != 0x0);
        owner = newOwner;
    }
}
