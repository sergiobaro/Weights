import Foundation
import Combine

class AddWeightPresenter: ObservableObject {

  @Published var weight = ""
  @Published var addDisabled = true

  private let repository: WeightRepository = WeightRepositoryCoreData.shared
  private var cancellables = Set<AnyCancellable>()

  init() {
    $weight
      .sink { [weak self] value in
        self?.addDisabled = (Decimal(string: value) == nil)
      }
      .store(in: &cancellables)
  }

  func add() {
    guard let decimal = Decimal(string: self.weight) else { return }
    let weight = Weight(weightId: UUID(),
                        weight: decimal,
                        createdAt: Date())

    do {
      try repository.add(weight: weight)
    } catch {
      print(error)
    }
  }
}
