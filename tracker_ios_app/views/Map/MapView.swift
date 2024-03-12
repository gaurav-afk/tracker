//
//  MapView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit
import TipKit


struct MapView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State var isSatelliteMap: Bool = false
    @State var isRecenterMap: Bool = false
    @State var position: MapCameraPosition = .automatic
//    @State var location: CLLocation?
    @State var share: Bool = false
    @State private var shareColor: Color = .red
    @State private var tappedLocation: Waypoint? = nil
    @State private var showLocationDetail = false
    private var dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    }
    
    
//    var body: some View {Text("testing map")}
        
    var body: some View {
        GeometryReader{ geo in
            Map(position: $position){
                // Path of the current user
                MapPolyline(coordinates: locationViewModel.locationSnapshots.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
                     .stroke(.blue, lineWidth: 2.0)
                
                
                // Paths of the following users
                ForEach(Array(locationViewModel.snapshotsOfFollowings), id: \.key) { userId, waypoints in
                    MapPolyline(coordinates: waypoints.sorted { $0.time < $1.time }.map {CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
                         .stroke(.green, lineWidth: 2.0)
                    
                    if let lastestLocation = waypoints.last, let nickName = userViewModel.currentUser?.userData?.following[userId]?.nickName {
                        Annotation("\(nickName) at \(dateFormatter.string(from: lastestLocation.time))", coordinate: CLLocationCoordinate2D(latitude: waypoints.last!.latitude, longitude: waypoints.last!.longitude)) {
                            Image(systemName: "mappin")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .shadow(color: .white, radius: 3)
                                .scaleEffect(x: -1)
                                .onTapGesture {
                                    print("tapped following")
                                    tappedLocation = waypoints.last!
                                    print("tappedlocation is now \(tappedLocation)")
                                    showLocationDetail.toggle()
                                }
                        }
                    }
                }
                
                Annotation("You're here", coordinate: CLLocationCoordinate2D(latitude: locationViewModel.currentLocation?.latitude ?? 0, longitude: locationViewModel.currentLocation?.longitude ?? 0)) {
                        Image(systemName: "mappin")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .shadow(color: .white, radius: 3)
                            .scaleEffect(x: -1)
                            .onTapGesture {
                                print("tapped yourself")
                                tappedLocation = locationViewModel.currentLocation!
                                print("tappedlocation is now \(tappedLocation)")
                                showLocationDetail.toggle()
                            }
                }
                
            }
            .mapStyle( isSatelliteMap ? .imagery(elevation: .realistic) : .standard(elevation: .realistic))
            .toolbarBackground(.automatic)
            .overlay(alignment: .bottomTrailing){
                VStack {
                    Button{
                        Task{
                            share.toggle()
                            if(shareColor == .red){
                                print("Location sharing is on") // MARK: START SHARING LOCATION WITH OTHERS
                            }else{
                                print("Location sharing is off") // // MARK: STOP SHARING LOCATION WITH OTHERS
                            }
                            shareColor = (shareColor == .green) ? .red : .green
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                share.toggle()
                            }
                        }
                    }label: {
                        Image(systemName: "wifi")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .imageScale(.small)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding(.trailing, 16)
                            .padding(.bottom, 5)
                            
                    }
                    .popoverTip(MapTip(), arrowEdge: .top)

                    BottomLeftButtonView(isRecenterMap: $isRecenterMap, isSatelliteMap: $isSatelliteMap, position: $position, share: $share, shareColor: $shareColor)
                    
                    Button{
                        isSatelliteMap.toggle()
                    }label: {
                        Image(systemName: isSatelliteMap ? "map.circle.fill" : "map.circle")
                            .font(.largeTitle)
                            .foregroundColor(.purple)
                            .imageScale(.large)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                            .padding([.bottom, .trailing], 16)
                            .padding(.bottom, geo.size.height/9)
                    }
                }
            }
            .sheet(isPresented: $showLocationDetail) {
//                LocationDetailsView(waypoint: locationViewModel.locationSnapshots.last!)
                if let tappedLocation = tappedLocation {
                    LocationDetailsView(waypoint: tappedLocation)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.fraction(0.5)])
                }
            }

            
            ZStack{
                ZStack {
                    Rectangle()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .foregroundColor(share ? shareColor.opacity(0.6) : .clear)
                        .animation(.easeInOut, value: share)
                    if share {
                       GridPattern()
                   }
               }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .onAppear{
                print("start location update")
                print("snapshot of following \(locationViewModel.snapshotsOfFollowings)")
                locationViewModel.startLocationUpdates()
                locationViewModel.startSavingSnapshots(userId: userViewModel.currentUser!.identifier)
            }
        }
            .edgesIgnoringSafeArea(.all)
    }
}


struct BottomLeftButtonView: View {
    @Binding var isRecenterMap: Bool
    @Binding var isSatelliteMap: Bool
    @Binding var position: MapCameraPosition
    @Binding var share: Bool
    @Binding var shareColor: Color
    
    var body: some View {
        
        
        
        Button{
            isRecenterMap = true
            withAnimation{
                position = .automatic
            }
        }label: {
            Image(systemName: "scope" )
                .font(.largeTitle)
                .foregroundColor(.orange)
                .imageScale(.medium)
                .background(.ultraThinMaterial)
                .clipShape(.circle)
                .padding(.trailing, 16)
                .padding(.bottom, 5)
        }
    }
    
}


struct GridPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let rows = 5
                let cols = 5
                let rowSpacing = geometry.size.height / CGFloat(rows)
                let colSpacing = geometry.size.width / CGFloat(cols)
                
                // Draw horizontal grid lines
                for i in 0..<rows {
                    let y = CGFloat(i) * rowSpacing
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                
                // Draw vertical grid lines
                for i in 0..<cols {
                    let x = CGFloat(i) * colSpacing
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
            }
            .stroke(Color.gray, lineWidth: 1) // Line color and width
        }
    }
}

//#Preview {
//    MapView()
//        .preferredColorScheme(.dark)
//}
