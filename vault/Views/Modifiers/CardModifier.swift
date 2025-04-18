//
//  CardModifier.swift
//  vault
//
//  Created by Bryant Huynh on 4/13/25.
//

import SwiftUI

struct FriendRowCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.vertical, 4)
    }
}

struct FriendDetailSectionCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


extension View {
    func friendRowCardStyle() -> some View {
        modifier(FriendRowCardStyle())
    }
    
    func friendDetailSectionCardStyle() -> some View {
        modifier(FriendDetailSectionCardStyle())
    }
}
