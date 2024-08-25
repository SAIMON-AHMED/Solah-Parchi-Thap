// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SolahParchiThap {

    address public owner;
    address[4] public players;
    uint8[4][4] public parchis;

    uint256 public start;
    uint8 public turn;
    bool public activeGame;

    mapping(address => uint8) public playerNum;
    mapping(address => uint8) public win;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
        _;
    }

    modifier onlyActiveGame() {
        require(activeGame, "No active game");
        _;
    }

    modifier onlyPlayerTurn() {
        require(turn == playerNum[msg.sender], "Not your turn");
        _;
    }

// To set and start the game
    function setState(address[4] memory _players, uint8[4][4] memory _parchis) public onlyOwner {
        for (uint8 i; i < 4; i++) {
            require(_players[i] != owner && _players[i] != address(0));
            players[i] = _players[i];
            playerNum[_players[i]] = i + 1;
        }
        for (uint i; i < 4; i++) {
            uint8 numOfParchis = 0;
            for (uint j; j < 4; j++) {
                numOfParchis += _parchis[i][j];
            }
            require(numOfParchis == 4);
            parchis[i] = _parchis[i];
        }

        turn = 1;
        start = block.timestamp;
        activeGame = true;
    }

        


    function passParchi(uint8 _type) public onlyActiveGame onlyPlayerTurn {
        require(parchis[turn - 1][_type - 1] > 0, "No parchis of this type to pass");

        parchis[turn - 1][_type - 1]--;

        if (turn == 4) {
            parchis[0][_type - 1]++;
            turn = 1;
        } else {
            parchis[turn][_type - 1]++;
            turn++;
        }
    }

    function claimWin() public onlyActiveGame {
        uint8[4] memory playerParchis = parchis[playerNum[msg.sender] - 1];
        for (uint8 i = 0; i < 4; i++) {
            if (playerParchis[i] == 4) {
                win[msg.sender]++;
                activeGame = false;
                reset();
                return;
            }
        }
        revert("No winning combination");
    }

    function endGame() public onlyActiveGame {
        require(playerNum[msg.sender] >= 1 && playerNum[msg.sender] <= 4
        && activeGame);
        require(block.timestamp >= start + 1 hours, "Game cannot be ended yet");
        reset();
        activeGame = false;
    }

    function getState() public view onlyOwner returns (address[4] memory, address, uint8[4][4] memory) {
        require(activeGame);
        return (players, players[turn - 1], parchis);
    }

    function getWins(address _player) public view returns (uint256) {
        require(_player != owner);
        return win[_player];
    }

    function myParchis() public view returns (uint8[4] memory) {
        require(playerNum[msg.sender] >= 1 && playerNum[msg.sender] <= 4 && activeGame);
        return parchis[playerNum[msg.sender] - 1];
    }

    function reset() internal {
        playerNum[players[0]] = 0;
        playerNum[players[1]] = 0;
        playerNum[players[2]] = 0;
        playerNum[players[3]] = 0;
        players[0] = address(0);
        players[1] = address(0);
        players[2] = address(0);
        players[3] = address(0);
    }
}
