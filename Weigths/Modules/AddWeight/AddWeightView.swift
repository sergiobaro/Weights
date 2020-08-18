import SwiftUI

struct AddWeightView: View {

  @ObservedObject private var presenter = AddWeightPresenter()
  @State private var weight: String = ""

  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Weight", text: $presenter.weight)
            .keyboardType(.decimalPad)
        }
        Section {
          HStack {
            Spacer()
            Button(action: { self.presenter.add() }) {
              Text("Add")
            }
            .disabled(presenter.addDisabled)
            Spacer()
          }
        }
      }
      .navigationBarTitle("Add Weight")
    }
  }
}

struct AddWeightView_Previews: PreviewProvider {
  static var previews: some View {
    AddWeightView()
  }
}
