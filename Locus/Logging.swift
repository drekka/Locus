//
//  Logging.swift
//  locus
//
//  Created by Derek Clarkson on 13/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

func locusLog(_ template: String, _ args: CVarArg...) {
    locusLog(template, arguments: args)
}

func locusLog(_ template: String, arguments: [CVarArg]) {
    os_log(.debug, "🧩 %@", String(format: template, arguments: arguments))
}

public func locusFatalError(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("🧨  " + message(), file: file, line: line)
}
