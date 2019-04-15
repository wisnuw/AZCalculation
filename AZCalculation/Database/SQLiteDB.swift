//
//  SQLiteDB.swift
//  asntoolbox
//
//  Created by Frans Kurniawan on 4/5/17.
//  Copyright © 2017 PT. Asuransi Allianz Life Indonesia. All rights reserved.
//

import Foundation
import SQLite3

let SQLITE_DATE = SQLITE_NULL + 1

private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

// MARK:- SQLiteDB Class - Does all the work
@objc(SQLiteDB)
public class SQLiteDB: NSObject {
  let DB_NAME = "POS.db"
  let QUEUE_LABEL = "SQLiteDB"
  static let shared = SQLiteDB()
  private var db: OpaquePointer? = nil
  private var queue: DispatchQueue!
  private let fmt = DateFormatter()
  private var path: String!
  private var isOpen = false

  private override init() {
    super.init()
    // Set up essentials
    queue = DispatchQueue(label: QUEUE_LABEL, attributes: [])
    // You need to set the locale in order for the 24-hour date format to work correctly on devices where 24-hour format is turned off
    fmt.locale = Locale(identifier: "en_US_POSIX")
    fmt.timeZone = TimeZone(secondsFromGMT: 0)
    fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
  }

  deinit {
    closeDB()
  }

  override public var description: String {
    return "SQLiteDB: \(path)"
  }

  // MARK:- Public Methods
  /// Open the database specified by the `DB_NAME` variable and assigns the internal DB references. If a database is currently open, the method first closes the current database and gets a new DB references to the current database pointed to by `DB_NAME`
  ///
  /// - Parameter copyFile: Whether to copy the file named in `DB_NAME` from resources or to create a new empty database file. Defaults to `true`
  /// - Returns: Returns a boolean value indicating if the database was successfully opened or not.
  @discardableResult
  public func openDB(copyFile: Bool = false) -> Bool {
    if db != nil {
      closeDB()
    }
    // Set up for file operations
    let fm = FileManager.default
    // Get path to DB in Documents directory
    let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                     FileManager.SearchPathDomainMask.userDomainMask,
                                                     true)[0]
   
