import AppKit

class History {
  public var all: [HistoryItem] {
//    var unpinned = HistoryItem.unpinned()
//    if UserDefaults.standard.size != -1 { // If history removal is not disabled
//        while unpinned.count > UserDefaults.standard.size {
//          remove(unpinned.removeLast())
//        }
//    }

    return HistoryItem.all()
  }

  init() {
    UserDefaults.standard.register(defaults: [UserDefaults.Keys.size: UserDefaults.Values.size])
    if ProcessInfo.processInfo.arguments.contains("ui-testing") {
      clear()
    }
  }

  func add(_ item: HistoryItem) {
    if let existingHistoryItem = findSimilarItem(item) {
      item.contents = existingHistoryItem.contents
      item.firstCopiedAt = existingHistoryItem.firstCopiedAt
      item.numberOfCopies += existingHistoryItem.numberOfCopies
      item.pin = existingHistoryItem.pin
      remove(existingHistoryItem)
    } else {
      if UserDefaults.standard.playSounds {
        NSSound(named: NSSound.Name("write"))?.play()
      }
    }

    CoreDataManager.shared.saveContext()
  }

  func update(_ item: HistoryItem) {
    CoreDataManager.shared.saveContext()
  }

  func remove(_ item: HistoryItem) {
    item.getContents().forEach(CoreDataManager.shared.viewContext.delete(_:))
    CoreDataManager.shared.viewContext.delete(item)
    CoreDataManager.shared.saveContext()
  }

  func clearUnpinned() {
    //all.filter({ $0.pin == nil }).forEach(remove(_:))
  }

  func clear() {
    //all.forEach(remove(_:))
  }

  private func findSimilarItem(_ item: HistoryItem) -> HistoryItem? {
    let duplicates = all.filter({ $0 == item || $0.supersedes(item) })
    if duplicates.count > 1 {
      return duplicates.last
    } else {
      return nil
    }
  }
}
