import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import ResturauntAPI
import UserAPI

HeliumLogger.use()

let rest = Resturaunt()
let controller = ResturauntController(backend: rest)

Kitura.addHTTPServer(onPort: controller.port, with: controller.router)
Kitura.run()
