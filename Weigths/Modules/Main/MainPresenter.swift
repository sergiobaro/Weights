import Foundation
import Combine

struct WeightViewModel: Identifiable {
  var id: UUID { weightId }

  let weightId: UUID
  let weight: String
  let date: String
}

class MainPresenter: ObservableObject {

  @Published var weights = [WeightViewModel]()

  private let repository: WeightRepository = WeightRepositoryCoreData.shared
  private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "dd-MM-YYYY HH:mm"

    return df
  }()
  private var cancellables = Set<AnyCancellable>()

  init() {
    repository.weights()
      .sink { [weak self] weights in
        self?.weights = weights.map {
          WeightViewModel(weightId: $0.weightId,
                          weight: $0.weight.stringValue,
                          date: self?.dateFormatter.string(from: $0.createdAt) ?? "")
        }
      }
      .store(in: &cancellables)
  }

  func removeWeight(at index: Int) {
    guard self.weights.indices.contains(index) else { return }

    let weight = self.weights[index]

    do {
      try self.repository.remove(weightId: weight.weightId)
    } catch {
      print(error)
    }
  }
}

private extension Decimal {
  var stringValue: String {
    (self as NSDecimalNumber).stringValue
  }
}
