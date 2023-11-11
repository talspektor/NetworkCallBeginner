//
//  ContentView.swift
//  NetworkCallBeginner
//
//  Created by Tal talspektor on 11/11/2023.
//

import SwiftUI

struct ContentView: View {

    @State private var user: GitHubUser?

    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
                    .frame(width: 120, height: 120)
            }

            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)

            Text(user?.bio ?? "Bio Placeholder")
                .padding()

            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHEror.invalidURL {
                print("invalid URL")
            } catch GHEror.invalidResponse {
                print("invalid response")
            } catch GHEror.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }

    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/talspektor"

        guard let url = URL(string: endpoint) else {
            throw GHEror.invalidURL
        }

        let (data, resposne) = try await URLSession.shared.data(from: url)

        guard let response = resposne as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHEror.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHEror.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHEror: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
