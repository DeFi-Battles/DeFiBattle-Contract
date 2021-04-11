require("@nomiclabs/hardhat-waffle");

const INFURA_ENDPOINT = "";

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const RINKEBY_PRIVATE_KEY = "";

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