    var path = Bundle.main.path(forResource: "POS", ofType: "db")
    if path == nil{
      let bundle = Bundle(for: type(of: self))
      path = bundle.path(forResource: "POS", ofType: "db")!
    }
    //let path = (docDir as NSString).appendingPathComponent(DB_NAME)
    // Check if DB is there in Documents directory
    if copyFile {
      // The database does not exist, so copy it
      guard let rp = Bundle.main.resourcePath else {
        return false
      }
      let from = (rp as NSString).appendingPathComponent(DB_NAME)
      do {
        if fm.fileExists(atPath: path!) {
          try fm.removeItem(at: URL(fileURLWithPath: path!))
        }
        
        try fm.copyItem(atPath: from, toPath: path!)
      } catch let error {
        assert(false, "SQLiteDB: Failed to copy writable version of DB! Error - \(error.localizedDescription)")
        return false
      }
    }
    // Open the DB
    let cpath = path!.cString(using: String.Encoding.utf8)
    let error = sqlite3_open_v2(cpath!, &db, SQLITE_OPEN_READWRITE, nil)
    if error != SQLITE_OK {
      // Open failed, close DB and fail
      //NSLog("SQLiteDB - failed to open DB!")
      sqlite3_close(db)
      return false
    }
    //NSLog("SQLiteDB opened!")
    isOpen = true
    return true
  }

  // MARK:- Public Methods
  public func dbDate(dt: Date) -> String {
    return fmt.string(from: dt)
  }

  // Execute SQL with parameters and return result code
  public func execute(sql: String, parameters: [Any]? = nil) -> Int {
    var result = 0
    queue.sync {
      if let stmt = self.prepare(sql: sql, params: parameters) {
        result = self.execute(stmt: stmt, sql: sql)
      }
    }
    return result
  }

  // Run SQL query with parameters
  public func query(sql: String, parameters: [Any]? = nil) -> [[String: Any]] {
    if !isOpen {
      let resultOpen = openDB()
      if !resultOpen {
        return [[String: Any]]()
      }
    }

    assert(db != nil, "Database has not been opened! Use the openDB() method before any DB queries.")
    var rows = [[String: Any]]()
    queue.sync {
      if let stmt = self.prepare(sql: sql, params: parameters) {
        rows = self.query(stmt: stmt, sql: sql)
      }
    }
    return rows
  }

  // Versioning
  public func getDBVersion() -> Int {
    var version = 0
    let arr = query(sql: "PRAGMA user_version")
    if arr.count == 1 {
      version = arr[0]["user_version"] as! Int
    }
    return version
  }

  // Sets the 'user_version' value, a user-defined version number for the database. This is useful for managing migrations.
  func set(version: Int) {
    _ = execute(sql: "PRAGMA user_version=\(version)")
  }

  // MARK:- Private Methods
  // MARK:- Private Methods
  /// Close the currently open SQLite database. Before closing the DB, the framework automatically takes care of optimizing the DB at frequent intervals by running the following commands:
  /// 1. **VACUUM** - Repack the DB to take advantage of deleted data
  /// 2. **ANALYZE** - Gather information about the tables and indices so that the query optimizer can use the information to make queries work better.
  public func closeDB() {
    if db != nil {
      // Get launch count value
      let ud = UserDefaults.standard
      var launchCount = ud.integer(forKey: "LaunchCount")
      launchCount -= 1
      //NSLog("SQLiteDB - Launch count \(launchCount)")
      var clean = false
      if launchCount < 0 {
        clean = true
        launchCount = 500
      }
      ud.set(launchCount, forKey: "LaunchCount")
      ud.synchronize()
      // Do we clean DB?
      if !clean {
        sqlite3_close(db)
        self.db = nil
        isOpen = false
        return
      }
      // Clean DB
      //NSLog("SQLiteDB - Optimize DB")
      let sql = "VACUUM; ANALYZE"
      if CInt(execute(sql: sql)) != SQLITE_OK {
        //NSLog("SQLiteDB - Error cleaning DB")
      }
      sqlite3_close(db)
      self.db = nil
      isOpen = false
      sqlite3_db_release_memory(db)
    }
  }


  // Private method which prepares the SQL
  private func prepare(sql: String, params: [Any]?) -> OpaquePointer? {
    var stmt: OpaquePointer? = nil
    let cSql = sql.cString(using: String.Encoding.utf8)
    // Prepare
    let result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
    if result != SQLITE_OK {
      sqlite3_finalize(stmt)
      if let error = String(validatingUTF8: sqlite3_errmsg(self.db)) {
        let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: \(error)"
        NSLog(msg)
      }
      return nil
    }
    // Bind parameters, if any
    if params != nil {
      // Validate parameters
      let cntParams = sqlite3_bind_parameter_count(stmt)
      let cnt = CInt(params!.count)
      if cntParams != cnt {
        let msg = "SQLiteDB - failed to bind parameters, counts did not match. SQL: \(sql), Parameters: \(params.debugDescription)"
        NSLog(msg)
        return nil
      }
      var flag: CInt = 0
      // Text & BLOB values passed to a C-API do not work correctly if they are not marked as transient.
      for ndx in 1...cnt {
//				NSLog("Binding: \(params![ndx-1]) at Index: \(ndx)")
        // Check for data types
        if let txt = params![Int(ndx) - 1] as? String {
          flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
        } else if let data = params![Int(ndx) - 1] as? NSData {
          flag = sqlite3_bind_blob(stmt, CInt(ndx), data.bytes, CInt(data.length), SQLITE_TRANSIENT)
        } else if let date = params![Int(ndx) - 1] as? Date {
          let txt = fmt.string(from: date)
          flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
        } else if let val = params![Int(ndx) - 1] as? Bool {
          let num = val ? 1 : 0
          flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(num))
        } else if let val = params![Int(ndx) - 1] as? Double {
          flag = sqlite3_bind_double(stmt, CInt(ndx), CDouble(val))
        } else if let val = params![Int(ndx) - 1] as? Int {
          flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(val))
        } else {
          flag = sqlite3_bind_null(stmt, CInt(ndx))
        }
        // Check for errors
        if flag != SQLITE_OK {
          sqlite3_finalize(stmt)
          if let error = String(validatingUTF8: sqlite3_errmsg(self.db)) {
            let msg = "SQLiteDB - failed to bind for SQL: \(sql), Parameters: \(params.debugDescription), Index: \(ndx) Error: \(error)"
            NSLog(msg)
          }
          return nil
        }
      }
    }
    return stmt
  }

  // Private method which handles the actual execution of an SQL statement
  private func execute(stmt: OpaquePointer, sql: String) -> Int {
    // Step
    let res = sqlite3_step(stmt)
    if res != SQLITE_OK && res != SQLITE_DONE {
      sqlite3_finalize(stmt)
      if let error = String(validatingUTF8: sqlite3_errmsg(self.db)) {
        let msg = "SQLiteDB - failed to execute SQL: \(sql), Error: \(error)"
        NSLog(msg)
      }
      return 0
    }
    // Is this an insert
    let upp = sql.uppercased()
    var result = 0
    if upp.hasPrefix("INSERT ") {
      // Known limitations: http://www.sqlite.org/c3ref/last_insert_rowid.html
      let rid = sqlite3_last_insert_rowid(self.db)
      result = Int(rid)
    } else if upp.hasPrefix("DELETE") || upp.hasPrefix("UPDATE") {
      var cnt = sqlite3_changes(self.db)
      if cnt == 0 {
        cnt += 1
      }
      result = Int(cnt)
    } else {
      result = 1
    }
    // Finalize
    sqlite3_finalize(stmt)
    return result
  }

  // Private method which handles the actual execution of an SQL query
  private func query(stmt: OpaquePointer, sql: String) -> [[String: Any]] {
    var rows = [[String: Any]]()
    var fetchColumnInfo = true
    var columnCount: CInt = 0
    var columnNames = [String]()
    var columnTypes = [CInt]()
    var result = sqlite3_step(stmt)
    while result == SQLITE_ROW {
      // Should we get column info?
      if fetchColumnInfo {
        columnCount = sqlite3_column_count(stmt)
        for index in 0..<columnCount {
          // Get column name
          let name = sqlite3_column_name(stmt, index)
          columnNames.append(String(validatingUTF8: name!)!)
          // Get column type
          columnTypes.append(self.getColumnType(index: index, stmt: stmt))
        }
        fetchColumnInfo = false
      }
      // Get row data for each column
      var row = [String: Any]()
      for index in 0..<columnCount {
        let key = columnNames[Int(index)]
        let type = columnTypes[Int(index)]
        if let val = getColumnValue(index: index, type: type, stmt: stmt) {
//						NSLog("Column type:\(type) with value:\(val)")
          row[key] = val
        }
      }
      rows.append(row)
      // Next row
      result = sqlite3_step(stmt)
    }
    sqlite3_clear_bindings(stmt)
//    sqlite3_db_release_memory(stmt)
    sqlite3_finalize(stmt)
    return rows
  }

  // Get column type
  private func getColumnType(index: CInt, stmt: OpaquePointer) -> CInt {
    var type: CInt = 0
    // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
    let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
    let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
    let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
    let intTypes = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
    let nullTypes = ["NULL"]
    let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
    // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
    let buf = sqlite3_column_decltype(stmt, index)
//		NSLog("SQLiteDB - Got column type: \(buf)")
    if buf != nil {
      var tmp = String(validatingUTF8: buf!)!.uppercased()
      // Remove bracketed section
      if let pos = tmp.range(of: "(") {
        tmp = tmp.substring(to: pos.lowerBound)
      }
      // Remove unsigned?
      // Remove spaces
      // Is the data type in any of the pre-set values?
//			NSLog("SQLiteDB - Cleaned up column type: \(tmp)")
      if intTypes.contains(tmp) {
        return SQLITE_INTEGER
      }
      if realTypes.contains(tmp) {
        return SQLITE_FLOAT
      }
      if charTypes.contains(tmp) {
        return SQLITE_TEXT
      }
      if blobTypes.contains(tmp) {
        return SQLITE_BLOB
      }
      if nullTypes.contains(tmp) {
        return SQLITE_NULL
      }
      if dateTypes.contains(tmp) {
        return SQLITE_DATE
      }
      return SQLITE_TEXT
    } else {
      // For expressions and sub-queries
      type = sqlite3_column_type(stmt, index)
    }
    return type
  }

  // Get column value
  private func getColumnValue(index: CInt, type: CInt, stmt: OpaquePointer) -> Any? {
    // Integer
    if type == SQLITE_INTEGER {
      let val = sqlite3_column_int(stmt, index)
      return Int(val)
    }
    // Float
    if type == SQLITE_FLOAT {
      let val = sqlite3_column_double(stmt, index)
      return Double(val)
    }
    // Text - handled by default handler at end
    // Blob
    if type == SQLITE_BLOB {
      let data = sqlite3_column_blob(stmt, index)
      let size = sqlite3_column_bytes(stmt, index)
      let val = NSData(bytes: data, length: Int(size))
      return val
    }
    // Null
    if type == SQLITE_NULL {
      return nil
    }
    // Date
    if type == SQLITE_DATE {
      // Is this a text date
      if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
        let uptr = ptr.bindMemory(to: CChar.self, capacity: 0)
        let txt = String(validatingUTF8: uptr)!
        let set = CharacterSet(charactersIn: "-:")
        if txt.rangeOfCharacter(from: set) != nil {
          // Convert to time
          var time: tm = tm(tm_sec: 0,
                            tm_min: 0,
                            tm_hour: 0,
                            tm_mday: 0,
                            tm_mon: 0,
                            tm_year: 0,
                            tm_wday: 0,
                            tm_yday: 0,
                            tm_isdst: 0,
                            tm_gmtoff: 0,
                            tm_zone: nil)
          strptime(txt, "%Y-%m-%d %H:%M:%S", &time)
          time.tm_isdst = -1
          let diff = TimeZone.current.secondsFromGMT()
          let t = mktime(&time) + diff
          let ti = TimeInterval(t)
          let val = Date(timeIntervalSince1970: ti)
          return val
        }
      }
      // If not a text date, then it's a time interval
      let val = sqlite3_column_double(stmt, index)
      let dt = Date(timeIntervalSince1970: val)
      return dt
    }
    // If nothing works, return a string representation
    if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
      let uptr = ptr.bindMemory(to: CChar.self, capacity: 0)
      let txt = String(validatingUTF8: uptr)
      return txt
    }
    return nil
  }

  func isOpenStatus() -> Bool {
    return isOpen
  }
}
// MARK: Base SQL Query
protocol AZSQLQuery {
  func queryBySQL(_ query: String, asArray: Bool) -> Any?
}
extension AZSQLQuery{
  /// Query to database tables
  ///
  /// - Parameters:
  ///   - query: query containing all the parameters
  /// - Returns: Any, You can case according to the value
  public func queryBySQL(_ query: String, asArray: Bool = false) -> Any? {
    let db = SQLiteDB.shared
    if(!db.isOpenStatus()){
      _ = db.openDB()
    }
    var value: Any = 0
    let data = db.query(sql: query)
    if data.count > 0 {
      if asArray {
        value = data.flatMap(){ $0.values }
      } else {
        if let dbValue = data[0].first{
          value = dbValue.value
        }else{
          value = data
        }
      }
    }
    return value
  }
}
