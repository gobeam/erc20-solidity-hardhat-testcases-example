//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./ERC20Interface.sol";
import "./Ownable.sol";
import "./Treasurer.sol";

contract GobeamToken is ERC20Interface, Ownable, Treasurer, SafeMath {
    string private _symbol;
    string private _name;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _treasurerFee;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    event TreasurerFee(address indexed from, uint256 amount);

    constructor() public {
        _symbol = "GOBEAM";
        _name = "GobeamToken";
        _decimals = 18;
        _totalSupply = 1000000000000000000000000*10**_decimals;
        _treasurerFee = 25;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function balanceOf(address _account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[_account];
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool success)
    {
        _transfer(msg.sender, to, amount*10**_decimals);
        return true;
    }

    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool success)
    {
        _allowances[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool success) {
        _allowances[from][msg.sender] = safeSub(
            _allowances[from][msg.sender],
            amount
        );
        _transfer(from, to, amount*10**_decimals);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual {
        require(_from != address(0), "cannot transfer from the zero address");
        require(_to != address(0), "cannot transfer to the zero address");
        require(_balances[_from] >= _amount, "Token not enough");
        if (_from == treasurer) {
            _balances[_from] = safeSub(_balances[_from], _amount);
            _balances[_to] = safeAdd(_balances[_to], _amount);

            emit Transfer(_from, _to, _amount);
        } else {
            uint256 treasurerFee = safeDiv(
                safeMul(_amount, _treasurerFee),
                1000
            );
            _balances[_from] = safeSub(_balances[_from], _amount);
            _balances[treasurer] = safeAdd(_balances[treasurer], treasurerFee);
            _balances[_to] += safeAdd(
                _balances[_to],
                safeSub(_amount, treasurerFee)
            );

            emit Transfer(_from, _to, _amount);
            emit TreasurerFee(_from, _amount);
        }
    }
}
