//
//  Logging.swift
//  environ
//
//  Created by Derek Clarkson on 13/5/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import os

func environLog(_ template: String, _ args: CVarArg...) {
    environLog(template, args)
}

func environLog(_ template: String, _ arguments: [CVarArg]) {
    os_log(.debug, "🧩 %@", String(format: template, arguments: arguments))
}
