//
//  ContentView.swift
//  MapForCSProject
//
//  Created by Joseph Garnett on 16/01/2023.
//
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .ignoresSafeArea()
            .tint(Color(.systemRed))
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}



