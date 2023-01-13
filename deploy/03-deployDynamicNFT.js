const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
const fs=require('fs')
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let ethUsdPriceFeedAddress
    if (chainId == 31337) {
        // Find ETH/USD price feed
        const EthUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = EthUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed
    }

    const lowSVG = fs.readFileSync("./images/dynamicNft/frown.svg", { encoding: "utf8" })
    const highSVG = fs.readFileSync("./images/dynamicNft/smile.svg", { encoding: "utf8" })
    log("----------------------------------------------------")
    arguments = [ethUsdPriceFeedAddress,lowSVG,highSVG]
    const dynamicNft = await deploy("DynamicSVGnft", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(dynamicNft.address, arguments)
    }
}

module.exports.tags = ["all", "dynamicsvg", "main"]
