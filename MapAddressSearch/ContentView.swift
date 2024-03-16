//
//  ContentView.swift
//  MapAddressSearch
//
//  Created by Michael Peters on 3/16/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var city = ""
    @State private var county = ""
    @State private var state = ""
    @State private var countryCode = ""
    @State private var coordinates:CLLocationCoordinate2D?
    @State private var searchedCoordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @AppStorage("zipCodeToSearch") var zipCodeToSearch = ""
    @AppStorage("addressToOpen") var addressToOpen = ""
    @AppStorage("addressToSearch") var addressToSearch = ""
    @AppStorage("selectedTab") var selectedTab = "ZipSearch"
    @AppStorage("selectedMapStyleIndex") var selectedMapStyleIndex = 0
    @AppStorage("isTrafficOn") var isTrafficOn = false
    
    struct Location: Identifiable {
        let id = UUID()
        var name: String
        var coordinate: CLLocationCoordinate2D
    }
    
    let locations = [
        Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
        Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
    ]
        
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    var selectedMapStyle: MapStyle {
        return switch(selectedMapStyleIndex) {
          case 0: .standard(showsTraffic: isTrafficOn)
          case 1: .hybrid(showsTraffic: isTrafficOn)
          case 2: .imagery
          default: .standard(showsTraffic: isTrafficOn)
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            VStack {
                Text("Zip Code Search")
                    .font(.title)
                    .bold()
                Divider()
                HStack {
                    TextField("Zip", text: $zipCodeToSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        CLGeocoder().geocodeAddressString(zipCodeToSearch) { (placemarks, error) in
                            if let result = placemarks?.first {
                                city = result.locality!
                                county = result.subAdministrativeArea!
                                state = result.administrativeArea!
                                countryCode = result.isoCountryCode!
                            }
                        }
                    }, label: {
                        Text("Search")
                    })
                    .disabled(zipCodeToSearch.count < 5)
                }
                .padding(.horizontal, 5)
                Form {
                    Section ("Results:") {
                        LabeledContent("County:", value: county)
                        LabeledContent("City:", value: city)
                        LabeledContent("State:", value: state)
                        LabeledContent("Country:", value: countryCode)
                    }
                }
            }
            .tabItem {
                Label("Zip Search", systemImage: "sparkle.magnifyingglass")
            }
            .tag("ZipSearch")

            VStack {
                Text("Open Address in 🍎 Maps")
                    .font(.title)
                    .bold()
                Divider()
                HStack {
                    TextField("Address to open in 🍎 Maps", text: $addressToOpen)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Link(destination: URL(string: "http://maps.apple.com/?address=\(addressToOpen)")!) {
                        Text("Open")
                    }
                }
                .padding(.horizontal, 5)
                Spacer()
            }
            .tabItem {
                Label("Apple Maps", systemImage: "apple.logo")
            }
            .tag("OpenAppleMaps")
                    
            VStack {
                Text("MapView Search")
                    .font(.title)
                    .bold()
                Divider()
                HStack {
                    TextField("Address to display above", text: $addressToSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                    Button("Search") {
                        CLGeocoder().geocodeAddressString(addressToSearch) { (placemarks, error) in
                            if let result = placemarks?.first {
                                coordinates = result.location!.coordinate
                                searchedCoordinates = CLLocationCoordinate2D(latitude: coordinates!.latitude, longitude: coordinates!.longitude)
                                position = MapCameraPosition.region(
                                    MKCoordinateRegion(
                                        center: searchedCoordinates,
                                        span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
                                    )
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
                HStack {
                    Picker("Select Map Style", selection: $selectedMapStyleIndex) {
                        ForEach(arrMapStyles.indices, id:\.self) { index in
                            let foundIndex = arrMapStyles[index]
                            Text((foundIndex.name))
                                .tag(index)
                        }
                    }
                    Toggle("Traffic", isOn: $isTrafficOn)
                        .frame(width: 110)
                        .disabled(arrMapStyles[selectedMapStyleIndex].name == "Imagery")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 5)
                Map(position: $position) {
                    
                    Marker("Location", coordinate: CLLocationCoordinate2D(latitude: searchedCoordinates.latitude, longitude: searchedCoordinates.longitude))
                }
                .mapStyle(selectedMapStyle)
                    .onMapCameraChange(frequency: .onEnd) { context in
                        print(context.region)
                    }
            }
            .padding(.bottom)
            .tabItem {
                Label("MapView Search", systemImage: "mappin.circle")
            }
            .tag("SearchAddress")
            
            
            VStack {
                Text("Multiple Locations")
                    .font(.title)
                    .bold()
                Divider()
                Spacer()
                MapReader { proxy in
                    Map {
                        ForEach(locations) { location in
                            Marker(location.name, coordinate: location.coordinate)
                            Annotation(location.name, coordinate: location.coordinate) {
                                Text(location.name)
                                    .font(.headline)
                                    .padding()
                                    .background(.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(.capsule)
                            }
                            .annotationTitles(.hidden)
                        }
                    }
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                print(coordinate)
                            }
                        }
                }
            }
            .padding(.bottom)
            .tabItem {
                Label("Multiple Pins", systemImage: "plusminus.circle")
            }
            .tag("MultipleLocations")
        }
    }
}

#Preview {
    ContentView()
}
