import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers, deployments } = hre
  const { deploy, get } = deployments

  const signers = await ethers.getSigners()
  const deployer = signers[0]

  const AddressBookDeployment = await get('AddressBook')

  const deployment = await deploy('NftReferalStaking', {
    contract: 'NftReferalStaking',
    from: deployer.address,
    proxy: {
      proxyContract: 'UUPS',
      execute: {
        init: {
          methodName: 'initialize',
          args: [
            AddressBookDeployment.address, // _addressBook
            365 * 24 * 60 * 60, // _lockPeriod
          ],
        },
      },
    },
  })
}

deploy.tags = ['NftReferalStaking']
deploy.dependencies = ['AddressBook']
export default deploy
