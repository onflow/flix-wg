access(all) 
contract FLIXRegistry {

    access(all)
    event ContractInitialized()

    access(all)
    event RegistryCreated(name: String)

    access(all)
    event Published(registryOwner: Address, registryName: String, registryUuid: UInt64, alias: String, id: String, cadenceBodyHash: String)

    access(all)
    event Removed(registryOwner: Address, registryName: String, registryUuid: UInt64, id: String)

    access(all)
    event Deprecated(registryOwner: Address, registryName: String, registryUuid: UInt64, id: String)

    access(all)
    event AliasLinked(alias: String, id: String)

    access(all)
    event AliasUnlinked(alias: String)

    access(all)
    enum FLIXStatus: UInt8 {

        access(all)
        case active

        access(all)
        case deprecated
    }

    access(all)
    struct FLIX {
        access(all)
        let id: String

        access(all)
        let jsonBody: String

        access(all)
        let cadenceBodyHash: String

        pub(set)
        var status: FLIXStatus

        init(id: String, jsonBody: String, cadenceBodyHash: String) {
            self.id = id
            self.jsonBody = jsonBody
            self.cadenceBodyHash = cadenceBodyHash
            self.status = FLIXStatus.active
        }
    }

    access(all)
    resource interface Queryable{
        access(all)
        fun resolve(cadenceBodyHash: String): FLIX?

        access(all)
        fun lookup(idOrAlias: String): FLIX?

        access(all)
        fun getIds(): [String]

        access(all)
        fun getAllAlias(): {String: String}
    }

    access(all)
    resource interface Admin {

        /// Add the flix to the registry and add or update the alias to point to this flix
        access(all) 
        fun publish(alias: String, flix: FLIX)

        access(all)
        fun link(alias: String, id: String)

        access(all)
        fun unlink(alias: String)

        access(all)
        fun deprecate(idOrAlias: String)
    }

    access(all)
    resource interface Removable {
        access(all)
        fun remove(id: String): FLIX?
    }

    access(all)
    resource Registry: Queryable, Removable, Admin {

        access(account) var flixes: {String: FLIX}
        access(account) var aliases: {String: String}
        access(account) var cadenceBodyHashes: {String: FLIX}
        access(account) let name: String

        access(all) 
        fun publish(alias: String, flix: FLIX) {
            self.flixes[flix.id] = flix
            self.aliases[alias] = flix.id
            emit Published(registryOwner: self.owner!.address, registryName: self.name, registryUuid: self.uuid, alias: alias, id: flix.id, cadenceBodyHash: flix.cadenceBodyHash)
        }

        access(all)
        fun link(alias: String, id: String) {
            self.aliases[alias] = id
            emit AliasLinked(alias: alias, id: id)
        }

        access(all)
        fun unlink(alias: String) {
            self.aliases.remove(key: alias)
            emit AliasUnlinked(alias: alias)
        }

        access(all)
        fun lookup(idOrAlias: String): FLIX? {
            if self.aliases.containsKey(idOrAlias) {
                return self.flixes[self.aliases[idOrAlias]!]
            }
            return self.flixes[idOrAlias]
        }

        access(all)
        fun resolve(cadenceBodyHash: String): FLIX? {
            return self.cadenceBodyHashes[cadenceBodyHash]
        }

        access(all)
        fun deprecate(idOrAlias: String) {
            var flix = self.lookup(idOrAlias: idOrAlias) ?? panic("FLIX does not exist with the given id or alias: ".concat(idOrAlias))
            flix.status = FLIXStatus.deprecated
            self.flixes[flix.id] = flix
            emit Deprecated(registryOwner: self.owner!.address, registryName: self.name, registryUuid: self.uuid, id: flix.id)
        }

        access(all)
        fun remove(id: String): FLIX? {
            let removed = self.flixes.remove(key: id)
            if(removed != nil) { emit Removed(registryOwner: self.owner!.address, registryName: self.name, registryUuid: self.uuid, id: id) }
            return removed
        }

        access(all)
        fun getIds(): [String] {
            return self.flixes.keys
        }

        access(all)
        fun getAllAlias(): {String: String} {
            return self.aliases
        }

        init(name: String) {
            self.name = name
            self.flixes = {}
            self.aliases = {}
            self.cadenceBodyHashes = {}
            emit RegistryCreated(name: name)
        }
    }

    access(all)
    fun createRegistry(name: String): @Registry {
        return <- create Registry(name: name)
    }

    access(all)
    fun PublicPath(name: String): PublicPath {
        return PublicPath(identifier: "flix_".concat(name))!
    }

        access(all)
    fun StoragePath(name: String): StoragePath {
        return StoragePath(identifier: "flix_".concat(name))!
    }

    init() {
        emit ContractInitialized()
    }

}
