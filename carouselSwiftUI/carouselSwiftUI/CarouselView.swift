//
//  CarouselView.swift
//  carouselSwiftUI
//
//  Created by anas chaudhary on 12/05/25.
//


import SwiftUI

struct VisaDestination: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

struct DestinationCarouselView: View {
    let items: [VisaDestination]
    @State private var snappedItem: Double = 0
    @State private var draggingItem: Double = 0
    @State private var isInitialized = false

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let imageSize = screenWidth * 0.80
            let spacing: CGFloat = -imageSize * 0.15
            let effectiveSpacing = imageSize + spacing

            VStack {
                ZStack {
                    ForEach(Array(items.enumerated()), id: \.1.id) { index, item in
                        let dist = distance(index)
                        let offset = CGFloat(dist) * effectiveSpacing
                        let threshold: Double = 0.5
                        let maxScale: Double = 1.0
                        let minScale: Double = 0.85
                        let scale = abs(dist) < threshold ? minScale + (1.0 - abs(dist) / threshold) * (maxScale - minScale) : minScale
                        
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageSize, height: imageSize)
                            .clipped()
                            .cornerRadius(18)
                            .overlay(
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                }
                                .padding(),
                                alignment: .bottomLeading
                            )
                            .scaleEffect(scale)
                            .offset(x: offset)
                            .zIndex(1.0 - abs(dist) * 0.1)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onAppear {
                    if !isInitialized && !items.isEmpty {
                        let mid = Double(items.count / 2)
                        snappedItem = mid
                        draggingItem = mid
                        isInitialized = true
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            let dragOffset = -value.translation.width / effectiveSpacing
                            let proposed = snappedItem + dragOffset
                            let overscrollFactor = 0.3
                            let clamped = proposed < 0
                                ? proposed * overscrollFactor
                                : proposed > Double(items.count - 1)
                                    ? Double(items.count - 1) + (proposed - Double(items.count - 1)) * overscrollFactor
                                    : proposed
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
                                draggingItem = clamped
                            }
                        }
                        .onEnded { value in
                            var proposed = snappedItem - value.predictedEndTranslation.width / effectiveSpacing
                            proposed = round(proposed)
                            proposed = max(0, min(Double(items.count - 1), proposed))
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                snappedItem = proposed
                                draggingItem = proposed
                            }
                        }
                )
                PaginationDotsView(currentIndex: Int(snappedItem), total: items.count)
            }
        }
        .frame(height: 300)
    }
    
    private func distance(_ item: Int) -> Double {
        return Double(item) - draggingItem
    }
}

struct PaginationDotsView: View {
    let currentIndex: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(index == currentIndex ? Color.gray : Color.gray.opacity(0.3))
            }
        }
        .padding(.top, 10)
    }
}


// MARK: - Main Screen View

struct VisaSignupScreen: View {
    @State private var phoneNumber: String = ""

    let destinations: [VisaDestination] = [
        VisaDestination(imageName: "IMG1", title: "Malaysia", subtitle: "12K+ Visas on Atlys"),
        VisaDestination(imageName: "IMG2", title: "Dubai", subtitle: "Visas on Atlys"),
        VisaDestination(imageName: "IMG3", title: "Thailand", subtitle: "Visas on Atlys")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 30) 
            VStack(spacing: 6) {
                Text("atlys")
                    .font(.system(size: 30, weight: .bold))
                Text("visas on time")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            DestinationCarouselView(items: destinations)
            Spacer().frame(height: 10)
            Text("Get Visas\nOn Time")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 15)
            HStack {
                Text("🇮🇳 +91")
                    .padding(.leading)
                    .font(.body)
                TextField("Enter mobile number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .font(.body)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal)

            Button(action: {
                
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            HStack {
                Divider()
                Text("or")
                    .foregroundColor(.gray)
                Divider()
            }
            .padding(.horizontal)
            HStack(spacing: 25) {
                Image(systemName: "globe")
                    .resizable()
                    .frame(width: 28, height: 28)

                Image(systemName: "apple.logo")
                    .resizable()
                    .frame(width: 28, height: 28)

                Image(systemName: "envelope")
                    .resizable()
                    .frame(width: 28, height: 22)
            }
            Text("By continuing, you agree to our terms & privacy policy.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal)
            Spacer()
        }
    }
}


// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VisaSignupScreen()
    }
}
