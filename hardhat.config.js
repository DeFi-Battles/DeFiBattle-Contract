require("@nomiclabs/hardhat-waffle");

const INFURA_ENDPOINT = "https://rinkeby.infura.io/v3/162408c0fa52425fa3252add6d3820d7";

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const RINKEBY_PRIVATE_KEY = "d8d2c0e36f79c02788d3712dd62ffe9aae965d2502b85694a62a95be807f3803";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ],

  }, 

  networks: {
    rinkeby: {
      url: `${INFURA_ENDPOINT}`,
      accounts: [`0x${RINKEBY_PRIVATE_KEY}`]
    }
  }
};
