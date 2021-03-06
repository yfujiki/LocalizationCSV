//
//  LocaleDatabase.swift
//  LocalizationCSV
//
//  Created by Rogelio Gudino on 9/12/15.
//  Copyright © 2015 Rogelio Gudino. All rights reserved.
//

import Foundation

enum DataBaseError: ErrorType {
    case DataBaseDoesNotExist(message: String)
    case FailToOpen(message: String)
    case FailToClose(message: String)
    case FailedToPrepareSelectQuery(message: String)
    case FailedToFinalizeSelectQuery(message: String)
}

func localeFolderNameForDisplayName(displayName: String) throws -> String? {
    let query = "SELECT folder_name FROM Locale WHERE display_name == \"\(displayName)\" LIMIT 1"
    return try executeSingleRowResultQuery(query)
}

func localeDisplayNameForFolderName(folderName: String) throws -> String? {
    let query = "SELECT display_name FROM Locale WHERE folder_name == \"\(folderName)\" LIMIT 1"
    return try executeSingleRowResultQuery(query)
}

private func executeSingleRowResultQuery(query: String) throws -> String? {
    var dataBase: COpaquePointer = nil
    guard let dataBaseLocation = NSBundle.mainBundle().pathForResource("LocalizationCSV", ofType: "sqlite") else {
        throw DataBaseError.DataBaseDoesNotExist(message: "Data base file not found.")
    }
    if sqlite3_open(dataBaseLocation, &dataBase) != SQLITE_OK {
        throw DataBaseError.FailToOpen(message: "Failed to open the data base.")
    }
    
    var statement: COpaquePointer = nil
    if sqlite3_prepare_v2(dataBase, query, -1, &statement, nil) != SQLITE_OK {
        throw DataBaseError.FailedToPrepareSelectQuery(message: "There was an error trying to read from the data base.")
    }
    
    var result: String?
    if sqlite3_step(statement) == SQLITE_ROW {
        let resultCharacters = sqlite3_column_text(statement, 0)
        if resultCharacters != nil {
            result = String.fromCString(UnsafePointer<Int8>(resultCharacters))
        }
    }
    if sqlite3_finalize(statement) != SQLITE_OK {
        throw DataBaseError.FailedToFinalizeSelectQuery(message: "There was an error trying to read from the data base.")
    }
    statement = nil
    
    if sqlite3_close(dataBase) != SQLITE_OK {
        throw DataBaseError.FailToClose(message: "Failed to close the data base.")
    }
    dataBase = nil
    
    return result
}
