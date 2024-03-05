import FLIXRegistry from 0xf8d6e0586b0a20c7
import FLIXSchema_v1_1_0 from 0xf8d6e0586b0a20c7

transaction(alias: String, flix: FLIXSchema_v1_1_0.FLIX, registryName: String) {

    prepare(signer: AuthAccount) {
        let registry = signer.borrow<&FLIXRegistry.Registry>(from: FLIXRegistry.StoragePath(name: registryName))
                            ?? panic("Could not borrow a reference to the Registry")
        registry.publish(alias: alias, flix: flix)
    }
}

