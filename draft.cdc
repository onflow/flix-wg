access(all)
contract FLIXRegistry{

    access(all)
    resource Registry {

    }

    access(all)
    event Published(id:String, cadenceBodyHash:String, alias:String, registry:Address, removeable:Bool)


    access(all)
    struct FLIXStatus {


    }

    access(all)
    struct FLIX {
        access(all) let id: String

        init(id: String) {
            self.id=id
        }
    }

    resource interface QueryableFLIX {

        access(all)
        fun resolve(cadenceBodyHash: String): &FLIX

        access(all)
        fun lookup(idOrAlias: String): &FLIX
    }

    resource interface Admin {

        /// Add the flix to the registry and add or update the alias to point to this flix
        access(all) 
        fun publish(alias:String, flix:FLIX)  {
            post {
                emit Published()
            }
        }

        access(all)
        fun link(alias:String, id:String)

        access(all)
        fun unlink(alias:String)

        access(all)
        fun deprecate(alias:String, status:FLIXStatus)
    }

    resource interface Removeable : Admin{
        access(all)
        fun remove(flix:FLIX)
    }

    //split on 0x123/<channel>/<aliasOrId>
    access(all)
    fun lookup(path:String) : &FLIX? {

        let paths = path.split(separator: "/")


        let address=  FLIXRegistry.stringToAddress(paths[0])
        let account = getAccount(address)

        let pp = PublicPath(identifier: paths[1])!
        let registry =account.capabilities.borrow<&{FLIXRegistry.QueryableFLIX}>(pp)!
        return registry.lookup(idOrAlias:paths[2])
    }

    access(all)
    fun lookupB(address:Address, path:PublicPath, aliasOrId:String) : &FLIX? {

        let account = getAccount(address)

        let registry =account.capabilities.borrow<&{FLIXRegistry.QueryableFLIX}>(path)!
        return registry.lookup(idOrAlias: aliasOrId)
    }

    access(all) fun stringToAddress(_ input:String): Address {
        var address=input
        if input.utf8[1] == 120 {
            address = input.slice(from: 2, upTo: input.length)
        }
        var r:UInt64 = 0
        var bytes = address.decodeHex()

        while bytes.length>0{
            r = r  + (UInt64(bytes.removeFirst()) << UInt64(bytes.length * 8 ))
        }

        return Address(r)
    }
}
