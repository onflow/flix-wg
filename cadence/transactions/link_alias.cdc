import FLIXRegistry from 0xf8d6e0586b0a20c7

transaction(alias: String, templateId: String, registryName: String) {

    prepare(signer: AuthAccount) {
        let registry = signer.borrow<&FLIXRegistry.Registry>(from: FLIXRegistry.StoragePath(name: registryName))
                            ?? panic("Could not borrow a reference to the Registry")

        registry.link(alias: alias, id: templateId)
    }
}