


const { network } = require("hardhat")


module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const developmentChains = ["hardhat", "localhost"];
    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS

    log("----------------------------------------------------")
    const arguments = []
    const nftMarketplace = await deploy("marketPlace", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    })

    
    log("----------------------------------------------------")
}

module.exports.tags = ["all", "nftmarketplace"]