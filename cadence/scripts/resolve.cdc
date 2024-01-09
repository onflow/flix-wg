import "FLIXRegistry"

pub fun main(accountAddress: Address, cadenceBodyHash: String): FLIXRegistry.FLIX? {
    let account = getAccount(accountAddress)
    let registry = account.getCapability(/public/stableFlixRegistryPublic)
                            .borrow<&FLIXRegistry.Registry{FLIXRegistry.Queryable}>()
                            ?? panic("Could not borrow a reference to the Registry")

    return registry.resolve(cadenceBodyHash: cadenceBodyHash)
}