import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { AddressBook__factory, NftToken__factory } from '../typechain-types'

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { ethers, deployments } = hre
  const { deploy, get } = deployments

  const signers = await ethers.getSigners()
  const deployer = signers[0]
  
  const NftTokenImplementationDeployment = await get('NftTokenImplementation')
  const AddressBookDeployment = await get('AddressBook')

  const deployment = await deploy('DubaiNftToken', {
    contract: 'ERC1967Proxy',
    from: deployer.address,
    args: [
      NftTokenImplementationDeployment.address,
      NftToken__factory.createInterface().encodeFunctionData('initialize', [
        AddressBookDeployment.address, // _addressBook
        'Dubai Collection', // _name
        'DUBAI_MVTG', // _symbol
      ])
    ]
  })

  const addressBook = AddressBook__factory.connect(AddressBookDeployment.address, deployer)
  await (await addressBook.setNftToken(deployment.address, true)).wait()
}

deploy.tags = ['DubaiNftToken']
deploy.dependencies = ['NftTokenImplementation', 'AddressBook', 'NftTokensObserver']
export default deploy
