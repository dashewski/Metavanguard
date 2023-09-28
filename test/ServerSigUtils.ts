import { BigNumberish, Signer, Wallet, ethers } from 'ethers'
import { ProductOwnerMarketplace__factory } from '../typechain-types'

export class ServerSigUtils {
  static async signDiscountedBuy({
    signer,
    recipient,
    nftToken,
    discount,
    uuidHash,
    exireiesTimestamp,
  }: {
    signer: Signer | Wallet
    recipient: string
    nftToken: string
    discount: BigNumberish
    uuidHash: string
    exireiesTimestamp: BigNumberish
  }): Promise<string> {
    const methodSig = ProductOwnerMarketplace__factory.createInterface().getSighash('discountedBuy')
    const messageHash = ethers.utils.solidityKeccak256(
      ['bytes4', 'address', 'address', 'uint256', 'bytes32', 'uint256'],
      [methodSig, recipient, nftToken, discount, uuidHash, exireiesTimestamp],
    )
    const messageHashBinary = ethers.utils.arrayify(messageHash)
    return await signer.signMessage(messageHashBinary)
  }
}
