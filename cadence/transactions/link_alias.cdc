import "FLIXRegistry"

transaction(alias: String, templateId: String) {

    prepare(signer: AuthAccount) {
        let registry = signer.borrow<&FLIXRegistry.Registry>(from: /storage/stableFlixRegistry)
                            ?? panic("Could not borrow a reference to the Registry")

        registry.link(alias: alias, id: templateId)
    }
}