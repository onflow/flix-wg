import "FLIXRegistry"

pub fun main(address: Address): Int {
    let account = getAccount(address)
    let registry = account.getCapability(/public/stableFlixRegistryPublic)
                            .borrow<&FLIXRegistry.Registry{FLIXRegistry.Queryable}>()
                            ?? panic("Could not borrow a reference to the Registry")

    return registry.getIds().length
}