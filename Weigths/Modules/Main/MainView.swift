import SwiftUI

struct MainView: View {

  @ObservedObject var presenter = MainPresenter()
  @State private var showAddWeight = false

  var body: some View {
    NavigationView {
      List {
        ForEach(self.presenter.weights) { weight in
          HStack {
            Text(weight.weight)
            Spacer()
            Text(weight.date)
              .font(.system(size: 12.0))
              .foregroundColor(.gray)
          }
        }
        .onDelete(perform: { index in
          self.presenter.removeWeight(at: index.first!)
        })
      }
      .navigationBarTitle("Weigths")
      .navigationBarItems(trailing:
        Button(action: { self.showAddWeight.toggle() }) {
          Image(systemName: "plus.circle")
            .font(.title)
            .accentColor(.black)
        }
        .sheet(isPresented: $showAddWeight) {
          AddWeightView()
        }
      )
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
