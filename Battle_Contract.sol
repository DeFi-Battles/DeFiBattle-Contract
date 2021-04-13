pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

contract YourContract {
    // enum Choice {
    //     None,
    //     Rock,
    //     Paper, // p2
    //     Scissors // p1
    // }

    enum Stage {
        FirstCommit,
        SecondCommit,
        FirstReveal,
        SecondReveal,
        Distribute
    }

    struct CommitChoice {
        address playerAddress;
        bytes32 commitment;
        // Choice choice;
        string[3] choice;
    }

    event Payout(address player, uint amount);

    // Initialisation args
    uint public bet;
    uint public deposit;
    uint public revealSpan;

    // State vars
    CommitChoice[2] public players;
    uint public revealDeadline;
    Stage public stage = Stage.FirstCommit;

    constructor(uint _bet, uint _deposit, uint _revealSpan) public {
        bet = _bet;
        deposit = _deposit;
        revealSpan = _revealSpan;
    }

    function commit(bytes32 commitment) public payable {
      console.log("cs");
        // Only run during commit stages
        uint playerIndex;
        if(stage == Stage.FirstCommit) playerIndex = 0;
        else if(stage == Stage.SecondCommit) playerIndex = 1;
        else revert("both players have already played");

        uint commitAmount = bet + deposit;
        require(commitAmount >= bet, "overflow error");
        require(msg.value >= commitAmount, "value must be greater than commit amount");

        // Return additional funds transferred
        if(msg.value > commitAmount) {
            (bool success, ) = msg.sender.call.value(msg.value - commitAmount)("");
            require(success, "call failed");
        }

        // Store the commitment
        players[playerIndex] = CommitChoice(msg.sender, commitment, ["dada", "dada", "dada"]);

        // If we're on the first commit, then move to the second
        if(stage == Stage.FirstCommit) stage = Stage.SecondCommit;
        // Otherwise we must already be on the second, move to first reveal
        else stage = Stage.FirstReveal;
    }

    // used to generate commitment
    function createCommitment(address player, string[3] memory choice, bytes32 blindingFactor) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(player,choice[0],choice[1], choice[2], blindingFactor));
    }
    
    
    function reveal(string[3] memory choice, bytes32 blindingFactor) public {
        // Only run during reveal stages
        require(stage == Stage.FirstReveal || stage == Stage.SecondReveal, "not at reveal stage");
        // Only accept valid choices
        // require(choice == Choice.Rock || choice == Choice.Paper || choice == Choice.Scissors, "invalid choice");

        // Find the player index
        uint playerIndex;
        if(players[0].playerAddress == msg.sender) playerIndex = 0;
        else if (players[1].playerAddress == msg.sender) playerIndex = 1;
        // Revert if unknown player
        else revert("unknown player");

        // Find player data
        CommitChoice storage commitChoice = players[playerIndex];

        // Check the hash to ensure the commitment is correct
        require(keccak256(abi.encodePacked(msg.sender, choice[0], choice[1], choice[2], blindingFactor)) == commitChoice.commitment, "invalid hash");

        // Update choice if correct
        commitChoice.choice= choice;

        if(stage == Stage.FirstReveal) {
            // If this is the first reveal, set the deadline for the second one
            revealDeadline = block.number + revealSpan;
            require(revealDeadline >= block.number, "overflow error");
            // Move to second reveal
            stage = Stage.SecondReveal;
        }
        // If we're on second reveal, move to distribute stage
        else stage = Stage.Distribute;
    }

    function parseInt(string memory _value)
        public
        pure
        returns (uint _ret) {
        bytes memory _bytesValue = bytes(_value);
        uint j = 1;
        for(uint i = _bytesValue.length-1; i >= 0 && i < _bytesValue.length; i--) {
            assert(uint8(_bytesValue[i]) >= 48 && uint8(_bytesValue[i]) <= 57);
            _ret += (uint8(_bytesValue[i]) - 48)*j;
            j*=10;
        }
    }

    function distribute() public {
       require(stage == Stage.Distribute || (stage == Stage.SecondReveal && revealDeadline <= block.number), "cannot yet distribute");

        uint player0Payout;
        uint player1Payout;
        uint winningAmount = deposit + 2 * bet;

        uint256 health0;
        uint256 health1;

        uint256 attack00 = parseInt(players[0].choice[0]);
        uint256 attack01 = parseInt(players[0].choice[1]); // health
        uint256 attack02 = parseInt(players[0].choice[2]);

        uint256 attack10 = parseInt(players[1].choice[0]);
        uint256 attack11 = parseInt(players[1].choice[1]); // health
        uint256 attack12 = parseInt(players[1].choice[2]);

        health0 = 100 - attack10 + attack01 - attack12;
        health1 = 100 - attack00 + attack11 - attack02;

        console.log(health0, health1);

        if (health1 > health0) {
            console.log("player 1, won");
        }
        else {
          console.log("player 2, won");
        }

                    // Reset the state to play again
        delete players;
        revealDeadline = 0;
        stage = Stage.FirstCommit;

    }


    
}
