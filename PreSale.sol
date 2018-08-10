pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Owned.sol";

contract PreSale is owned{
    using SafeMath for uint256;

    struct Sale {
        uint sale_number;
        uint256 start_timestamp;
        uint256 end_timestamp;
        uint8 bonus_rate;
        uint256 sell_limit;
    }

    Sale [] private sale_list;
    uint256 [] private sale_sold;

    function PreSale () public {

    }

    function getSaleLength() public constant returns(uint) {
        return sale_list.length;
    }

    function getSaleInfo(uint _index) public constant returns(
        uint sale_number,
        uint256 start_timestamp,
        uint256 end_timestamp,
        uint8 bonus_rate,
        uint256 sell_limit
    ) {
        sale_number = sale_list[_index].sale_number;
        start_timestamp = sale_list[_index].start_timestamp;
        end_timestamp = sale_list[_index].end_timestamp;
        bonus_rate = sale_list[_index].bonus_rate;
        sell_limit = sale_list[_index].sell_limit;
    }

    function getSaleSold(uint _index) public constant returns(uint256) {
        return sale_sold[_index];
    }


    function addBonus(
        uint256 _amount,
        uint8 _bonus
    ) internal pure returns(uint256) {
        return _amount.add((_amount.mul(_bonus)).div(100));
    }


    function newSale(
        uint256 start_timestamp,
        uint256 end_timestamp,
        uint8 bonus_rate,
        uint256 sell_token_limit
    ) onlyOwner public {
        require(start_timestamp > 0);
        require(end_timestamp > 0);
        require(sell_token_limit > 0);

        uint256 sale_number = sale_list.length;
        for (uint i=0; i < sale_list.length; i++) {
            require(sale_list[i].end_timestamp < start_timestamp);
        }

        sale_list[sale_list.length++] = Sale({
            sale_number: sale_number,
            start_timestamp: start_timestamp,
            end_timestamp: end_timestamp,
            bonus_rate: bonus_rate,
            sell_limit: sell_token_limit
        });
        sale_sold[sale_sold.length++] = 0;
    }

    function changeSaleInfo(
        uint256 _index,
        uint256 start_timestamp,
        uint256 end_timestamp,
        uint8 bonus_rate,
        uint256 sell_token_limit
    ) onlyOwner public returns(bool) {
        require(_index < sale_list.length);
        require(start_timestamp > 0);
        require(end_timestamp > 0);
        require(sell_token_limit > 0);

        sale_list[_index].start_timestamp = start_timestamp;
        sale_list[_index].end_timestamp = end_timestamp;
        sale_list[_index].bonus_rate = bonus_rate;
        sale_list[_index].sell_limit = sell_token_limit;
        return true;
    }

    function changeSaleStart(
        uint256 _index,
        uint256 start_timestamp
    ) onlyOwner public returns(bool) {
        require(_index < sale_list.length);
        require(start_timestamp > 0);
        sale_list[_index].start_timestamp = start_timestamp;
        return true;
    }

    function changeSaleEnd(
        uint256 _index,
        uint256 end_timestamp
    ) onlyOwner public returns(bool) {
        require(_index < sale_list.length);
        require(end_timestamp > 0);
        sale_list[_index].end_timestamp = end_timestamp;
        return true;
    }

    function changeSaleBonusRate(
        uint256 _index,
        uint8 bonus_rate
    ) onlyOwner public returns(bool) {
        require(_index < sale_list.length);
        sale_list[_index].bonus_rate = bonus_rate;
        return true;
    }

    function changeSaleTokenLimit(
        uint256 _index,
        uint256 sell_token_limit
    ) onlyOwner public returns(bool) {
        require(_index < sale_list.length);
        require(sell_token_limit > 0);
        sale_list[_index].sell_limit = sell_token_limit;
        return true;
    }


    function checkSaleCanSell(
        uint256 _index,
        uint256 _amount
    ) internal view returns(bool) {
        uint256 index_sold = sale_sold[_index];
        uint256 index_end_timestamp = sale_list[_index].end_timestamp;
        uint256 sell_limit = sale_list[_index].sell_limit;
        uint8 bonus_rate = sale_list[_index].bonus_rate;
        uint256 sell_limit_plus_bonus = addBonus(sell_limit, bonus_rate);

        if (now >= index_end_timestamp) {
            return false;
        } else if (index_sold.add(_amount) > sell_limit_plus_bonus) {
            return false;
        } else {
            return true;
        }
    }

    function addSaleSold(uint256 _index, uint256 amount) internal {
        require(amount > 0);
        require(_index < sale_sold.length);
        require(checkSaleCanSell(_index, amount) == true);
        sale_sold[_index] += amount;
    }

    function subSaleSold(uint256 _index, uint256 amount) internal {
        require(amount > 0);
        require(_index < sale_sold.length);
        require(sale_sold[_index].sub(amount) >= 0);
        sale_sold[_index] -= amount;
    }

    function canSaleInfo() public view returns(
        uint sale_number,
        uint256 start_timestamp,
        uint256 end_timestamp,
        uint8 bonus_rate,
        uint256 sell_limit
    ) {
        var(sale_info, isSale) = nowSaleInfo();
        require(isSale == true);
        sale_number = sale_info.sale_number;
        start_timestamp = sale_info.start_timestamp;
        end_timestamp = sale_info.end_timestamp;
        bonus_rate = sale_info.bonus_rate;
        sell_limit = sale_info.sell_limit;
    }

    function nowSaleInfo() internal view returns(Sale sale_info, bool isSale) {
        isSale = false;
        for (uint i=0; i < sale_list.length; i++) {
            uint256 end_timestamp = sale_list[i].end_timestamp;
            uint256 sell_limit = sale_list[i].sell_limit;
            uint8 bonus_rate = sale_list[i].bonus_rate;
            uint256 sell_limit_plus_bonus = addBonus(sell_limit, bonus_rate);
            uint256 temp_sold_token = sale_sold[i];
            if ((now <= end_timestamp) && (temp_sold_token < sell_limit_plus_bonus)) {
                sale_info = Sale({
                    sale_number: sale_list[i].sale_number,
                    start_timestamp: sale_list[i].start_timestamp,
                    end_timestamp: sale_list[i].end_timestamp,
                    bonus_rate: sale_list[i].bonus_rate,
                    sell_limit: sale_list[i].sell_limit
                });
                isSale = true;
                break;
            } else {
                isSale = false;
                continue;
            }
        }
    }
}
