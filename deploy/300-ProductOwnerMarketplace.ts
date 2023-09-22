import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { AddressBook__factory } from '../typechain-types'
import { USDT } from '../constants/addresses'

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers, deployments } = hre
  const { deploy, get } = deployments

  const signers = await ethers.getSigners()
  const deployer = signers[0]
  const server = signers[1]

  const AddressBookDeployment = await get('AddressBook')

  const deployment = await deploy('ProductOwnerMarketplace', {
    contract: 'ProductOwnerMarketplace',
    from: deployer.address,
    proxy: {
      proxyContract: 'UUPS',
      execute: {
        init: {
          methodName: 'initialize',
          args: [
            AddressBookDeployment.address, // _addressBook
            server.address, // _server
            [USDT], // _payTokens
            [ethers.utils.parseUnits('2000', 18)], // _defaultPrices
          ],
        },
      },
    },
  })

  const addressBook = AddressBook__factory.connect(AddressBookDeployment.address, deployer)
  await (await addressBook.setProductOwnerMarketplace(deployment.address)).wait()
}

deploy.tags = ['ProductOwnerMarketplace']
deploy.dependencies = ['AddressBook', 'Treasury']
export default deploy
