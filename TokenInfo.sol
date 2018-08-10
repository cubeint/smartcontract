pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Owned.sol";

contract TokenInfo is owned {
    using SafeMath for uint256;

    address public token_wallet_address;

    string public name = "CUBE";
    string public symbol = "AUTO";
    uint256 public decimals = 18;
    uint256 public total_supply = 7200000000 * (10 ** uint256(decimals));

    // 1 ether : 100,000 token
    uint256 public conversion_rate = 100000;

    event ChangeTokenName(address indexed who);
    event ChangeTokenSymbol(address indexed who);
    event ChangeTokenWalletAddress(address indexed from, address indexed to);
    event ChangeTotalSupply(uint256 indexed from, uint256 indexed to);
    event ChangeConversionRate(uint256 indexed from, uint256 indexed to);
    event ChangeFreezeTime(uint256 indexed from, uint256 indexed to);

    function totalSupply() public constant returns (uint) {
        return total_supply;
    }

    function changeTokenName(string newName) onlyOwner public {
        name = newName;
        ChangeTokenName(msg.sender);
    }

    function changeTokenSymbol(string newSymbol) onlyOwner public {
        symbol = newSymbol;
        ChangeTokenSymbol(msg.sender);
    }

    function changeTokenWallet(address newTokenWallet) onlyOwner internal {
        require(newTokenWallet != address(0));
        address pre_address = token_wallet_address;
        token_wallet_address = newTokenWallet;
        ChangeTokenWalletAddress(pre_address, token_wallet_address);
    }

    function changeTotalSupply(uint256 _total_supply) onlyOwner internal {
        require(_total_supply > 0);
        uint256 pre_total_supply = total_supply;
        total_supply = _total_supply;
        ChangeTotalSupply(pre_total_supply, total_supply);
    }

    function changeConversionRate(uint256 _conversion_rate) onlyOwner public {
        require(_conversion_rate > 0);
        uint256 pre_conversion_rate = conversion_rate;
        conversion_rate = _conversion_rate;
        ChangeConversionRate(pre_conversion_rate, conversion_rate);
    }
}
