import "FLIXRegistry"

transaction(alias: String) {

    prepare(signer: AuthAccount) {
        let registry = signer.borrow<&FLIXRegistry.Registry>(from: /storage/stableFlixRegistry)
                            ?? panic("Could not borrow a reference to the Registry")

        registry.unlink(alias: alias)
    }
}