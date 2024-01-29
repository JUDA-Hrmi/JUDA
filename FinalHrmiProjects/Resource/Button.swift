//
//  Button.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

// NavigationLink: without Button blinking animation
struct EmptyActionStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
	}
}
