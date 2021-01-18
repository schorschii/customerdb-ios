//
//  CallDirectoryHandler.swift
//  Copyright © 2020 Georg Sieber. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    let db = CallDirectoryDatabase()
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // Check whether this is an "incremental" data request. If so, only provide the set of phone number blocking
        // and identification entries which have been added or removed since the last time this extension's data was loaded.
        // But the extension must still be prepared to provide the full set of data at any time, so add all blocking
        // and identification phone numbers if the request is not incremental.
        if context.isIncremental {
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
            addOrRemoveIncrementalIdentificationPhoneNumbers(to: context)
        } else {
            addAllBlockingPhoneNumbers(to: context)
            addAllIdentificationPhoneNumbers(to: context)
        }

        context.completeRequest()
    }

    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve all phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.
    }

    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    }

    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve phone numbers to identify and their identification labels from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
        //
        // Numbers must be provided in numerically ascending order.

        NSLog("add_all")
        for number in db.getNumbers() {
            if let phoneNumber = Int64(number.mPhoneNumber.replacingOccurrences(of: " ", with: "")) {
                if phoneNumber > 0 {
                    context.addIdentificationEntry(
                        withNextSequentialPhoneNumber: phoneNumber,
                        label: number.mDisplayName
                    )
                }
            }
        }
    }

    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Retrieve any changes to the set of phone numbers to identify (and their identification labels) from data store. For optimal performance and memory usage when there are many phone numbers,
        // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.

        NSLog("add_incremental")
        context.removeAllIdentificationEntries()
        for number in db.getNumbers() {
            if let phoneNumber = Int64(number.mPhoneNumber.replacingOccurrences(of: " ", with: "")) {
                if phoneNumber > 0 {
                    NSLog("add: "+String(phoneNumber))
                    context.addIdentificationEntry(
                        withNextSequentialPhoneNumber: phoneNumber,
                        label: number.mDisplayName
                    )
                }
            }
        }
    }

}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occurred while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
    }

}
