//
//  BackgroundTask.swift
//  spree3d
//
//  Created by hassan uriostegui on 1/17/21.
//

import UIKit

// NOTE: By default is 10 minutes to expire https://developer.apple.com/documentation/uikit/uibackgroundtaskidentifier

class BackgroundTask {
    private var identifier = UIBackgroundTaskIdentifier.invalid
    var application: UIApplication {
        UIApplication.shared
    }

    func start() {
        identifier = application.beginBackgroundTask {
            self.finish()
        }
    }

    func finish() {
        if identifier != UIBackgroundTaskIdentifier.invalid {
            application.endBackgroundTask(identifier)
        }

        identifier = UIBackgroundTaskIdentifier.invalid
    }
}

extension BackgroundTask {
    static func run(handler: (BackgroundTask) -> Void) {
        // NOTE: The handler must call end() when it is done

        let backgroundTask = BackgroundTask()
        backgroundTask.start()
        handler(backgroundTask)
    }

    static func runThrowing(handler: (BackgroundTask) throws -> Void) throws {
        // NOTE: The handler must call end() when it is done

        do {
            let backgroundTask = BackgroundTask()
            backgroundTask.start()
            try handler(backgroundTask)
        } catch {
            throw error
        }
    }
}
