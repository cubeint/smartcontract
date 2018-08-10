pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Owned.sol";
import "./PreSale.sol";
import "./FreezeToken.sol";
import "./TokenInfo.sol";
import "./Vote.sol";
import "./BasicToken.sol";

contract Token is owned, PreSale, FreezeToken, TokenInfo, Vote, BasicToken {
    using SafeMath for uint256;

    bool public open_free = false;

    event Payable(address indexed who, uint256 eth_amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);

    function Token (address _owner_address, address _token_wallet_address) public {
        require(_token_wallet_address != address(0));

        if (_owner_address != address(0)) {
            owner = _owner_address;
            balance_of[owner] = 0;
        } else {
            owner = msg.sender;
            balance_of[owner] = 0;
        }

        token_wallet_address = _token_wallet_address;
        balance_of[token_wallet_address] = total_supply;
    }

    function mintToken(
        address to,
        uint256 token_amount,
        uint256 freeze_timestamp
    ) onlyOwner public returns (bool) {
        require(token_amount > 0);
        require(balance_of[token_wallet_address] >= token_amount);
        require(balance_of[to] + token_amount > balance_of[to]);
        uint256 token_plus_bonus = 0;
        uint sale_number = 0;

        var(sale_info, isSale) = nowSaleInfo();
        if (isSale) {
            sale_number = sale_info.sale_number;
            uint8 bonus_rate = sale_info.bonus_rate;
            token_plus_bonus = addBonus(token_amount, bonus_rate);
            require(checkSaleCanSell(sale_number, token_plus_bonus) == true);
            addSaleSold(sale_number, token_plus_bonus);
        } else if (open_free) {
            token_plus_bonus = token_amount;
        } else {
            require(open_free == true);
        }

        balance_of[token_wallet_address] -= token_plus_bonus;
        balance_of[to] += token_plus_bonus;

        uint256 _freeze = 0;
        if (freeze_timestamp >= 0) {
            _freeze = freeze_timestamp;
        }

        freezeTo(to, now + _freeze); // FreezeToken.sol
        Transfer(0x0, to, token_plus_bonus);
        addAddress(to);
        return true;
    }

    function mintTokenBulk(address[] _tos, uint256[] _amounts) onlyOwner public {
        require(_tos.length == _amounts.length);
        for (uint i=0; i < _tos.length; i++) {
            mintToken(_tos[i], _amounts[i], 0);
        }
    }

    function superMint(
        address to,
        uint256 token_amount,
        uint256 freeze_timestamp
    ) onlyOwner public returns(bool) {
        require(token_amount > 0);
        require(balance_of[token_wallet_address] >= token_amount);
        require(balance_of[to] + token_amount > balance_of[to]);

        balance_of[token_wallet_address] -= token_amount;
        balance_of[to] += token_amount;

        uint256 _freeze = 0;
        if (freeze_timestamp >= 0) {
            _freeze = freeze_timestamp;
        }

        freezeTo(to, now + _freeze);
        Transfer(0x0, to, token_amount);
        Mint(to, token_amount);
        addAddress(to);
        return true;
    }

    function superMintBulk(address[] _tos, uint256[] _amounts) onlyOwner public {
        require(_tos.length == _amounts.length);
        for (uint i=0; i < _tos.length; i++) {
            superMint(_tos[i], _amounts[i], 0);
        }
    }

    function transfer(address to, uint256 value) public {
        _transfer(msg.sender, to, value);
    }

    function transferBulk(address[] tos, uint256[] values) public {
        require(tos.length == values.length);
        for (uint i=0; i < tos.length; i++) {
            transfer(tos[i], values[i]);
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public {
        require(msg.sender != address(0));
        require(_from != address(0));
        require(_amount <= allowances[_from][msg.sender]);
        _transfer(_from, _to, _amount);
        allowances[_from][msg.sender] -= _amount;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) private {
        require(_from != address(0));
        require(_to != address(0));
        require(balance_of[_from] >= _amount);
        require(balance_of[_to].add(_amount) >= balance_of[_to]);
        require(transfer_close == false);
        require(checkFreeze(_from) == false);

        uint256 prevBalance = balance_of[_from] + balance_of[_to];
        balance_of[_from] -= _amount;
        balance_of[_to] += _amount;
        assert(balance_of[_from] + balance_of[_to] == prevBalance);
        addAddress(_to);
        Transfer(_from, _to, _amount);
    }

    function burn(address _who, uint256 _amount) onlyOwner public returns(bool) {
        require(_amount > 0);
        require(balanceOf(_who) >= _amount);
        balance_of[_who] -= _amount;
        total_supply -= _amount;
        Burn(_who, _amount);
        return true;
    }

    function additionalTotalSupply(uint256 _addition) onlyOwner public returns(bool) {
        require(_addition > 0);
        uint256 change_total_supply = total_supply.add(_addition);
        balance_of[token_wallet_address] += _addition;
        changeTotalSupply(change_total_supply);
    }

    function tokenWalletChange(address newTokenWallet) onlyOwner public returns(bool) {
        require(newTokenWallet != address(0));
        uint256 token_wallet_amount = balance_of[token_wallet_address];
        balance_of[newTokenWallet] = token_wallet_amount;
        balance_of[token_wallet_address] = 0;
        changeTokenWallet(newTokenWallet);
    }

    function () payable public {
        uint256 eth_amount = msg.value;
        msg.sender.transfer(eth_amount);
        Payable(msg.sender, eth_amount);
    }

    function tokenOpen() onlyOwner public {
        open_free = true;
    }

    function tokenClose() onlyOwner public {
        open_free = false;
    }

    function freezeAddress(
        address _who,
        uint256 _addTimestamp
    ) onlyOwner public returns(bool) {
        freezeTo(_who, _addTimestamp);
        return true;
    }

    function meltAddress(
        address _who
    ) onlyOwner public returns(bool) {
        meltNow(_who);
        return true;
    }

    // call a voting in Vote.sol
    function voteAgree() public returns (bool) {
        address _voter = msg.sender;
        uint256 _balance = balanceOf(_voter);
        require(_balance > 0);
        return voting(_voter, _balance);
    }

    function voteAgree(address who) onlyOwner public returns(bool) {
        require(who != address(0));
        uint256 _balance = balanceOf(who);
        require(_balance > 0);
        return voting(who, _balance);
    }
}
