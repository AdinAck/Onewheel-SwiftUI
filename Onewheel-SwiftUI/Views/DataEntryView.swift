//
//  DataEntryView.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/24/22.
//

import SwiftUI

struct DataEntryView: View {
    @State private var local: String = ""
    @FocusState private var focus: Bool
    
    @Binding var data: String
    
    var body: some View {
        HStack {
            Text("Cells (series)")
            Spacer()
            TextField("", text: $local)
                .focused($focus)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
        }
        .onAppear {
            local = data
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focus.toggle()
                    data = local
                }
            }
        }
    }
}

//struct DataEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DataEntryView()
//    }
//}
