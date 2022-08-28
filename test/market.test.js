const{expect}=require("chai");

const { network, deployments, ethers, getNamedAccounts} = require("hardhat");

const developmentChains = ["hardhat", "localhost"];

!developmentChains.includes(network.name)
? describe.skip
: describe("Dynamic SVG NFT Unit Tests", function () {
    let marketPlace, deployer, user, basicNft, instance, nftInstance;
    const TOKEN_ID=0;
    const PRICE = ethers.utils.parseEther("1");

    beforeEach(async()=>{

        deployer=(await getNamedAccounts()).deployer;

        user=(await getNamedAccounts()).user;
        await deployments.fixture(["all"]);

        // const accounts=await ethers.getSigners();

       

        instance=await ethers.getContract("marketPlace", deployer);
        // marketPlace=await instance.connect(deployer);

        basicNft= await ethers.getContract("BasicNft", deployer);
        // basicNft=await nftInstance.connect(deployer);
        await basicNft.mintNft();

        await basicNft.setApproval(instance.address, TOKEN_ID);
    })

    describe("list Items", ()=>{
        it("SHould emit event after listing an NFT", async()=>{
            /* const tx=await instance.listNft(basicNft.address, TOKEN_ID, PRICE);
            
            

            await tx.wait(1);

            expect(tx).to.emit("itemListed"); */
            
            expect(await nftMarketplace.listItem(basicNft.address, TOKEN_ID, PRICE)).to.emit(
                      "itemListed"
                  );
        })
    })

   
})
