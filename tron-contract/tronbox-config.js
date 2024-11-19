require("dotenv").config();

module.exports = {
  networks: {
    development: {
      userFeePercentage: 100, // The percentage of resource consumption ratio.
      feeLimit: 100000000, // The TRX consumption limit for the deployment and trigger, unit is SUN
      privateKey:
        "a23ff50b419e86ecb55ff5cb42d12f3d69427ada8fecb6ebccdd287e77196a27",
      fullHost: "https://api.shasta.trongrid.io",
      network_id: "2", // Shasta testnet
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",
    },
  },
  // solc compiler optimize
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
    evmVersion: "istanbul",
  },
};
