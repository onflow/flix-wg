import "FLIXRegistry"

pub fun main(accountAddress: Address, cadenceBodyHash: String, registryName: String): FLIXRegistry.FLIX? {
    let account = getAccount(accountAddress)
    let registry = account.getCapability(FLIXRegistry.PublicPath(name: registryName))
                            .borrow<&FLIXRegistry.Registry{FLIXRegistry.Queryable}>()
                            ?? panic("Could not borrow a reference to the Registry")

    return registry.resolve(cadenceBodyHash: cadenceBodyHash)
}