import Foundation

struct WasteItem {
    static let pool: [WasteItem] = [
        WasteItem(name: .sortingItemGlassBottle, category: .glass),
        WasteItem(name: .sortingItemGlassJar, category: .glass),
        WasteItem(name: .sortingItemSodaCan, category: .metal),
        WasteItem(name: .sortingItemFoil, category: .metal),
        WasteItem(name: .sortingItemNewspaper, category: .paper),
        WasteItem(name: .sortingItemCardboardBox, category: .paper),
        WasteItem(name: .sortingItemPlasticBag, category: .plastic),
        WasteItem(name: .sortingItemPlasticBottle, category: .plastic),
    ]

    let name: LocalizedStringResource
    let category: WasteCategory
}
