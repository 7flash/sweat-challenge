pragma solidity ^0.4.18;

import "./DateTime.sol";

contract Sweat {
    uint256 balance;

    uint256 public daysDuration;
    uint256 public end;
    uint256 public windowStart;
    uint256 public windowEnd;

    address public boss;
    address public worker;

    mapping (uint8 => bool) public accomplishedDays;

    address dateTime;

    // @param _boss Адрес начальника, который сможет пополнять баланс контракта
    // @param _worker Адрес работника, который сможет получить деньги в случае выполнения обещаний
    // @param _daysDuration Длительность контракта в днях, после чего деньги смогут быть выведены со счета
    // @param _windowStart Начало промежутка времени для подтверждения выполненной работы каждый день
    // @param _windowEnd Конец промежутка времени для подтверждения выполненной работы каждый день
    function Sweat(address _boss, address _worker, uint256 _daysDuration, uint256 _windowStart, uint256 _windowEnd) {
        boss = _boss;
        worker = _worker;

        daysDuration = _daysDuration;
        end = now + daysDuration * 1 days + 1 days;

        windowStart = _windowStart;
        windowEnd = _windowEnd;

        dateTime = new DateTime();
    }

    // @notice Начальник сможет пополнять баланс контракта, отправляя эфир на счет
    function () payable {
        require(msg.sender == boss);
    }

    // @notice Начальник сможет вывести деньги со счета после окончания времени контракта, если сотрудник провинился
    function withdrawBoss() {
        require(msg.sender == boss);
        require(balance < daysDuration);
        require(now > end);

        boss.transfer(this.balance);
    }

    // @notice Сотрудник сможет вывести деньги со счета после окончания времени контракта,
    //         если он собрал достаточное количество токенов за это время
    function withdrawWorker() {
        require(msg.sender == worker);
        require(balance >= daysDuration);

        worker.transfer(this.balance);
    }

    // @notice Каждый день сотрудник должен подтвердить выполненную работу вызовом транзакции в определенный
               промежуток времени
    function accomplish() {
        require(msg.sender == worker);

        uint8 currentDay = DateTime(dateTime).getDay(now);

        require(now < end);
        require(accomplishedDays[currentDay] == false);

        balance++;

        accomplishedDays[currentDay] = true;
    }

    // @notice Работник сможет видеть свой прогресс через Metamask или MEW
    function balanceOf(address _compatibility) public constant returns(uint256) {
        return balance;
    }
}