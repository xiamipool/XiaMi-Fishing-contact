pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";


import "../interface/IERC20.sol";
import "../interface/IPool.sol";
import "./Governance.sol";
import "../interface/IPowerStrategy.sol";


contract LPTokenWrapper is IPool,Governance {
    using SafeMath for uint256;

    IERC20 public _lpToken = IERC20(0x4A2d7984A2c35780E431675053Ba93Af674e9520);

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    uint256 private _totalPower;
    mapping(address => uint256) private _powerBalances;

    address public _powerStrategy = address(0x0);


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function setPowerStragegy(address strategy)  public  onlyGovernance{
        _powerStrategy = strategy;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function balanceOfPower(address account) public view returns (uint256) {
        return _powerBalances[account];
    }



    function totalPower() public view returns (uint256) {
        return _totalPower;
    }


    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);

        if( _powerStrategy != address(0x0)){
            _totalPower = _totalPower.sub(_powerBalances[msg.sender]);
            IPowerStrategy(_powerStrategy).lpIn(msg.sender, amount);

            _powerBalances[msg.sender] = IPowerStrategy(_powerStrategy).getPower(msg.sender);
            _totalPower = _totalPower.add(_powerBalances[msg.sender]);
        }else{
            _totalPower = _totalSupply;
            _powerBalances[msg.sender] = _balances[msg.sender];
        }

        _lpToken.transferFrom(msg.sender, address(this), amount);


    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "amout > 0");

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        if( _powerStrategy != address(0x0)){
            _totalPower = _totalPower.sub(_powerBalances[msg.sender]);
            IPowerStrategy(_powerStrategy).lpOut(msg.sender, amount);
            _powerBalances[msg.sender] = IPowerStrategy(_powerStrategy).getPower(msg.sender);
            _totalPower = _totalPower.add(_powerBalances[msg.sender]);

        }else{
            _totalPower = _totalSupply;
            _powerBalances[msg.sender] = _balances[msg.sender];
        }

        _lpToken.transfer(msg.sender, amount);
    }


}