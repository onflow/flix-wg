import "FLIXRegistry"

pub fun main(address: Address, registryName: String): Int {
    let account = getAccount(address)
    let registry = account.getCapability(FLIXRegistry.PublicPath(name: registryName))
                            .borrow<&FLIXRegistry.Registry{FLIXRegistry.Queryable}>()
                            ?? panic("Could not borrow a reference to the Registry")

    return registry.getIds().length
}