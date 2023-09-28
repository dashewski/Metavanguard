import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { AddressBook__factory } from '../typechain-types'

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers, deployments } = hre
  const { deploy, get } = deployments

  const signers = await ethers.getSigners()
  const deployer = signers[0]
  const server = signers[1]

  const AddressBookDeployment = await get('AddressBook')

  const deployment = await deploy('NftTokensObserver', {
    contract: 'NftTokensObserver',
    from: deployer.address,
    proxy: {
      proxyContract: 'UUPS',
      execute: {
        init: {
          methodName: 'initialize',
          args: [
            AddressBookDeployment.address, // _addressBook
          ],
        },
      },
    },
  })
  
  const addressBook = AddressBook__factory.connect(AddressBookDeployment.address, deployer)
  await (await addressBook.setNftTokensObserver(deployment.address)).wait()
}

deploy.tags = ['NftTokensObserver']
deploy.dependencies = ['AddressBook']
export default deploy
