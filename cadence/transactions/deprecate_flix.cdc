import "FLIXRegistry"

transaction(idOrAlias: String) {

    prepare(signer: AuthAccount) {
        let registry = signer.borrow<&FLIXRegistry.Registry>(from: /storage/stableFlixRegistry)
                            ?? panic("Could not borrow a reference to the Registry")

        registry.deprecate(idOrAlias: idOrAlias)
    }
}
