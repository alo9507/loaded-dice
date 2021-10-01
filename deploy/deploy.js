const hre = require("hardhat");

async function main() {
    const LoadedDice = await hre.ethers.getContractFactory("LoadedDice");
    const loadedDice = await LoadedDice.deploy();
    await loadedDice.deployed();

    console.log("LoadedDice deployed to:", loadedDice.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
