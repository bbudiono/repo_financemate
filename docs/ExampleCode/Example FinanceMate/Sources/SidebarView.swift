import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(SidebarItem.allCases) { item in
                NavigationLink(
                    destination: EmptyView(),
                    tag: item,
                    selection: $selection
                ) {
                    Label(item.name, systemImage: item.icon)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(selection: .constant(.dashboard))
    }
}