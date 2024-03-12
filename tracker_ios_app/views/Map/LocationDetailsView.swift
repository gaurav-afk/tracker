//
//  LocationDetailsView.swift
//  tracker_ios_app
//
//  Created by macbook on 10/3/2024.
//

import SwiftUI

struct LocationDetailsView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    private var waypoint: Waypoint
    
    init(waypoint: Waypoint) {
        self.waypoint = waypoint
    }
    
    var body: some View {
        VStack {
            Text("Location Details")
            
            if let weather = locationViewModel.currentWeather {
                HStack {
                    AsyncImage(url: weather.conditionIconUrl) { phase in
                        switch phase{
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width * 0.3, height: 100)
                                
                            default:
                                Image(systemName: "xmark.square.fill")
                                    .onAppear(){
                                        print("\(#function) cannot show image from \(weather.conditionIconUrl)")
                                    }
                        }
                    }
                    Text("\(weather.condition)")
                }
                
                Text("region: \(weather.region)")
                Text("country: \(weather.country)")
                Text("temp: \(weather.temp)")
                Text("humidity: \(weather.humidity)")
                Text("last Updated: \(weather.lastUpdate)")
            }
            else {
                Text("Weather not available")
            }
        }
        .onAppear() {
            Task {
                await locationViewModel.getLocationDetails(latitude: waypoint.latitude, longitude: waypoint.longitude)
            }
        }
    }
}

//#Preview {
//    LocationDetailsView()
//}
