pragma solidity ^0.6.6;

// This contract is deployed on Kovan and addresses are hardcoded

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

// Contract for Chainlink VRF
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract YourContract is ERC721, VRFConsumerBase {
    // Used By Constructor
    bytes32 public keyHash;
    address public vrfCoordinator;

    // Fee for Chainlink oracle
    uint256 internal fee;

    uint256 public randomResult;

    // Character properties
    struct Character {
        // uint256 strength;
        // uint256 luck;
        // uint256 speed;
        // string name;
        uint256 dna;
    }

    // Array of Characters for storing new characters minted
    Character[] public characters;

    mapping(bytes32 => string) requestToCharacterName;
    mapping(bytes32 => address) requestToSender;
    mapping(bytes32 => uint256) requestToTokenId;

    // The contructor inherits ERC721 and VRFConsumer. VRFConsumerBase (VRF Coordinator, LINK Token)
    constructor()
        public
        ERC721("Peaceful Monsters", "MONSTER")
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK Token
        )
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    // This function initiates request to Chainlink VRF for random number
    // userProvidedSeed is needed for the randomness function
    function requestRandomCharacter(
        uint256 userProvidedSeed,
        string memory name
    ) public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed);

        // Used to map random number to name of Character
        requestToCharacterName[requestId] = name;
        // Maps address calling the function to requestId
        requestToSender[requestId] = msg.sender;

        // console.log(requestId);
        return requestId;
    }

    // This functions retrieves the random number and performs some task with it.
    // requestRandomness function returns requestId and randomNumber
    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        console.log(randomNumber);
        uint256 newId = characters.length;
        // uint256 strength = (randomNumber % 100);
        // uint256 luck = (((randomNumber) % 10000) / 100);
        // uint256 speed = ((randomNumber % 10) * 82);
        uint256 dna = randomNumber;

        characters.push(Character(dna));

        _safeMint(requestToSender[requestId], newId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Function caller not owner // Approved"
        );

        _setTokenURI(tokenId, _tokenURI);
    }
}
