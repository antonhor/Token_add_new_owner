// SPDX-License-Identifier: MIT
/*
Copy of previous contract but with right names;
**/
pragma solidity >=0.4.22 <0.8.0;

contract GoodsToken2 {
    string public constant name = "GoodsToken2";
    string public constant symbol = "DTV";
    uint8 public constant decimals = 18;
    uint256 public startTime = block.timestamp + 7 minutes;
    uint256 public totalSupply;
    address[] public owners;
    
    mapping(address => pool) pools;

    mapping (address => uint256) balances;
    
    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => bool) onlyOwnership;
    
    struct pool {
        mapping(address => bool) voters;
        uint256 numberOfVoter;
    }

    constructor () public {
        onlyOwnership[msg.sender] = true;
        owners.push(msg.sender);
        onlyOwnership[0xE0F318cd9a66820c886bFd0c584B00933A04998D] = true;
        owners.push(0xE0F318cd9a66820c886bFd0c584B00933A04998D);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _from, address indexed _to, uint256 _value);
    event Burned(address indexed _from, uint256 _amount);

    

    function mint (address _to, uint256 _value) public onlyOwner{
        require(totalSupply + _value >= totalSupply && balances[_to] + _value >= balances[_to]);
        balances[_to] += _value;
        totalSupply += _value;
    }
    
    modifier onlyOwner() {
        require(onlyOwnership[msg.sender] == true);
        _;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public {
        require(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }
    
    function transferFrom (address _from, address _to, uint256 _value) public {
        require(balances[_from] >= _value && balances[_to] + _value >= balances[_to] && allowed[_from][msg.sender] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }
    
    function approve (address _spender, uint256 _value) public {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function burn(uint256 _value) public {
        require(balances[msg.sender] >= _value && _value>0);
        if (block.timestamp > startTime) {
            balances[msg.sender] -= _value;
            totalSupply -= _value;
            emit Burned(msg.sender, _value);
        }
    }

    function addNewOwner (address _newOwner) public onlyOwner{
        require(pools[_newOwner].numberOfVoter>owners.length/2);
        bool noMatches;
        for (uint256 i = 0; i<owners.length;i++){
            if (i == owners.length - 1 && owners[i] != _newOwner) {
                noMatches = true;
            }
        }
        if(noMatches) {
            owners.push(_newOwner);
            onlyOwnership[_newOwner] = true;
            noMatches = false;
            pools[_newOwner].numberOfVoter = 0;
            for(uint256 n=0;n<owners.length;n++){
                delete pools[_newOwner].voters[owners[n]];
            }
        }
    }
}