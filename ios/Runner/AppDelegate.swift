import UIKit
import Flutter
import flutter_local_notifications
import WebKit
import SQLite3

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    // データ移行のためのMethodChannelをセットアップ
    let controller = window?.rootViewController as! FlutterViewController
    let dataChannel = FlutterMethodChannel(name: "com.nailgrow/data_migration", binaryMessenger: controller.binaryMessenger)
    
    dataChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      if call.method == "migrateLocalStorageData" {
        self.migrateLocalStorageData(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func migrateLocalStorageData(result: @escaping FlutterResult) {
    // Cordovaアプリのローカルストレージデータを取得するパス
    let libraryDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
    let webkitDir = libraryDir.appendingPathComponent("WebKit")
    
    // LocalStorageデータを検索
    do {
      let fileManager = FileManager.default
      var cordovaLocalStorageDir: URL?
      
      // WebKit/WebsiteDataディレクトリ内を検索
      if let websiteDataDir = try? fileManager.contentsOfDirectory(at: webkitDir, includingPropertiesForKeys: nil) {
        for directory in websiteDataDir {
          if directory.lastPathComponent == "LocalStorage" {
            cordovaLocalStorageDir = directory
            break
          }
        }
      }
      
      // WebKit/LocalStorageディレクトリ内を検索 (古いiOSバージョン用)
      if cordovaLocalStorageDir == nil {
        cordovaLocalStorageDir = webkitDir.appendingPathComponent("LocalStorage")
      }
      
      guard let localStorageDir = cordovaLocalStorageDir, fileManager.fileExists(atPath: localStorageDir.path) else {
        result(FlutterError(code: "STORAGE_NOT_FOUND", message: "LocalStorageディレクトリが見つかりませんでした", details: nil))
        return
      }
      
      // すべてのlocalstorageファイルを検索
      let localStorageFiles = try fileManager.contentsOfDirectory(at: localStorageDir, includingPropertiesForKeys: nil)
      
      // SQLiteデータベースファイルを探す
      var migrationData: [String: Any] = [:]
      var foundData = false
      
      for file in localStorageFiles {
        if file.pathExtension == "localstorage" {
          // SQLiteデータベースとしてファイルを開く
          let db = try openSQLiteDatabase(path: file.path)
          if let data = try readLocalStorageData(database: db) {
            migrationData = data
            foundData = true
            break
          }
        }
      }
      
      if foundData {
        result(migrationData)
      } else {
        result(FlutterError(code: "NO_DATA", message: "LocalStorageデータが見つかりませんでした", details: nil))
      }
    } catch {
      result(FlutterError(code: "MIGRATION_ERROR", message: "データ移行エラー: \(error.localizedDescription)", details: nil))
    }
  }
  
  private func openSQLiteDatabase(path: String) throws -> OpaquePointer? {
    var db: OpaquePointer?
    guard sqlite3_open(path, &db) == SQLITE_OK else {
      throw NSError(domain: "SQLiteError", code: 1, userInfo: [NSLocalizedDescriptionKey: "データベースを開けませんでした"])
    }
    return db
  }
  
  private func readLocalStorageData(database db: OpaquePointer?) throws -> [String: Any]? {
    var migrationData: [String: Any] = [:]
    
    // LocalStorageのキーを検索するクエリ
    let query = "SELECT key, value FROM ItemTable"
    var statement: OpaquePointer?
    
    guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
      throw NSError(domain: "SQLiteError", code: 2, userInfo: [NSLocalizedDescriptionKey: "クエリの準備に失敗しました"])
    }
    
    defer {
      sqlite3_finalize(statement)
    }
    
    // 必要なキーのリスト
    let keysToMigrate = ["start_year", "start_month", "my_goal", "my_badges", "myCalGoal", "start_day", "myDayCount"]
    var foundAnyKey = false
    
    while sqlite3_step(statement) == SQLITE_ROW {
      if let keyPtr = sqlite3_column_text(statement, 0) {
        let key = String(cString: keyPtr)
        
        if keysToMigrate.contains(key) {
          foundAnyKey = true
          
          if let valuePtr = sqlite3_column_text(statement, 1) {
            let valueString = String(cString: valuePtr)
            
            // 数値かJSONかを判断して適切に変換
            if let intValue = Int(valueString) {
              migrationData[key] = intValue
            } else if let doubleValue = Double(valueString) {
              migrationData[key] = doubleValue
            } else if valueString.hasPrefix("[") || valueString.hasPrefix("{") {
              // JSONの場合
              if let jsonData = valueString.data(using: .utf8),
                 let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) {
                migrationData[key] = jsonObject
              } else {
                migrationData[key] = valueString
              }
            } else {
              migrationData[key] = valueString
            }
          }
        }
      }
    }
    
    return foundAnyKey ? migrationData : nil
  }
}
